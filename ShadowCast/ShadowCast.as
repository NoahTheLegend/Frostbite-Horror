#include "ShadowCastHooks.as"
#include "CustomBlocks.as";

void onInit(CRules@ this)
{
    if(isClient())
	{
		this.set_s32("render_id", -1);
    }
    
    onReload(this);
}

SMaterial material;
bool texture_added = false; // thanks vamist

void onReload(CRules@ this)
{
    print("-------SHADOWCAST INIT-------");
    // set up hooks
    MAP_LOAD_CALLBACK@ map_load_func = @onMapLoad;
    this.set("MAP_LOAD_CALLBACK", @map_load_func);

    SET_TILE_CALLBACK@ set_tile_func = @onSetTile;
    this.set("SET_TILE_CALLBACK", @set_tile_func);
    //since we just created it that means map didnt called it, call it ourselves
    onMapLoad(getMap().tilemapwidth, getMap().tilemapheight);

    if(isClient())
	{
		int id = this.get_s32("render_id");
		if(id != -1) Render::RemoveScript(id);

        id = Render::addScript(Render::layer_postworld, getCurrentScriptName(), "Render", 0);
		this.set_s32("render_id", id);

        material.SetFlag(SMaterial::COLOR_MASK, true);
        material.SetFlag(SMaterial::COLOR_MATERIAL, true);
        material.SetFlag(SMaterial::LIGHTING, false);
        material.SetFlag(SMaterial::ZBUFFER, true);
        material.SetFlag(SMaterial::ZWRITE_ENABLE, false);
        material.SetFlag(SMaterial::FRONT_FACE_CULLING, false);
        material.SetFlag(SMaterial::BACK_FACE_CULLING, true);
        material.SetFlag(SMaterial::BLEND_OPERATION, true);
        material.SetFlag(SMaterial::FOG_ENABLE, false);
        material.SetFlag(SMaterial::TEXTURE_WRAP, false);
        //material.SetColorMask(SMaterial::RGB);
        material.SetMaterialType(SMaterial::LIGHTMAP_LIGHTING);
        material.SetBlendOperation(SMaterial::ADD);

       // material.SetBlendOperation(SMaterial::SUBTRACT);
        /*material.DisableAllFlags();
        material.SetFlag(SMaterial::COLOR_MASK, false);
        material.SetFlag(SMaterial::COLOR_MATERIAL, false);
        material.SetFlag(SMaterial::BLEND_OPERATION, false);
		material.SetFlag(SMaterial::ZBUFFER, false);
		material.SetFlag(SMaterial::ZWRITE_ENABLE, true);
		material.SetFlag(SMaterial::BACK_FACE_CULLING, false);
		material.SetFlag(SMaterial::FOG_ENABLE, false);
		material.SetMaterialType(SMaterial::SOLID);
        material.SetColorMask(SMaterial::ALL);
        material.SetColorMaterial(SMaterial::DIFFUSE_AND_AMBIENT);*/
        //material.SetBlendOperation(SMaterial::NONE);

        if(!texture_added)
        {
            texture_added = true;
            material.AddTexture("shadow_cast.png");
        }
	}
}

int CHUNK_SIZE = 16;
u8[] tile_nums;
bool[] solids;
bool solid_map;
ShadowChunk[] chunks;

int map_size;
int tile_update_per_tick = 5000;
int chunk_update_per_tick = 16;
int last_index;
bool full_upadate_needed;
bool chunk_update;

int[] tiles_to_update;

void onMapLoad(int width, int height)
{
    map_size = width * height;
    full_upadate_needed = true;
    chunk_update = false;
    last_index = 0;

    tile_nums.clear();
    tile_nums = u8[](map_size);
    solids.clear();
    solids = bool[](map_size);
    solid_map = false;
    tiles_to_update.clear();

    //print("tile_nums: " + tile_nums.size());
}

void onSetTile(int offset, uint16 tiletype)
{
    solids[offset] = isSolid(getMap(), tiletype);
    //print("solids[offset]: "+ (solids[offset] ? "true" : "false"));
    tiles_to_update.push_back(offset);
}

