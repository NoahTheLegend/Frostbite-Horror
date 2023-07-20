// LoaderUtilities.as

#include "DummyCommon.as";
#include "ParticleSparks.as";
#include "Hitters.as";
#include "CustomBlocks.as";
#include "TileVariationLegacy.as";

const Vec2f[] directions =
{
	Vec2f(0, -8),
	Vec2f(0, 8),
	Vec2f(8, 0),
	Vec2f(-8, 0)
};

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	Tile tile = map.getTile(offset);
	if(isDummyTile(tile.type))
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	else if (isTileSnow(tile.type) || isTileSnowPile(tile.type)) // seemingly doesnt work?
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if (blob !is null) // doesnt pass
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
			// snow
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
			// snow pile
			case CMap::tile_snow_pile:
			case CMap::tile_snow_pile_v0:
			case CMap::tile_snow_pile_v1:
			case CMap::tile_snow_pile_v2:
			case CMap::tile_snow_pile_v3:
				return oldTileType + 2;

			case CMap::tile_snow_pile_v4:
			case CMap::tile_snow_pile_v5:
				return CMap::tile_empty;
			// steel
			case CMap::tile_steel:
				return CMap::tile_steel_d0;

			case CMap::tile_steel_v0:
			case CMap::tile_steel_v1:
			case CMap::tile_steel_v2:
			case CMap::tile_steel_v3:
			case CMap::tile_steel_v4:
			case CMap::tile_steel_v5:
			case CMap::tile_steel_v6:
			case CMap::tile_steel_v7:
			case CMap::tile_steel_v8:
			case CMap::tile_steel_v9:
			case CMap::tile_steel_v10:
			case CMap::tile_steel_v11:
			case CMap::tile_steel_v12:
			case CMap::tile_steel_v13:
			case CMap::tile_steel_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_steel_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);

				for (u8 i = 0; i < 4; i++)
				{
					steel_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_steel_d0;
			}

			case CMap::tile_steel_d0:
			case CMap::tile_steel_d1:
			case CMap::tile_steel_d2:
			case CMap::tile_steel_d3:
			case CMap::tile_steel_d4:
			case CMap::tile_steel_d5:
			case CMap::tile_steel_d6:
			case CMap::tile_steel_d7:
				return oldTileType + 1;

			case CMap::tile_steel_d8:
				return CMap::tile_empty;
			
			// elder bricks
			case CMap::tile_elderbrick:
			case CMap::tile_elderbrick_v0:
				return CMap::tile_elderbrick_d0;
			
			case CMap::tile_elderbrick_d0:
			case CMap::tile_elderbrick_d1:
			case CMap::tile_elderbrick_d2:
			case CMap::tile_elderbrick_d3:
				return oldTileType + 1;

			case CMap::tile_elderbrick_d4:
				return CMap::tile_ground_back;
			
			// polished stone
			case CMap::tile_polishedstone:
				return CMap::tile_polishedstone_d0;

			case CMap::tile_polishedstone_v0:
			case CMap::tile_polishedstone_v1:
			case CMap::tile_polishedstone_v2:
			case CMap::tile_polishedstone_v3:
			case CMap::tile_polishedstone_v4:
			case CMap::tile_polishedstone_v5:
			case CMap::tile_polishedstone_v6:
			case CMap::tile_polishedstone_v7:
			case CMap::tile_polishedstone_v8:
			case CMap::tile_polishedstone_v9:
			case CMap::tile_polishedstone_v10:
			case CMap::tile_polishedstone_v11:
			case CMap::tile_polishedstone_v12:
			case CMap::tile_polishedstone_v13:
			case CMap::tile_polishedstone_v14:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				map.server_SetTile(pos, CMap::tile_polishedstone_d0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);

				for (u8 i = 0; i < 4; i++)
				{
					polishedstone_Update(map, map.getTileWorldPosition(index) + directions[i]);
				}
				return CMap::tile_polishedstone_d0;
			}

			case CMap::tile_polishedstone_d0:
			case CMap::tile_polishedstone_d1:
			case CMap::tile_polishedstone_d2:
			case CMap::tile_polishedstone_d3:
			case CMap::tile_polishedstone_d4:
			case CMap::tile_polishedstone_d5:
				return oldTileType + 1;

			case CMap::tile_polishedstone_d6:
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
			else if (tile_old == CMap::tile_steel_d8)
				OnSteelTileDestroyed(map, index);
			else if (tile_old == CMap::tile_elderbrick_d4)
				OnElderBrickTileDestroyed(map, index);
			else if (tile_old == CMap::tile_polishedstone_d6)
				OnPolishedStoneTileDestroyed(map, index);

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
				map.SetTileSupport(index, 0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_snow_v0:
			case CMap::tile_snow_v1:
			case CMap::tile_snow_v2:
			case CMap::tile_snow_v3:
			case CMap::tile_snow_v4:
			case CMap::tile_snow_v5:
				map.SetTileSupport(index, 0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				break;

			case CMap::tile_snow_d0:
			case CMap::tile_snow_d1:
			case CMap::tile_snow_d2:
			case CMap::tile_snow_d3:
				map.SetTileSupport(index, 0);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				map.RemoveTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
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

			case CMap::tile_steel:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				steel_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);

				break;
			}

			case CMap::tile_steel_v0:
			case CMap::tile_steel_v1:
			case CMap::tile_steel_v2:
			case CMap::tile_steel_v3:
			case CMap::tile_steel_v4:
			case CMap::tile_steel_v5:
			case CMap::tile_steel_v6:
			case CMap::tile_steel_v7:
			case CMap::tile_steel_v8:
			case CMap::tile_steel_v9:
			case CMap::tile_steel_v10:
			case CMap::tile_steel_v11:
			case CMap::tile_steel_v12:
			case CMap::tile_steel_v13:
			case CMap::tile_steel_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;

			case CMap::tile_steel_d0:
			case CMap::tile_steel_d1:
			case CMap::tile_steel_d2:
			case CMap::tile_steel_d3:
			case CMap::tile_steel_d4:
			case CMap::tile_steel_d5:
			case CMap::tile_steel_d6:
			case CMap::tile_steel_d7:
			case CMap::tile_steel_d8:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnSteelTileHit(map, index);
				break;

			case CMap::tile_elderbrick:
				elderbrick_SetTile(map, pos);
				map.SetTileSupport(index, 255);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;
				
			case CMap::tile_elderbrick_v0:
				map.SetTileSupport(index, 255);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;

			case CMap::tile_elderbrick_d0:
			case CMap::tile_elderbrick_d1:
			case CMap::tile_elderbrick_d2:
			case CMap::tile_elderbrick_d3:
			case CMap::tile_elderbrick_d4:
				map.SetTileSupport(index, 255);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnElderBrickTileHit(map, index);
				break;

			case CMap::tile_polishedstone:
			{
				Vec2f pos = map.getTileWorldPosition(index);

				polishedstone_SetTile(map, pos);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag( index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 0.925f);

				break;
			}

			case CMap::tile_polishedstone_v0:
			case CMap::tile_polishedstone_v1:
			case CMap::tile_polishedstone_v2:
			case CMap::tile_polishedstone_v3:
			case CMap::tile_polishedstone_v4:
			case CMap::tile_polishedstone_v5:
			case CMap::tile_polishedstone_v6:
			case CMap::tile_polishedstone_v7:
			case CMap::tile_polishedstone_v8:
			case CMap::tile_polishedstone_v9:
			case CMap::tile_polishedstone_v10:
			case CMap::tile_polishedstone_v11:
			case CMap::tile_polishedstone_v12:
			case CMap::tile_polishedstone_v13:
			case CMap::tile_polishedstone_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);

				break;

			case CMap::tile_polishedstone_d0:
			case CMap::tile_polishedstone_d1:
			case CMap::tile_polishedstone_d2:
			case CMap::tile_polishedstone_d3:
			case CMap::tile_polishedstone_d4:
			case CMap::tile_polishedstone_d5:
			case CMap::tile_polishedstone_d6:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				map.RemoveTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
				OnPolishedStoneTileHit(map, index);
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

