#include "CustomBlocks.as";

Tile getSurfaceTile(CBlob@ this)
{
    Tile empty = Tile();
    empty.type = -1;

    if (this is null) return empty;
    CMap@ map = getMap();
    if (map is null) return empty;

    return map.getTile(this.getPosition()+Vec2f(0, this.getRadius() + 4.0f));
}