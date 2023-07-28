
/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace CMap
{
	enum CustomTiles
	{
		tile_caution = tile_steel - 96,
		tile_caution_v0,
		tile_caution_v1,
		tile_caution_v2,

		tile_elderbrick = tile_steel - 80,
		tile_elderbrick_v0,
		tile_elderbrick_d0,
		tile_elderbrick_d1,
		tile_elderbrick_d2,
		tile_elderbrick_d3,
		tile_elderbrick_d4,

		tile_polishedstone = tile_steel - 64,
		tile_polishedstone_v0,
		tile_polishedstone_v1,
		tile_polishedstone_v2,
		tile_polishedstone_v3,
		tile_polishedstone_v4,
		tile_polishedstone_v5,
		tile_polishedstone_v6,
		tile_polishedstone_v7,
		tile_polishedstone_v8,
		tile_polishedstone_v9,
		tile_polishedstone_v10,
		tile_polishedstone_v11,
		tile_polishedstone_v12,
		tile_polishedstone_v13,
		tile_polishedstone_v14,
		tile_polishedstone_d0 = tile_polishedstone + 16,
		tile_polishedstone_d1,
		tile_polishedstone_d2,
		tile_polishedstone_d3,
		tile_polishedstone_d4,
		
		tile_bpolishedstone = tile_steel - 32,
		tile_bpolishedstone_v0,
		tile_bpolishedstone_v1,
		tile_bpolishedstone_v2,
		tile_bpolishedstone_v3,
		tile_bpolishedstone_v4,
		tile_bpolishedstone_v5,
		tile_bpolishedstone_v6,
		tile_bpolishedstone_v7,
		tile_bpolishedstone_v8,
		tile_bpolishedstone_v9,
		tile_bpolishedstone_v10,
		tile_bpolishedstone_v11,
		tile_bpolishedstone_v12,
		tile_bpolishedstone_v13,
		tile_bpolishedstone_v14,
		tile_bpolishedstone_d0 = tile_bpolishedstone + 16,
		tile_bpolishedstone_d1,
		tile_bpolishedstone_d2,
		tile_bpolishedstone_d3,
		tile_bpolishedstone_d4,

		tile_steel = 512,
		tile_steel_v0,
		tile_steel_v1,
		tile_steel_v2,
		tile_steel_v3,
		tile_steel_v4,
		tile_steel_v5,
		tile_steel_v6,
		tile_steel_v7,
		tile_steel_v8,
		tile_steel_v9,
		tile_steel_v10,
		tile_steel_v11,
		tile_steel_v12,
		tile_steel_v13,
		tile_steel_v14,
		tile_steel_d0 = tile_steel + 16,
		tile_steel_d1,
		tile_steel_d2,
		tile_steel_d3,
		tile_steel_d4,
		tile_steel_d5,
		tile_steel_d6,
		tile_steel_d7,
		tile_steel_d8,

		tile_bsteel = tile_steel + 32,
		tile_bsteel_v0,
		tile_bsteel_v1,
		tile_bsteel_v2,
		tile_bsteel_d0,
		tile_bsteel_d1,
		tile_bsteel_d2,
		tile_bsteel_d3,
		tile_bsteel_d4,

		tile_bglass_d0 = tile_bsteel + 15, // intended to be +15!
		tile_bglass = tile_bsteel + 16,
		tile_bglass_v0,
		tile_bglass_v1,
		tile_bglass_v2,
		tile_bglass_v3,
		tile_bglass_v4,
		tile_bglass_v5,
		tile_bglass_v6,
		tile_bglass_v7,
		tile_bglass_v8,
		tile_bglass_v9,
		tile_bglass_v10,
		tile_bglass_v11,
		tile_bglass_v12,
		tile_bglass_v13,
		tile_bglass_v14,

		tile_snow = tile_bglass + 16,
		tile_snow_v0,
		tile_snow_v1,
		tile_snow_v2,
		tile_snow_v3,
		tile_snow_v4,
		tile_snow_v5,
		tile_snow_d0,
		tile_snow_d1,
		tile_snow_d2,
		tile_snow_d3,

		tile_snow_pile = tile_snow + 16,
		tile_snow_pile_v0,
		tile_snow_pile_v1,
		tile_snow_pile_v2,
		tile_snow_pile_v3,
		tile_snow_pile_v4,
		tile_snow_pile_v5,


		tile_ice = tile_snow_pile + 16,
		tile_ice_v0,
		tile_ice_v1,
		tile_ice_v2,
		tile_ice_v3,
		tile_ice_v4,
		tile_ice_v5,
		tile_ice_v6,
		tile_ice_v7,
		tile_ice_v8,
		tile_ice_v9,
		tile_ice_v10,
		tile_ice_v11,
		tile_ice_v12,
		tile_ice_v13,
		tile_ice_v14,
		tile_ice_d0 = tile_ice + 16,
		tile_ice_d1,
		tile_ice_d2,
		tile_ice_d3,

		tile_snow_bricks = tile_ice + 32,
		tile_snow_bricks_d0,
		tile_snow_bricks_d1,
		tile_bsnow_bricks = tile_snow_bricks + 3,
		tile_bsnow_bricks_d0,
		tile_bsnow_bricks_d1
	};
};