void steel_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_steel + steel_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		steel_Update(map, pos + directions[i]);
	}
}

u8 steel_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (isSteelTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void steel_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isSteelTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_steel+steel_GetMask(map,pos));
}

void OnSteelTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES );

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.95f);
		sparks(pos, 1, 1);
	}
}

void OnSteelTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("destroy_stone.ogg", pos, 1.0f, 0.9f);
	}
}

void elderbrick_SetTile(CMap@ map, Vec2f pos)
{
	Tile tile = map.getTile(pos);
	tile.dirt = 255;
	if (!map.isTileSolid(map.getTile(pos-Vec2f(0,8))) && !isTileCustomSolid(map.getTile(pos-Vec2f(0,8)).type))
		map.SetTile(map.getTileOffset(pos), CMap::tile_elderbrick_v0);
}

void OnElderBrickTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES );

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.825f);
		sparks(pos, 1, 1);
	}
}

void OnElderBrickTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("destroy_stone.ogg", pos, 1.0f, 0.75f);
	}
}


void polishedstone_SetTile(CMap@ map, Vec2f pos)
{
	map.SetTile(map.getTileOffset(pos), CMap::tile_polishedstone + polishedstone_GetMask(map, pos));

	for (u8 i = 0; i < 4; i++)
	{
		polishedstone_Update(map, pos + directions[i]);
	}
}

u8 polishedstone_GetMask(CMap@ map, Vec2f pos)
{
	u8 mask = 0;

	for (u8 i = 0; i < 4; i++)
	{
		if (isPolishedStoneTile(map, pos + directions[i])) mask |= 1 << i;
	}

	return mask;
}

void polishedstone_Update(CMap@ map, Vec2f pos)
{
	u16 tile = map.getTile(pos).type;
	if (isPolishedStoneTile(map, pos))
		map.SetTile(map.getTileOffset(pos),CMap::tile_polishedstone+polishedstone_GetMask(map,pos));
}

void OnPolishedStoneTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	map.RemoveTileFlag( index, Tile::LIGHT_PASSES );

	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("PickStone" + (1 + XORRandom(3)), pos, 1.0f, 0.95f);
		sparks(pos, 1, 1);
	}
}

void OnPolishedStoneTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);

		Sound::Play("destroy_wall.ogg", pos, 1.0f, 0.9f);
	}
}