#include "CustomBlocks.as";

array<bool> tile_map();
const u8 max_inits_per_tick = 1;
const u8 max_length = 10;

void onInit(CRules@ this)
{
    Reset(this);
}

void onRestart(CRules@ this)
{
    Reset(this);
}

void Reset(CRules@ this)
{
    CMap@ map = getMap();
    if (map is null)
    {
        error("Could not update map matrix");
        return;
    }

    array<bool> new_tile_map(map.tilemapwidth*map.tilemapheight);
	tile_map = new_tile_map;
}

void onSetTile(CMap@ map, u32 index, TileType new_tile, TileType old_tile)
{
    if (getRules().hasTag("loading")) return;

    // add a separate bool hook to see which materials save temperature (room space)
    bool old_solid = false;
    //bool new_solid = false;
    if (isSolid(map, old_tile)) old_solid = true;
    //if (isCustomSolid(map, new_tile)) new_solid = true;

    //if (!old_solid || new_solid) return;
    if (!old_solid) return;

    flood_order.push_back(index);
}

u32[] flood_order = {};

void onTick(CRules@ this)
{
    CMap@ map = getMap();
    if (map is null) return;

    for (u16 i = 0; i < Maths::Min(max_inits_per_tick, flood_order.size()); i++)
    {
        Flood(map, flood_order[flood_order.length-(i+1)], max_length); // recursive-less
        flood_order.erase(flood_order.length-(i+1));
    }
}

void Flood(CMap@ map, u32 index, u8 length) // recursive-less version
{
    u32[] list;
    list.push_back(index);

    if (length == 0) return;

    while (list.size() != 0)
    {
        if (length == 0) return;
        u32 step = list[0];

        u32 up = step - map.tilemapwidth;
        if (FloodValidation(map, up))
            list.push_back(up);

        u32 right = step + 1;
        if (FloodValidation(map, right))
            list.push_back(right);

        u32 down = step + map.tilemapwidth;
        if (FloodValidation(map, down))
            list.push_back(down);

        u32 left = step - 1;
        if (FloodValidation(map, left))
            list.push_back(left);

        Vec2f pos = map.getTileWorldPosition(step);
        tile_map[step] = true;

        list.erase(0);
        length--;
    }
}

bool FloodValidation(CMap@ map, u32 index)
{
    return !tile_map[index] && !isTileExposure(map.getTile(index).type);
}

void onRender(CRules@ this) // debug
{
    if (tile_map.length == 0) return;
    CMap@ map = getMap();
    if (map is null) return;

    if (getControls() is null) return;
    if (!getControls().isKeyPressed(KEY_LSHIFT)) return;

    Vec2f pos = getControls().getMouseWorldPos()+Vec2f(8, 8);
    Vec2f area = Vec2f(10, 10);

    GUI::SetFont("MENU");

    for (u32 i = 0; i < area.x * area.y; i++)
    {
        Vec2f current_pos = pos - (area*4) + Vec2f(i%area.x * 8, Maths::Floor(Maths::Floor(i/area.x) * 8));
        Vec2f centralized_pos = Vec2f(Maths::Floor(current_pos.x/8)*8-4.0f, Maths::Floor(current_pos.y/8)*8-4.0f);
        Vec2f screen_pos = getDriver().getScreenPosFromWorldPos(centralized_pos);

        SColor color = SColor(125, 255, 25, 25);
        u32 offset = map.getTileOffset(centralized_pos);
        bool has_room = tile_map[offset];
        if (has_room)
        {
            color.set(125, 25, 255, 25);
        }

        GUI::DrawRectangle(screen_pos-Vec2f(4,4), screen_pos+Vec2f(4,4), color);
        if (i == 0) GUI::DrawTextCentered(offset+"", screen_pos-Vec2f(4,2), SColor(155, 255, 255, 0));
    }
}