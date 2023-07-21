
#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	this.inventoryButtonPos = Vec2f(0, 0);
	this.getCurrentScript().tickFrequency = 90;

	this.Tag("heavy weight");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getDistanceTo(this) <= 8.0f && canSeeButtons(this, forBlob);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return true;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable() && !blob.hasTag("flesh");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (this.getSprite() is null) return;
	this.getSprite().SetRelativeZ(-20.0f);
}

const string[] anims = {
	"red",
	"yellow",
	"greem"
};

void onInit(CSprite@ this)
{
	// Building
	CBlob@ blob = this.getBlob();
	this.SetZ(-20); 

	blob.addCommandID("sync");

	if (isServer())
	{
		blob.set_u8("anim", XORRandom(anims.length));
		blob.set_u8("frame", XORRandom(12));
	}

	if (getLocalPlayer() !is null && getLocalPlayer().isMyPlayer())
	{
		CBitStream params;
		params.write_bool(false);
		blob.SendCommand(blob.getCommandID("sync"));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync"))
	{
		bool init = params.read_bool();
		if (isServer() && !init)
		{
			CBitStream params;
			params.write_bool(true);
			params.write_u8(this.get_u8("anim"));
			params.write_u8(this.get_u8("frame")); // amount of frames here, since its serverside you gotta do it manually
			this.SendCommand(this.getCommandID("sync"), params);

			return;
		}
		if (isClient() && init)
		{
			u8 anim = params.read_u8();
			u8 frame = params.read_u8();

			if (anim >= anims.length) return;

			CSprite@ sprite = this.getSprite();
			if (sprite is null) return;

			VaryVisuals(sprite, anim, frame);
		}
	}
}

const u8 stickers_total = 7; // including 0

void VaryVisuals(CSprite@ this, u8 anim, u8 frame)
{
	this.SetAnimation(anims[anim]);
	this.SetFrameIndex(frame);
}