void onTick(CRules@ this)
{
    //CCamera@ cam = getCamera();
    //cam.targetDistance = 1;
    if(full_upadate_needed)
    {
        CMap@ map = getMap();
        if(!chunk_update)
        {
            if(!solid_map)
            {
                for(int i = 0; i < map_size; i++)
                {
                    TileType t = map.getTile(i).type;
                    solids[i] = isSolidNotIce(map, t) || !map.hasTileFlag(i, Tile::LIGHT_PASSES);
                }
                solid_map = true;
            }
            int max_index = last_index + tile_update_per_tick;
            if(max_index >= map_size)
            {
                chunk_update = true;
                max_index = map_size;
            }
            print("max_index: " + max_index);
            for(int i = last_index; i < max_index; i++)
            {
                UpdateTileNum(map, i);
            }
            last_index += tile_update_per_tick;
        }
        else
        {
            chunks.clear();
            
            int x_max = Maths::Ceil(float(map.tilemapwidth) / float(CHUNK_SIZE));
            int y_max = Maths::Ceil(float(map.tilemapheight) / float(CHUNK_SIZE));
            
            int x_size = 16;
            int y_size = 16;

            for(int y = 0; y < y_max; y++)
            {
                x_size = 16;
                if(y == y_max - 1)
                {
                    y_size = map.tilemapheight - y * CHUNK_SIZE;
                }
                for(int x = 0; x < x_max; x++)
                {
                    if(x == x_max - 1)
                    {
                        x_size = map.tilemapwidth - x * CHUNK_SIZE;
                    }

                    ShadowChunk chunk = ShadowChunk(Vec2f(x * CHUNK_SIZE, y * CHUNK_SIZE), Vec2f(x_size, y_size));
                    chunks.push_back(chunk);
                }
            }
            chunk_update = false;
            full_upadate_needed = false;
        }
    }
    else
    {
        int chunks_updated = 0;
        for(int i = 0; i < chunks.size(); i++)
        {
            if(chunks_updated >= chunk_update_per_tick)
                break;

            ShadowChunk@ chunk = chunks[i];
            if(chunk.update_needed)
            {
                if(chunk.onScreen())
                {
                    chunk.on_screen = true;
                    chunk.UpdateMesh();
                    chunks_updated++;
                }
                else
                    chunk.on_screen = false;
            }
        }

        if(tiles_to_update.size() > 0)
        {
            CMap@ map = getMap();
            for(int i = 0; i < tiles_to_update.size(); i++)
            {
                int offset = tiles_to_update[i];
                UpdateTileNum(map, offset);

                int[] dirs = {-map.tilemapwidth-1, -map.tilemapwidth, -map.tilemapwidth+1, -1, 1, map.tilemapwidth-1, map.tilemapwidth, map.tilemapwidth+1};
                for(int i = 0; i < dirs.size(); i++)
                {
                    int n_offset = offset + dirs[i];
                    if(!inMap(map, n_offset))
                        continue;
                    UpdateTileNum(map, n_offset);
                    int chunk_x = Maths::Floor((n_offset % map.tilemapwidth) / CHUNK_SIZE);
                    int chunk_y = Maths::Floor((n_offset / map.tilemapwidth) / CHUNK_SIZE);
                    //print("chunk_x: " + chunk_x + " chunk_y: " + chunk_y);
                    int x_max = Maths::Ceil(float(map.tilemapwidth) / float(CHUNK_SIZE));
                    //print("x_max: " + x_max);
                    int chunk_offset = chunk_y * x_max + chunk_x;
                    if(chunk_offset < chunks.size())
                    {
                        ShadowChunk@ chunk = chunks[chunk_y * x_max + chunk_x];
                        chunk.update_needed = true;
                    }
                }
            }
            tiles_to_update.clear();
        }
    }
}

// 0,0,0
// 0,t,0  ==  00000000 our u8
// 0,0,0

