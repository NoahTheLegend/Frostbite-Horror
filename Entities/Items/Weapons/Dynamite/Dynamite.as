#include "Hitters.as";
#include "DynamiteCommon.as";
#include "CustomBlocks.as";

void onInit(CBlob@ this)
{
	this.set_u16("explosive_parent", 0);
	this.getShape().getConsts().net_threshold_multiplier = 2.0f;
	SetupBomb(this, bomb_fuse, 48.0f, 3.0f, 24.0f, 0.4f, true);
	this.getSprite().SetEmitSoundPaused(true);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null) ap.SetKeysToTake(key_action2);

	this.Tag("ignore blocking actors");
	this.Tag("place45 perp");
	this.Tag("can place");
	this.Tag("cant repair");
}

// todo: special cracking explosion when planted

void set_delay(CBlob@ this, string field, s32 delay)
{
	this.set_s32(field, getGameTime() + delay);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.hasTag("activated")) return;

	Vec2f vel = blob.getVelocity();
	s32 timer = blob.get_s32("bomb_timer") - getGameTime();

	if (timer < 0)
	{
		return;
	}

	if (timer > 30)
	{
		this.SetAnimation("default");
		this.animation.frame = this.animation.getFramesCount() * (1.0f - ((timer - 30) / 220.0f));
	}
	else
	{
		this.SetAnimation("shes_gonna_blow");
		this.animation.frame = this.animation.getFramesCount() * (1.0f - (timer / 30.0f));

		if (timer < 15 && timer > 0)
		{
			f32 invTimerScale = (1.0f - (timer / 15.0f));
			Vec2f scaleVec = Vec2f(1, 1) * (1.0f + 0.07f * invTimerScale * invTimerScale);
			this.ScaleBy(scaleVec);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this is hitterBlob)
	{
		this.set_s32("bomb_timer", 0);
	}

	if (isExplosionHitter(customData))
	{
		return damage; //chain explosion
	}

	return 0.0f;
}

void onDie(CBlob@ this)
{
	this.getSprite().SetEmitSoundPaused(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//special logic colliding with players
	if (blob.hasTag("player"))
	{
		const u8 hitter = this.get_u8("custom_hitter");

		//all water bombs collide with enemies
		if (hitter == Hitters::water)
			return blob.getTeamNum() != this.getTeamNum();

		//collide with shielded enemies
		return blob.getTeamNum() != this.getTeamNum();
	}

	string name = blob.getName();

	if (name == "fishy" || name == "food" || name == "steak" || name == "grain" || name == "heart" || name == "saw")
	{
		return false;
	}

	return true;
}

void onSetStatic(CBlob@ this, const bool isStatic)
{	
	if (!isStatic)
	{
		return;
	}

	CMap@ map = this.getMap();
	if (map is null) return;

	Vec2f pos = this.getPosition();
	f32 angle = this.getAngleDegrees();

	TileType above = map.getTile(pos).type;
	TileType under = map.getTile(pos + Vec2f(0, 8).RotateBy(angle)).type;

	bool can_lit = isTileExposure(above) && !isTileExposure(under);
	if (can_lit)
	{
		this.Tag("placed");
	}
	else
	{
		this.getShape().SetStatic(false);
		this.Tag("unstuck");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f p1)
{
	if (!solid || this.hasTag("dead"))
	{
		return;
	}

	CMap@ map = getMap();
	if (map is null) return;

	const f32 vellen = this.getOldVelocity().Length();
	const u8 hitter = this.get_u8("custom_hitter");
	if (vellen > 1.7f && p1 != Vec2f_zero && p1.x < map.tilemapwidth*8 && p1.y < map.tilemapheight*8)
	{
		Vec2f normal = this.getPosition() - p1;
		if (normal.Length() > 0.0f)
		{
			normal.Normalize();
			TileType tile = map.getTile(this.getPosition() - normal * 10).type;

			if (isTileSnow(tile))
			{
				Sound::Play("StepSnow"+(XORRandom(4)+1)+".ogg", this.getPosition(), 1.0f, 0.9f+XORRandom(21)*0.01f);
			}
			else
			{
				Sound::Play("/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f));
			}
		}
	}

	if (!isExplosionHitter(hitter) && !this.isAttached())
	{
		Boom(this);
		if (!this.hasTag("_hit_water") && blob !is null) //smack that mofo
		{
			this.Tag("_hit_water");
			Vec2f pos = this.getPosition();
			blob.Tag("force_knock");
		}
	}
}

void onAttach(CBlob@ this, CBlob@ blob, AttachmentPoint@ ap)
{
	this.set_f32("angle", 0);
	this.setAngleDegrees(0);
	this.getSprite().ResetTransform();
	this.getSprite().SetOffset(Vec2f_zero);
}