
//human HUD

#include "/Entities/Common/GUI/ActorHUDStartPos.as";

const string iconsFilename = "HumanIcons.png";
const int slotsSize = 6;

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
	this.getBlob().set_u8("gui_HUD_slots_width", slotsSize);

	this.getBlob().set_u8("current_alpha", 255);

	getHUD().HideCursor();
	int id = Render::addScript(Render::layer_last, "HumanHUD.as", "RenderHumanCursor", 50000);
}

void ResetChecks()
{
	has_sharp = false;
	has_pickaxe = false;
	has_axe = false;
}

void onTick(CBlob@ this)
{
	ResetChecks();

	bool a1 = isAction(this);
	this.set_bool("a1", a1);

	u8 frame = getCursorFrame(this);
	this.set_u8("cursor_frame", frame);

	CInventory@ inv = this.getInventory();
	if (inv is null) return;
	Vec2f invsize = inv.getInventorySlots();
	
	for (u16 i = 0; i < invsize.x * invsize.y; i++)
	{
		CBlob@ b = inv.getItem(i);
		if (b is null || !b.hasTag("tool")) continue;

		if (b.hasTag("sharp")) has_sharp = true;
		else if (b.hasTag("pickaxe")) has_pickaxe = true;
		else if (b.hasTag("axe")) has_axe = true;
	}
}

bool has_sharp = false;
bool has_pickaxe = false;
bool has_axe = false;

void ManageCursors(CBlob@ this)
{
	if (getControls() is null) return;
	CMap@ map = getMap();
	if (map is null) return;

	Vec2f mpos = getControls().getInterpMouseScreenPos();
	Vec2f offset = Vec2f(-3, -2);

	f32 v = 255; // visibility
	
	u8 frame = 0;
	bool a1 = getControls().isKeyPressed(KEY_LBUTTON) || getControls().isKeyPressed(KEY_RBUTTON);

	if (this !is null)
	{
		frame = this.get_u8("cursor_frame");
		a1 = this.get_bool("a1");

		if (!getControls().isMenuOpened())
		{
			CGridMenu@ menu = getGridMenuByName("Recipes");
			if (menu is null)
			{
				const u8 map_luminance = map.getColorLight(this.getAimPos()).getLuminance();
				v = Maths::Lerp(this.get_u8("current_alpha"), map_luminance, 0.1f);
				this.set_u8("current_alpha", v);
			}
		}
	}
	
	f32 scale = getScaleFactor(frame) * cl_mouse_scale / 2;
	GUI::DrawIcon("HumanCursor.png", a1 ? frame+1 : frame, Vec2f(32, 32), mpos+offset, scale, SColor(Maths::Max(155,v), v, v, v));
}

u8 getCursorFrame(CBlob@ this)
{
	if (this.hasTag("carrying_sharp")) return 2;
	else if (this.hasTag("carrying_pickaxe")) return 4;
	else if (this.hasTag("carrying_axe")) return 6;

	if (getControls() is null) return 0;
	CMap@ map = getMap();
	if (map is null) return 0;
	Vec2f mpos = getControls().getInterpMouseScreenPos();

	CBlob@[] list;
	map.getBlobsAtPosition(mpos, @list);
	for (u16 i = 0; i < list.length; i++)
	{
		CBlob@ b = list[i];
		if (b is null) continue;

		if (has_sharp && useSharp(this, b)) return 2;
		else if (has_pickaxe && usePickaxe(this, b)) return 4;
		else if (has_axe && useAxe(this, b)) return 6;
	}

	return 0;
}

bool isAction(CBlob@ this)
{
	bool a1 = this.isKeyPressed(key_action1);
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null && ap.getOccupied() !is null && ap.getOccupied().get_bool("a1"))
		a1 = true;

	return a1;
}

bool useSharp(CBlob@ this, CBlob@ blob)
{
	return false;
}

bool usePickaxe(CBlob@ this, CBlob@ blob)
{
	return false;
}

bool useAxe(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ ap)
{
	if (attached !is null)
	{
		if (attached.hasTag("sharp")) this.Tag("carrying_sharp");
		else if (attached.hasTag("pickaxe")) this.Tag("carrying_pickaxe");
		else if (attached.hasTag("axe")) this.Tag("carrying_axe");
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ ap)
{
	if (detached !is null)
	{
		if (detached.hasTag("sharp")) this.Untag("carrying_sharp");
		else if (detached.hasTag("pickaxe")) this.Untag("carrying_pickaxe");
		else if (detached.hasTag("axe")) this.Untag("carrying_axe");
	}
}


f32 getScaleFactor(u8 frame)
{
	switch (frame)
	{
		case 0:
		case 1:
			return 0.5f;
		
		case 2:
		case 3:
			return 0.75f;
	}

	return 0.75f;
}

void RenderHumanCursor(int id)
{
	CBlob@ blob = getLocalPlayerBlob();
	ManageCursors(blob);
	if (blob is null) return;

	if (g_videorecording)
		return;

	CPlayer@ player = blob.getPlayer();

	// draw inventory

	Vec2f tl = getActorHUDStartPosition(blob, slotsSize);
	DrawInventoryOnHUD(blob, tl);

	// draw coins

	const int coins = player !is null ? player.getCoins() : 0;
	DrawCoinsOnHUD(blob, coins, tl, slotsSize - 2);

	// draw class icon

	GUI::DrawIcon(iconsFilename, 3, Vec2f(16, 32), tl + Vec2f(8 + (slotsSize - 1) * 40, -13), 1.0f);
}
