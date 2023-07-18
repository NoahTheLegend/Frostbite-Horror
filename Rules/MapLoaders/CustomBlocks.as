
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
		tile_steel 		= 256,
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
		tile_steel_d8
	};
};

bool isTileSteel(u32 index)
{
	return index >= CMap::tile_steel && index <= CMap::tile_steel_d8;
}
