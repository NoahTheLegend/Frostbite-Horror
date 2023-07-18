// LoaderUtilities.as

#include "DummyCommon.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	if(isDummyTile(map.getTile(offset).type))
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	return true;
}


TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if (map.getTile(index).type > 255)
	{
		switch(oldTileType)
		{
			case CMap::tile_snow:
			case CMap::tile_snow_v0:
			case CMap::tile_snow_v1:
			case CMap::tile_snow_v2:
			case CMap::tile_snow_v3:
			case CMap::tile_snow_v4:
			case CMap::tile_snow_v5:
				return CMap::tile_snow_d0;

			case CMap::tile_snow_d0:
			case CMap::tile_snow_d1:
			case CMap::tile_snow_d2:
				return oldTileType + 1;

			case CMap::tile_snow_d3:
				return CMap::tile_empty;

			case CMap::tile_snow_pile:
			case CMap::tile_snow_pile_v0:
			case CMap::tile_snow_pile_v1:
			case CMap::tile_snow_pile_v2:
			case CMap::tile_snow_pile_v3:
				return oldTileType + 2;

			case CMap::tile_snow_pile_v4:
			case CMap::tile_snow_pile_v5:
				return CMap::tile_empty;
		}
	}

	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	Vec2f pos = map.getTileWorldPosition(index);

	switch(tile_new)
	{
		case CMap::tile_empty:
		case CMap::tile_ground_back:
		{
			if (tile_old == CMap::tile_snow_d3 || tile_old == CMap::tile_snow_pile_v4 || tile_old == CMap::tile_snow_pile_v5)
				OnSnowTileDestroyed(map, index);

			if(isTileSnowPile(map.getTile(index-map.tilemapwidth).type) && map.tilemapwidth < index)
				map.server_SetTile(map.getTileWorldPosition(index-map.tilemapwidth), CMap::tile_empty);
			break;
		}
	}

	if (map.getTile(index).type > 255)
	{
		u32 id = tile_new;
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case CMap::tile_snow:
				if(isClient())
				{
					int add = index % 7;
					if (add > 0)
					map.SetTile(index, CMap::tile_snow + add);
				}
				map.SetTileSupport(index, 1);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_snow_v0:
			case CMap::tile_snow_v1:
			case CMap::tile_snow_v2:
			case CMap::tile_snow_v3:
			case CMap::tile_snow_v4:
			case CMap::tile_snow_v5:
				map.SetTileSupport(index, 1);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_snow_d0:
			case CMap::tile_snow_d1:
			case CMap::tile_snow_d2:
			case CMap::tile_snow_d3:
				map.SetTileSupport(index, 1);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				if(isClient()) OnSnowTileHit(map, index);
				break;

			case CMap::tile_snow_pile:
			case CMap::tile_snow_pile_v0:
			case CMap::tile_snow_pile_v1:
			case CMap::tile_snow_pile_v2:
			case CMap::tile_snow_pile_v3:
			case CMap::tile_snow_pile_v4:
			case CMap::tile_snow_pile_v5:
				if(tile_new > tile_old && isTileSnowPile(tile_old)) // if pile got smaller do particles
				{
					if(isClient()) OnSnowTileHit(map, index);
				}
				map.SetTileSupport(index, 0);
				map.AddTileFlag(index, Tile::LIGHT_SOURCE | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
		}
	}
}

void OnSnowTileHit(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		for (int i = 0; i < 3; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)
			: SColor(255, 110, 100, 93);
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);
		}
		Sound::Play("dig_dirt" + (1 + XORRandom(3)), pos, 0.80f, 1.30f);
	}
}

void OnSnowTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		for (int i = 0; i < 15; i++)
		{
			Vec2f vel = getRandomVelocity( 0.6f, 2.0f, 180.0f);
			vel.y = -Maths::Abs(vel.y)+Maths::Abs(vel.x)/4.0f-2.0f-float(XORRandom(100))/100.0f;
			SColor color = (XORRandom(10) % 2 == 1) ? SColor(255, 57, 51, 47)
			: SColor(255, 110, 100, 93);
			ParticlePixel(pos+Vec2f(4, 0), vel, color, true);
		}
		ParticleAnimated("Smoke.png", pos+Vec2f(4, 0),
		Vec2f(0, 0), 0.0f, 1.0f, 3, 0.0f, false);
		Sound::Play("destroy_dirt.ogg", pos, 0.80f, 1.30f);
	}
}