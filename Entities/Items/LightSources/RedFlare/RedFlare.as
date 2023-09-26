#include "ParticleSparks.as";

const u16 duration = 60 * 30;

void onInit(CBlob@ this)
{
	this.Tag("ignore fall");
	this.getShape().SetRotationsAllowed(true);

	this.addCommandID("sync");

	if (isClient())
	{
		CBitStream params;
		params.write_bool(false);
		this.SendCommand(this.getCommandID("sync"), params);
	}

	this.getCurrentScript().tickFrequency = 3;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.hasTag("activated")) return;

	s32 timer = blob.get_s32("timer") - getGameTime();
	if (!blob.hasTag("extinguished"))
	{
		blob.SetLight(true);
		blob.SetLightRadius((96.0f+XORRandom(16)) * (Maths::Max(0,timer)/(getGameTime()+duration))+16.0f);
		blob.SetLightColor(SColor(255, 200+XORRandom(55), 25, 25));
	}
	else blob.SetLight(false);

	if (timer < 0)
	{
		this.SetAnimation("end");
		return;
	}
	else this.SetAnimation("activate");
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;
	if (!this.hasTag("activated") || this.hasTag("extinguished")) return;

	s32 timer = this.get_s32("timer") - getGameTime();
	if (timer < 0)
	{
		this.server_SetTimeToDie(15.0f);
		this.setInventoryName("Red Flare (extinguished)");
		this.Tag("extinguished");
	}

	MakeParticle(this, Vec2f(0, 0.5f - XORRandom(11)*0.1f), "RedFlareFire"+XORRandom(2));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		this.Tag("activated");
		this.set_s32("timer", getGameTime() + duration);
	}
	else if (cmd == this.getCommandID("sync"))
	{
		bool truesync = params.read_bool();
		
		if (!truesync && isServer()) // init
		{
			if (this.hasTag("activated"))
			{
				CBitStream params1;
				params1.write_bool(true);
				params1.write_s32(this.get_s32("timer"));
			}
		}
		if (truesync && isClient())
		{
			s32 timer = params.read_s32();
			this.set_s32("timer", timer);
		}
	}
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, -8).RotateBy(this.getAngleDegrees());
	CParticle@ p = ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
	if (p !is null)
	{
		//p.collides = true;
		//p.diesoncollide = false;
		p.windaffect = 5.0f;
		p.setRenderStyle(RenderStyle::additive);
	}
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return !this.hasTag("activated");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ ap)
{
	this.setAngleDegrees(0);
	this.getShape().SetRotationsAllowed(false);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ ap)
{
	this.getShape().SetRotationsAllowed(true);
}