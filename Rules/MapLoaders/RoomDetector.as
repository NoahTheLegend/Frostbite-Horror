#include "CustomBlocks.as";

u8 delay_marking = 0;
array<bool> tile_map();

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
    if (delay_marking != 0) return;
    if (getRules().hasTag("loading")) return;

    // add a separate bool hook to see which materials save temperature (room space)
    bool old_solid = false;
    //bool new_solid = false;
    if (map.isTileSolid(old_tile) || isTileCustomSolid(old_tile)) old_solid = true;
    //if (map.isTileSolid(new_tile) || isTileCustomSolid(new_tile)) new_solid = true;

    //if (!old_solid || new_solid) return;
    if (!old_solid) return;

	Vec2f pos = map.getTileWorldPosition(index);
    //Flood(map, true, index, old_tile, 10);

    Flood(map, index, old_tile, 10); // recursive-less
}

//void Flood(CMap@ map, bool init, u32 index, TileType oldtile, u8 length)
//{
//    if (length == 0) return;
//    
//    if ((init || map.getTile(index).type == oldtile) && !tile_map[index])
//    {
//        Vec2f pos = map.getTileWorldPosition(index);
//        map.server_tile_new(pos, CMap::tile_empty);
//
//        tile_map[index] = true;
//        Flood(map, false, index - map.tilemapwidth, oldtile, length - 1);
//        Flood(map, false, index + 1, oldtile, length - 1);
//        Flood(map, false, index - 1, oldtile, length - 1);
//        Flood(map, false, index + map.tilemapwidth, oldtile, length - 1);
//    }
//}

void onTick(CRules@ this)
{
    if (delay_marking > 0) delay_marking--;
    if (remove_order.size() != 0) delay_marking = 1;

    for (u16 i = 0; i < remove_order.size(); i++)
    {
        getMap().server_SetTile(remove_order[i], CMap::tile_empty);
    }

    remove_order = array<Vec2f>();
}

Vec2f[] remove_order = {};

void Flood(CMap@ map, u32 index, TileType oldtile, u8 length) // recursive-less version
{
    u32[] list;
    list.push_back(index);

    if (length == 0) return;

    while (list.size() != 0)
    {
        if (length == 0) return;
        u32 step = list[0];

        u32 up = step - map.tilemapwidth;
        if (FloodValidation(map, up, oldtile))
            list.push_back(up);

        u32 right = step + 1;
        if (FloodValidation(map, right, oldtile))
            list.push_back(right);

        u32 down = step + map.tilemapwidth;
        if (FloodValidation(map, down, oldtile))
            list.push_back(down);

        u32 left = step - 1;
        if (FloodValidation(map, left, oldtile))
            list.push_back(left);

        Vec2f pos = map.getTileWorldPosition(step);
        //map.server_tile_new(pos, CMap::tile_empty);
        remove_order.push_back(pos);
        tile_map[step] = true;

        list.erase(0);
        length--;
    }
}

bool FloodValidation(CMap@ map, u32 index, TileType oldtile)
{
    return !tile_map[index] && map.getTile(index).type == oldtile;
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