void UpdateTileNum(CMap@ map, int offset)
{
    int num = 0;
    /*if(!map.hasTileFlag(offset, Tile::SOLID))
    {
        tile_nums[offset] = 0;
        solids[offset] = false;
        return;
    }
    solids[offset] = true;

    
    int pos = offset - map.tilemapwidth - 1; // top left
    if(inMap(map, pos))
        if(map.hasTileFlag(pos, Tile::SOLID))
            num |= 128;
    
    pos = offset - map.tilemapwidth; // top mid
    if(inMap(map, pos))
        if(map.hasTileFlag(pos, Tile::SOLID))
            num |= 64;
    
    pos = offset - map.tilemapwidth + 1; // top right
    if(inMap(map, pos))
        if(map.hasTileFlag(pos, Tile::SOLID))
            num |= 32;
    
    pos = offset - 1; // left
    if(inMap(map, pos))
        if(map.hasTileFlag(pos, Tile::SOLID))
            num |= 16;
    
    pos = offset + 1; // right
    if(inMap(map, pos))
        if(map.hasTileFlag(pos, Tile::SOLID))
            num |= 8;
    
    pos = offset + map.tilemapwidth - 1; // bottom left
    if(inMap(map, pos))
        if(map.hasTileFlag(pos, Tile::SOLID))
            num |= 4;
    
    pos = offset + map.tilemapwidth; // bottom mid
    if(inMap(map, pos))
        if(map.hasTileFlag(pos, Tile::SOLID))
            num |= 2;
    
    pos = offset + map.tilemapwidth + 1; // bottom right
    if(inMap(map, pos))
        if(map.hasTileFlag(pos, Tile::SOLID))
            num |= 1;*/

    if(!solids[offset])
    {
        tile_nums[offset] = 0;
        return;
    }

    
    int pos = offset - map.tilemapwidth - 1; // top left
    if(inMap(map, pos))
        if(solids[pos])
            num |= 128;
    
    pos = offset - map.tilemapwidth; // top mid
    if(inMap(map, pos))
        if(solids[pos])
            num |= 64;
    
    pos = offset - map.tilemapwidth + 1; // top right
    if(inMap(map, pos))
        if(solids[pos])
            num |= 32;
    
    pos = offset - 1; // left
    if(inMap(map, pos))
        if(solids[pos])
            num |= 16;
    
    pos = offset + 1; // right
    if(inMap(map, pos))
        if(solids[pos])
            num |= 8;
    
    pos = offset + map.tilemapwidth - 1; // bottom left
    if(inMap(map, pos))
        if(solids[pos])
            num |= 4;
    
    pos = offset + map.tilemapwidth; // bottom mid
    if(inMap(map, pos))
        if(solids[pos])
            num |= 2;
    
    pos = offset + map.tilemapwidth + 1; // bottom right
    if(inMap(map, pos))
        if(solids[pos])
            num |= 1;
    
    tile_nums[offset] = num;
}

bool inMap(CMap@ map, int offset)
{
    return offset >= 0 && offset < map.tilemapwidth * map.tilemapheight;
}

class ShadowChunk
{
    SMesh mesh;
    Vec2f world_pos;
    Vec2f world_size;
    Vec2f pos;
    Vec2f size;
    bool update_needed;
    bool empty;
    bool on_screen;

    ShadowChunk(Vec2f _pos, Vec2f _size)
    {
        pos = _pos;
        world_pos = _pos * 8;
        size = _size;
        world_size = _size * 8;
        update_needed = true;
        empty = true;
        on_screen = false;

        mesh.SetHardwareMapping(SMesh::STATIC);
    }

    void UpdateMesh()
    {
        Vec2f pos_end = pos+size;

        mesh.Clear();

        Vertex[] verts;
        uint16[] indices;

        for(int y = pos.y; y < pos_end.y; y++)
        {
            for(int x = pos.x; x < pos_end.x; x++)
            {
                int index = y * getMap().tilemapwidth + x;
                //print("index: "+index);
                if(!solids[index])
                    continue;
                int num = tile_nums[index];
                if(num == 255) // fully ocluded
                    continue;
                
                AddFaces(@verts, @indices, x, getMap().tilemapheight-y-getMap().tilemapheight, num);
            }
        }

        if(verts.size() == 0)
        {
            update_needed = false;
            empty = true;
            return;
        }

        empty = false;

        mesh.SetVertex(verts);
        mesh.SetIndices(indices);
        mesh.BuildMesh();
        
        update_needed = false;
    }

