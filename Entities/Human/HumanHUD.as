
//human HUD

#include "ActorHUDStartPos.as";
#include "HUDComponents.as";

const string iconsFilename = "HumanIcons.png";
const int slotsSize = 6;

// chat bubble & same for ingame chat
const u8 font0_size = 14;
const string font0_name = "RockwellMT";
const bool font0_antialiasing = true;

const u8 font1_size = 12;
const string font1_name = "CascadiaCodePL";
const bool font1_antialiasing = true;

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";

	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	blob.set_u8("gui_HUD_slots_width", slotsSize);
	blob.set_u8("current_alpha", 255);
	InitTemperatureComponent(blob);

	if (!GUI::isFontLoaded(font0_name+"_"+font0_size))
	{
		string font = CFileMatcher(font0_name+".ttf").getFirst();
		GUI::LoadFont(font0_name+"_"+font0_size, font, font0_size, font0_antialiasing);
	}

	if (!GUI::isFontLoaded(font1_name+"_"+font1_size))
	{
		string font = CFileMatcher(font1_name+".ttf").getFirst();
		GUI::LoadFont(font1_name+"_"+font1_size, font, font1_size, font1_antialiasing);
	}
}

void onTick(CBlob@ this)
{
	getHUD().HideCursor();
	UpdateTemperature(this);
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

void onRender(CSprite@ this)
{
	CBlob@ blob = getLocalPlayerBlob();
	if (blob is null) return;

	DrawTemperature(this);

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

bool mouseHover(Vec2f mpos, Vec2f tl, Vec2f br)
{
	return (mpos.x >= tl.x && mpos.x <= br.x
			&& mpos.y >= tl.y && mpos.y <= br.y);
}