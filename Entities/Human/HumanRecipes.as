#include "BuildBlock.as"
#include "Requirements.as"
#include "Costs.as"
#include "TeamIconToken.as"

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonHumanBlocks(BuildBlock[][]@ blocks, int team_num = 0, const string&in gamemode_override = "")
{
	InitCosts();
	CRules@ rules = getRules();

	string gamemode = rules.gamemode_name;
	if (gamemode_override != "")
	{
		gamemode = gamemode_override;
	}

	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", getTeamIcon("stone_door", "1x1StoneDoor.png", team_num, Vec2f(16, 8)), "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", getTeamIcon("wooden_door", "1x1WoodDoor.png", team_num, Vec2f(16, 8)), "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "bridge", getTeamIcon("bridge", "Bridge.png", team_num), "Trap Bridge\nOnly your team can stand on it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 1);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "building", "$building$", "Workshop\nStand in an open space\nand tap this button.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 1);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[0].insertAt(9, b);
	}
	{
		BuildBlock b(0, "workbench", "$workbench$", "Workbench\nCreate trampolines, saws, and more");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 1);
		b.buildOnGround = true;
		b.size.Set(32, 16);
		blocks[0].push_back(b);
	}

	BuildBlock[] page_1;
	blocks.push_back(page_1);
	{
		BuildBlock b(0, "wire", "$wire$", "Wire");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "elbow", "$elbow$", "Elbow");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "tee", "$tee$", "Tee");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "junction", "$junction$", "Junction");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "diode", "$diode$", "Diode");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "resistor", "$resistor$", "Resistor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "inverter", "$inverter$", "Inverter");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "transistor", "$transistor$", "Transistor");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "toggle", "$toggle$", "Toggle");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[1].push_back(b);
	}

	BuildBlock[] page_2;
	blocks.push_back(page_2);
	{
		BuildBlock b(0, "lever", "$lever$", "Lever");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "push_button", "$pushbutton$", "Button");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[2].push_back(b);
	}

	BuildBlock[] page_3;
	blocks.push_back(page_3);
	{
		BuildBlock b(0, "lamp", "$lamp$", "Lamp");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "emitter", "$emitter$", "Emitter");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "receiver", "$receiver$", "Receiver");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "magazine", "$magazine$", "Magazine");
		AddRequirement(b.reqs, "blob", "mat_stone", "Wood", 20);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "bolter", "$bolter$", "Bolter");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "obstructor", "$obstructor$", "Obstructor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "spiker", "$spiker$", "Spiker");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[3].push_back(b);
	}
}

ConfigFile@ openBlockBindingsConfig()
{
	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/BlockBindings.cfg"))
	{
		// write EmoteBinding.cfg to Cache
		cfg.saveFile("BlockBindings.cfg");

	}

	return cfg;
}

u8 read_block(ConfigFile@ cfg, string name, u8 default_value)
{
	u8 read_val = cfg.read_u8(name, default_value);
	return read_val;
}
