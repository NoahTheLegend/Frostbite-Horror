
#include "StatusCommon.as"

void onInit(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null) return;

    StatusEffect@[] setstats = status_collection;
    blob.set("StatusEffects", @setstats);
}

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null) return;
    
    StatusEffect@[]@ stats;
    if (!blob.get("StatusEffects", @stats)) return;

    for (u8 i = 0; i < stats.size(); i++)
    {
        StatusEffect@ stat = stats[i];
        if (stat is null) continue;

        printf(""+stat.name);
    }
}