    void AddFaces(Vertex[]@ verts, uint16[]@ indices, int x, int y, int num)
    {
        // 0,0,0
        // 0,t,0  ==  00000000 our u8
        // 0,0,0

        // down face
        if(num & 0b00011111 == 0b00011111 || ~num & 0b00000010 == 0b00000010 || num & 0b00011000 == 0b00011000)
        {
            verts.push_back(Vertex(x-0.25, y-1, NEAR_PLANE,  1, 0, color_white));
            verts.push_back(Vertex(x,      y-1, FAR_PLANE,   1, 1, color_white));
            verts.push_back(Vertex(x+1,    y-1, FAR_PLANE, 0, 1, color_white));
            verts.push_back(Vertex(x+1.25, y-1, NEAR_PLANE,0, 0, color_white));
            AddFaceIndices(@indices, verts.size());
        }

        // up face
        if(num & 0b11111000 == 0b11111000 || ~num & 0b01000000 == 0b01000000 || num & 0b00011000 == 0b00011000)
        {
            verts.push_back(Vertex(x, y, FAR_PLANE,     0, 1, color_white));
            verts.push_back(Vertex(x-0.25, y, NEAR_PLANE,    0, 0, color_white));
            verts.push_back(Vertex(x+1.25, y, NEAR_PLANE,  1, 0, color_white));
            verts.push_back(Vertex(x+1, y, FAR_PLANE,   1, 1, color_white));
            AddFaceIndices(@indices, verts.size());
        }

        // left face
        if(num & 0b11010110 == 0b11010110 || ~num & 0b00010000 == 0b00010000 || num & 0b01000010 == 0b01000010)
        {
            verts.push_back(Vertex(x, y-1.25, NEAR_PLANE, 0, 0, color_white));
            verts.push_back(Vertex(x, y+0.25, NEAR_PLANE, 1, 0, color_white));
            verts.push_back(Vertex(x, y, FAR_PLANE, 1, 1, color_white));
            verts.push_back(Vertex(x, y-1, FAR_PLANE, 0, 1, color_white));
            AddFaceIndices(@indices, verts.size());
        }

        // right face
        if(num & 0b01101011 == 0b01101011 || ~num & 0b00001000 == 0b00001000 || num & 0b01000010 == 0b01000010)
        {
            verts.push_back(Vertex(x+1, y-1, FAR_PLANE, 1, 1, color_white));
            verts.push_back(Vertex(x+1, y, FAR_PLANE, 0, 1, color_white));
            verts.push_back(Vertex(x+1, y+0.25, NEAR_PLANE, 0, 0, color_white));
            verts.push_back(Vertex(x+1, y-1.25, NEAR_PLANE, 1, 0, color_white));
            AddFaceIndices(@indices, verts.size());
        }
    }

    void AddFaceIndices(uint16[]@ indices, int size)
    {
        indices.push_back(size - 4);
        indices.push_back(size - 3);
        indices.push_back(size - 2);
        indices.push_back(size - 4);
        indices.push_back(size - 2);
        indices.push_back(size - 1);
    }

    bool onScreen()
    {
        Driver@ driver = getDriver();
        Vec2f screen_pos = driver.getScreenPosFromWorldPos(world_pos);
        Vec2f screen_pos_end = driver.getScreenPosFromWorldPos(world_pos + world_size);

        // check if at least part of rectangle is in screen bounds 
        return (screen_pos_end.x >= 0 && screen_pos_end.y >= 0) || (screen_pos.x <= driver.getScreenWidth() && screen_pos.y <= driver.getScreenHeight()); // hmm
    }

    void Render()
    {
        if(!empty && on_screen)
        {
            mesh.RenderMesh();
        }
    }
}

const float FAR_PLANE = 10.0f;
const float NEAR_PLANE = 0.0f;
bool enable = false;
bool rshift = false;

void Render(int id)
{
    CControls@ controls = getControls();
    if (controls !is null)
    {
        if (controls.isKeyPressed(KEY_RSHIFT))
        {
            if (!rshift)
            {
                enable = !enable;
                rshift = true;
            }
        }
        else rshift = false;
    }  
    if (!enable) return;

	Render::ClearZ();
    material.SetVideoMaterial();
    float[] proj;
    Matrix::MakePerspective(proj, Maths::Pi/2.0f, float(getScreenWidth()) / float(getScreenHeight()), 0.001f, 10.0f);
    Render::SetProjectionTransform(proj);
    
    CCamera@ cam = getCamera();
    
    // i stole most of this dogshit from engine, i have no idea what it does now, but at some point i did
    float resolution_factor = Maths::Max(float(getScreenWidth()) / 1280.0f, float(getScreenHeight()) / 720.0f);
	float dist = (0.5f)/resolution_factor;
    float zoooom = (FAR_PLANE * 2.0f) / float(getScreenHeight());
    float fDynaDistance = cam.targetDistance * resolution_factor;
    zoooom /= ((0.5) / fDynaDistance);

    float[] model;
    Matrix::MakeIdentity(model);
    Vec2f cam_pos = cam.getPosition();
    //if (getLocalPlayerBlob() !is null)
    //    cam_pos = getLocalPlayerBlob().getInterpolatedPosition();
    Matrix::SetScale(model, zoooom*8, zoooom*8, 1);
    Render::SetModelTransform(model);

    

    float[] view;
    Matrix::MakeIdentity(view);
    Matrix::SetTranslation(view, -cam_pos.x*zoooom, cam_pos.y*zoooom, 0);
    Render::SetViewTransform(view);
    
    if(!full_upadate_needed && chunks.size() > 0)
    {
        for(int i = 0; i < chunks.size(); i++)
        {
            chunks[i].Render();
        }
    }
}