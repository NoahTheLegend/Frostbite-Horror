
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.inventoryButtonPos = Vec2f(0, 0);
	this.getCurrentScript().tickFrequency = 90;
	this.SetFacingLeft(XORRandom(100) < 50);

	this.addCommandID("sync");

	if (isServer())
	{
		this.set_u8("anim", XORRandom(anims.length));
		this.set_u8("frame", XORRandom(8));
	}

	if (isClient())
	{
		CBitStream params;
		params.write_bool(true);
		this.SendCommand(this.getCommandID("sync"), params);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getDistanceTo(this) <= 16.0f && canSeeButtons(this, forBlob);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable();
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (this.getSprite() is null) return;
	this.getSprite().SetRelativeZ(-20.0f);
}

const string[] anims = {
	"green",
	"grey"
};

void onInit(CSprite@ this)
{
	// Building
	CBlob@ blob = this.getBlob();
	this.SetZ(-25); 
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync"))
	{
		bool init;
		if (!params.saferead_bool(init)) return;

		if (init && isServer())
		{
			CBitStream params;
			params.write_bool(false);
			params.write_u8(this.get_u8("anim"));
			params.write_u8(this.get_u8("frame")); // amount of frames here, since its serverside you gotta do it manually
			this.SendCommand(this.getCommandID("sync"), params);
			
			return;
		}
		if (!init && isClient())
		{
			u8 anim = params.read_u8();
			u8 frame = params.read_u8();
			if (anim > anims.length) return;
			
			CSprite@ sprite = this.getSprite();
			if (sprite is null) return;

			VaryVisuals(sprite, anim, frame);
		}
	}
}

void VaryVisuals(CSprite@ this, u8 anim, u8 frame)
{
	this.SetAnimation(anims[anim]);
	this.SetFrameIndex(frame);

	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	
	u32 seed = blob.getNetworkID();
	bool has_amogus = (seed+"").find("6") != -1 && (seed+"").find("9") != -1;
	if (has_amogus)
	{
		CSpriteLayer@ amo = this.addSpriteLayer("amo", "VisualEffects.png", 16, 16);
		if (amo is null) return;
		Animation@ anim = amo.addAnimation("frame", 0, false);
		if (anim is null) return;
		//printf("sus");
		anim.AddFrame(seed%2 + 2);
		amo.SetAnimation(anim);
		amo.ScaleBy(Vec2f(0.4f, 0.4f));
		amo.SetOffset(Vec2f(XORRandom(50)*0.1f-2.5f, XORRandom(30)*0.1f-1.5f));
	}
	
	if (blob.getShape() !is null && this.animation.frame > 3)
	{
		blob.getShape().setFriction(0.8);
	}
}
