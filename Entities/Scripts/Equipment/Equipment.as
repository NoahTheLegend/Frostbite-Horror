#include "RunnerCommon.as"
#include "EquipmentCommon.as"

// Made by GoldenGuy 

void onInit(CBlob@ this)
{
	this.Tag("equipment support");

	this.addCommandID("equip_head");
	this.addCommandID("equip_torso");
	this.addCommandID("equip2_torso");
	this.addCommandID("equip_boots");
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu@ gridmenu)
{
	if (this.hasTag("dead")) return;
	const string name = this.getName();

	Vec2f MENU_POS = gridmenu.getUpperLeftPosition() + Vec2f(-96, 72);

	CGridMenu@ equipments = CreateGridMenu(MENU_POS, this, Vec2f(1, 3), "equipment");
	CGridMenu@ extraequipments = CreateGridMenu(MENU_POS+Vec2f(48, 0), this, Vec2f(1, 1), "equipment");

	string HeadImage = "Equipment.png";
	string TorsoImage = "Equipment.png";
	string Torso2Image = "Equipment.png";
	string BootsImage = "Equipment.png";

	int HeadFrame = 0;
	int TorsoFrame = 1;
	int Torso2Frame = 1;
	int BootsFrame = 2;

	if (this.get_string("equipment_head") != "")
	{
		HeadImage = this.get_string("equipment_head")+"_icon.png";
		HeadFrame = 0;
	}
	if (this.get_string("equipment_torso") != "")
	{
		TorsoImage = this.get_string("equipment_torso")+"_icon.png";
		TorsoFrame = 0;
	}
	if (this.get_string("equipment2_torso") != "")
	{
		Torso2Image = this.get_string("equipment2_torso")+"_icon.png";
		Torso2Frame = 0;
	}
	if (this.get_string("equipment_boots") != "")
	{
		BootsImage = this.get_string("equipment_boots")+"_icon.png";
		BootsFrame = 0;
	}

	if (equipments !is null)
	{
		equipments.SetCaptionEnabled(false);
		equipments.deleteAfterClick = false;

		if (this !is null)
		{
			CBitStream params;
			params.write_u16(this.getNetworkID());

			int teamnum = this.getTeamNum();
			if (teamnum > 6) teamnum = 7;
			AddIconToken("$headimage$", HeadImage, Vec2f(24, 24), HeadFrame, teamnum);
			AddIconToken("$torsoimage$", TorsoImage, Vec2f(24, 24), TorsoFrame, teamnum);
			AddIconToken("$bootsimage$", BootsImage, Vec2f(24, 24), BootsFrame, teamnum);

			CGridButton@ head = equipments.AddButton("$headimage$", "", this.getCommandID("equip_head"), Vec2f(1, 1), params);
			if (head !is null)
			{
				if (this.get_string("equipment_head") != "") head.SetHoverText("Unequip head gear\n");
				else head.SetHoverText("Equip head gear\n");
			}

			CGridButton@ torso = equipments.AddButton("$torsoimage$", "", this.getCommandID("equip_torso"), Vec2f(1, 1), params);
			if (torso !is null)
			{
				if (this.get_string("equipment_torso") != "") torso.SetHoverText("Unequip snow suit\n");
				else torso.SetHoverText("Equip snow suit\n");
			}

			CGridButton@ boots = equipments.AddButton("$bootsimage$", "", this.getCommandID("equip_boots"), Vec2f(1, 1), params);
			if (boots !is null)
			{
				if (this.get_string("equipment_boots") != "") boots.SetHoverText("Unequip boots\n");
				else boots.SetHoverText("Equip boots\n");
			}
		}
	}
	if (extraequipments !is null)
	{
		extraequipments.SetCaptionEnabled(false);
		extraequipments.deleteAfterClick = false;

		if (this !is null)
		{
			CBitStream params;
			params.write_u16(this.getNetworkID());

			int teamnum = this.getTeamNum();
			if (teamnum > 6) teamnum = 7;
			AddIconToken("$torsoimage$", Torso2Image, Vec2f(24, 24), TorsoFrame, teamnum);

			CGridButton@ torso = extraequipments.AddButton("$torsoimage$", "", this.getCommandID("equip2_torso"), Vec2f(1, 1), params);
			if (torso !is null)
			{
				if (this.get_string("equipment2_torso") != "") torso.SetHoverText("Unequip backpack\n");
				else torso.SetHoverText("Equip backpack\n");
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("equip_head") || cmd == this.getCommandID("equip_torso") || cmd == this.getCommandID("equip2_torso") || cmd == this.getCommandID("equip_boots"))
	{
		if (getGameTime() < this.get_u32("equipment_delay")) return;
		this.set_u32("equipment_delay", getGameTime()+5);

		u16 callerID;
		if (!params.saferead_u16(callerID)) return;
		CBlob@ caller = getBlobByNetworkID(callerID);
		if (caller is null) return;
		if (caller.get_string("equipment_torso") != "" && cmd == this.getCommandID("equip_torso"))
			removeTorso(caller, caller.get_string("equipment_torso"));
		else if (caller.get_string("equipment2_torso") != "" && cmd == this.getCommandID("equip2_torso"))
			remove2Torso(caller, caller.get_string("equipment2_torso"));
		else if (caller.get_string("equipment_boots") != "" && cmd == this.getCommandID("equip_boots"))
			removeBoots(caller, caller.get_string("equipment_boots"));
		else if (caller.get_string("equipment_head") != "" && cmd == this.getCommandID("equip_head"))
			removeHead(caller, caller.get_string("equipment_head"));

		CBlob@ item = caller.getCarriedBlob();
		if (item !is null)
		{
			string eqName = item.getName();
			if (getEquipmentType(item) == "head" && cmd == this.getCommandID("equip_head"))
			{
				addHead(caller, eqName);
				if (eqName == "default") 
					caller.set_f32(eqName+"_health", item.get_f32("health"));

				if (item.getQuantity() <= 1) item.server_Die();
				else item.server_SetQuantity(Maths::Max(item.getQuantity() - 1, 0));
			}
			else if (getEquipmentType(item) == "torso" && cmd == this.getCommandID("equip_torso") && eqName != "backpack")
			{
				addTorso(caller, eqName);
				if (eqName == "default")
					caller.set_f32(eqName+"_health", item.get_f32("health"));
				item.server_Die();
			}
			else if (getEquipmentType(item) == "torso" && cmd == this.getCommandID("equip2_torso"))
			{
				add2Torso(caller, eqName);
				if (eqName == "default")
					caller.set_f32(eqName+"_health", item.get_f32("health"));
				item.server_Die();
			}
			else if (getEquipmentType(item) == "boots" && cmd == this.getCommandID("equip_boots"))
			{
				addBoots(caller, eqName);
				if (eqName == "combatboots" || eqName == "carbonboots" || eqName == "wilmetboots") caller.set_f32(eqName+"_health", item.get_f32("health"));
				item.server_Die();
			}
			else if (caller.getSprite() !is null && caller.isMyPlayer()) caller.getSprite().PlaySound("NoAmmo.ogg", 1.0f);
		}

		caller.ClearMenus();
	}
}

void onDie(CBlob@ this)
{
    if (isServer())
	{
		string headname = this.get_string("equipment_head");
		string torsoname = this.get_string("equipment_torso");
		string torso2name = this.get_string("equipment2_torso");
		string bootsname = this.get_string("equipment_boots");

		//if (headname != "")
		//{
		//	server_CreateBlob(headname, this.getTeamNum(), this.getPosition());
		//}
		//if (torsoname != "")
		//{
		//	server_CreateBlob(torsoname, this.getTeamNum(), this.getPosition());
		//}
		//if (torso2name != "")
		//{
		//	server_CreateBlob(torso2name, this.getTeamNum(), this.getPosition());
		//}
		//if (bootsname != "")
		//{
		//	server_CreateBlob(bootsname, this.getTeamNum(), this.getPosition());
		//}
	}
}
