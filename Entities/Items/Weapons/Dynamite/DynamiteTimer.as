#include "DynamiteCommon.as";
#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	if (!this.exists("bomb_timer"))
	{
		this.set_s32("bomb_timer", getGameTime());
	}
	f32 explRadius = 64.0f;
	if (!this.exists("explosive_radius"))
	{
		this.set_f32("explosive_radius", explRadius);
	}
	if (!this.exists("explosive_damage"))
	{
		this.set_f32("explosive_damage", 3.0f);
	}

	//use the bomb hitter
	if (!this.exists("custom_hitter"))
	{
		this.set_u8("custom_hitter", Hitters::bomb);
	}
	if (!this.exists("map_damage_radius"))
	{
		this.set_f32("map_damage_radius", 24.0f);
	}
	if (!this.exists("map_damage_ratio"))
	{
		this.set_f32("map_damage_ratio", 0.4f);
	}
	if (!this.exists("map_damage_raycast"))
	{
		this.set_bool("map_damage_raycast", true);
	}
}

void Explode(CBlob@ this)
{
	if (this.hasTag("exploding"))
	{
		if (this.exists("explosive_radius") && this.exists("explosive_damage"))
		{
			Explode(this, this.get_f32("explosive_radius"), this.get_f32("explosive_damage"));
		}
		else //default "bomb" explosion
		{
			Explode(this, 64.0f, 3.0f);
		}
		this.Untag("exploding");
	}

	BombFuseOff(this);
	this.getCurrentScript().runFlags |= Script::remove_after_this;
	if (this.getHealth() < 2.5f || this.hasTag("player"))
	{
		this.getSprite().Gib();
		this.Tag("dead");
		this.server_Die();
	}
	else
	{
		this.server_Hit(this, this.getPosition(), Vec2f_zero, this.get_f32("explosive_damage") * 1.5f, 0);
	}
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		if (ap.isKeyPressed(key_action2))
		{
			if (!this.hasTag("activated"))
			{
				this.set_s32("bomb_timer", getGameTime() + bomb_fuse);
				Activate(this);
			}

			this.getSprite().SetEmitSoundPaused(false);
		}
	}

	if (this.hasTag("unstuck"))
	{
		this.Untag("unstuck");
		this.getShape().SetStatic(false);
	}

	if (this.hasTag("placed"))
	{
		this.Untag("placed");

		if (this.getShape().isStatic() && !this.isAttached())
		{
			this.getSprite().SetOffset(Vec2f(0, 4));

			Activate(this);
		}
		else
		{
			this.getShape().SetStatic(false);
		}
	}
	if (!this.hasTag("activated")) return;

	if (!UpdateBomb(this))
	{
		Explode(this);
	}
}

void onDie(CBlob@ this)
{
	Explode(this);
}

// run the tick so we explode in inventory
void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.doTickScripts = true;
}