bool isTileCustomSolid(u32 index)
{
	return isTileSteel(index) || isTilePolishedStone(index) || isTileCaution(index) || isTileSnow(index) || isTileIce(index) || isTileElderBrick(index);
}

bool isTileCaution(u32 index)
{
	return index >= CMap::tile_caution && index <= CMap::tile_caution_v2;
}

bool isTileSteel(u32 index)
{
	return index >= CMap::tile_steel && index <= CMap::tile_steel_d8;
}

bool isTileBackSteel(u32 index)
{
	return index >= CMap::tile_bsteel && index <= CMap::tile_bsteel_d4;
}

bool isBackSteelTile(CMap@ map, Vec2f pos) // required for getMask function
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bsteel && tile <= CMap::tile_bsteel_v2;
}

bool isSteelTile(CMap@ map, Vec2f pos) // required for getMask function
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_steel && tile <= CMap::tile_steel_v14;
}

bool isTileSnow(TileType tile)
{
	return tile >= CMap::tile_snow && tile <= CMap::tile_snow_d3;
}

bool isTileSnowPile(TileType tile)
{
	return tile >= CMap::tile_snow_pile && tile <= CMap::tile_snow_pile_v5;
}

bool isTileElderBrick(u32 index)
{
	return index >= CMap::tile_elderbrick && index <= CMap::tile_elderbrick_d4;
}

bool isTilePolishedStone(u32 index)
{
	return index >= CMap::tile_polishedstone && index <= CMap::tile_polishedstone_d4;
}

bool isPolishedStoneTile(CMap@ map, Vec2f pos) // required for getMask function
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_polishedstone && tile <= CMap::tile_polishedstone_v14;
}

bool isTileBackPolishedStone(u32 index)
{
	return index >= CMap::tile_bpolishedstone && index <= CMap::tile_bpolishedstone_d4;
}

bool isBackPolishedStoneTile(CMap@ map, Vec2f pos) // required for getMask function
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bpolishedstone && tile <= CMap::tile_bpolishedstone_v14;
}

bool isTileIce(u32 index)
{
	return index >= CMap::tile_ice && index <= CMap::tile_ice_d3;
}

bool isIceTile(CMap@ map, Vec2f pos) // required for getMask function
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_ice && tile <= CMap::tile_ice_v14;
}

bool isTileBackGlass(u32 index)
{
	return index >= CMap::tile_bglass_d0 && index <= CMap::tile_bglass_v14;
}

bool isBackGlassTile(CMap@ map, Vec2f pos) // required for getMask function
{
	u16 tile = map.getTile(pos).type;
	return tile >= CMap::tile_bglass && tile <= CMap::tile_bglass_v14;
}

bool isTileSnowBricks(u32 index)
{
	return index >= CMap::tile_snow_bricks && index <= CMap::tile_snow_bricks_d1;
}

bool isTileBackSnowBricks(u32 index)
{
	return index >= CMap::tile_bsnow_bricks && index <= CMap::tile_bsnow_bricks_d1;
}