
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
	Vec2f offset = Vec2f(-1, -2);
	f32 scale = 0.5f * cl_mouse_scale / 2;

	this.set_u8("current_alpha", v);
	GUI::DrawIcon("HumanCursor.png", 0, Vec2f(25, 27), mpos+offset, scale, SColor(Maths::Max(155,v), v, v, v));
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
