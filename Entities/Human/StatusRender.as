
#include "StatusCommon.as"

void onInit(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null) return;

    StatusEffect@[] setstats = status_collection;
    blob.set("StatusEffects", @setstats);
}

const int sw = getDriver().getScreenWidth();
const int sh = getDriver().getScreenHeight();
const Vec2f slot_area_base = Vec2f(32, 32);
const Vec2f pane_pos = Vec2f(sw/2, sh - slot_area_base.x * 2);
const u8 grid_width = 5;

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null) return;
    
    StatusEffect@[]@ stats;
    if (!blob.get("StatusEffects", @stats)) return;

    for (u8 i = 0; i < 5; i++)
    {
        StatusEffect@ stat = stats[0];
        if (stat is null) continue;

        Vec2f slot = Vec2f(stat.gap, stat.gap) + slot_area_base;
        f32 offset = (slot.x * grid_width) / 2;
        f32 align = slot.x/4;

        Vec2f pos = Vec2f(pane_pos) - Vec2f(offset + align, 0) + Vec2f(slot.x * i, 0);
        GUI::DrawIcon(stat.icon, stat.frame, stat.size, pos, stat.scale);
    }
}