// keep this script in cfg script order after scripts where you init corresponding variables and tags
#include "Hitters.as";
#include "Knocked.as";

void onInit(CBlob@ this)
{
    if (!this.exists("attack_delay")) this.set_u8("attack_delay", 30);
	if (!this.exists("damage")) this.set_f32("damage", 1.0f);
	if (!this.exists("knock_time")) this.set_u8("knock_time", 0);
	if (!this.exists("hitter")) this.set_u8("hitter", Hitters::sword);
    if (!this.exists("attack_types_amount")) this.set_u8("attack_types_amount", 1);

    AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}
}

void onTick(CBlob@ this)
{
    if (this.isAttached())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		if (holder is null) return;

        u8 attack_delay = this.get_u8("attack_delay");

        f32 next = this.get_u32("next_attack");
        f32 gt = getGameTime();
        f32 current_delay = Maths::Max(-5, next - gt);
        this.set_u8("current_delay", Maths::Max(0, current_delay));

        if (current_delay != -5) return; // compensate time for returning visuals into initial state

        const bool a1 = point.isKeyPressed(key_action1);
		
		if (getKnocked(holder) <= 0) // do not attack if we have a stun
		{		
			if (a1)
			{
				u8 team = holder.getTeamNum();
				
				HitInfo@[] hitInfos;
				if (getMap().getHitInfosFromArc(this.getPosition(), getAimAngle(this, holder), 30, 16, this, @hitInfos))
				{
					for (uint i = 0; i < hitInfos.length; i++)
					{
						CBlob@ blob = hitInfos[i].blob;
						if (blob !is null && (this.hasTag("hit_only_flesh") ? blob.hasTag("flesh") : true)
                            && (this.hasTag("hit_allies") ? true : blob.getTeamNum() != this.getTeamNum()))
						{
							SetKnocked(blob, this.get_u8("knock_time"));

							if (isServer())
							{
								holder.server_Hit(blob, blob.getPosition(), Vec2f(), this.get_f32("damage"), this.get_u8("hitter"), true);
							}
						}
					}
				}

				this.set_u32("next_attack", getGameTime() + attack_delay);
                this.set_u8("attack_type", XORRandom(this.get_u8("attack_types_amount")));
			}
		}
	}
}

f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
	return -(holder.getAimPos() - this.getPosition()).Angle();
}