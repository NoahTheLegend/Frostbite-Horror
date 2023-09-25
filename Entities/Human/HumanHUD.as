
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

void ManageCursors(CBlob@ this)
{
	if (getControls() is null) return;
	CMap@ map = getMap();
	if (map is null) return;

	f32 v = 255;
	if (!getControls().isMenuOpened())
	{
		CGridMenu@ menu = getGridMenuByName("Recipes");
		if (menu is null)
		{
			const u8 map_luminance = map.getColorLight(this.getAimPos()).getLuminance();
			v = Maths::Lerp(this.get_u8("current_alpha"), map_luminance, 0.1f);
		}
	}

	Vec2f mpos = getControls().getInterpMouseScreenPos();
	Vec2f offset = Vec2f(-3, -2);

	u8 frame = getCursorFrame(this, mpos);
	f32 scale = getScaleFactor(frame) * cl_mouse_scale / 2;

	bool a1 = this.isKeyPressed(key_action1);
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null && ap.getOccupied() !is null && ap.getOccupied().get_bool("a1"))
		a1 = true;

	this.set_u8("current_alpha", v);
	GUI::DrawIcon("HumanCursor.png", a1 ? frame+1 : frame, Vec2f(32, 32), mpos+offset, scale, SColor(Maths::Max(155,v), v, v, v));
}

u8 getCursorFrame(CBlob@ this, Vec2f mpos)
{
	if (this.hasTag("carrying_sharp")) return 2;
	return 0;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ ap)
{
	if (attached !is null)
	{
		if (attached.hasTag("sharp")) this.Tag("carrying_sharp");
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ ap)
{
	if (detached !is null)
	{
		if (detached.hasTag("sharp")) this.Untag("carrying_sharp");
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
	if (blob is null || !blob.isMyPlayer()) return;
	ManageCursors(blob);

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
