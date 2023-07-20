
#include "GenericButtonCommon.as"

string[] anims = {
	"light",
	"dark",
	"blue"
};

void onInit(CSprite@ this)
{
	// Building
	CBlob@ blob = this.getBlob();
	this.SetZ(-50); //-60 instead of -50 so sprite layers are behind ladders

	blob.addCommandID("sync");
	// TODO: share randomprops (except seed) to nearby lockers
	if (isServer())
	{
		blob.set_u8("anim", XORRandom(anims.length));
		blob.set_u8("frame", XORRandom(12));
		blob.set_u32("seed", XORRandom(696969));
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
			params.write_u32(this.get_u32("seed")); // seed for spritelayers
			this.SendCommand(this.getCommandID("sync"), params);

			return;
		}
		if (isClient() && init)
		{
			u8 anim = params.read_u8();
			u8 frame = params.read_u8();
			u32 seed = params.read_u32();

			if (anim >= anims.length) return;

			CSprite@ sprite = this.getSprite();
			if (sprite is null) return;

			sprite.SetAnimation(anims[anim]);
			sprite.SetFrameIndex(frame);

		}
	}
}

void onInit(CBlob@ this)
{
	this.getShape().getConsts().mapCollisions = false;
	AddIconToken("$store_inventory$", "InteractionIcons.png", Vec2f(32, 32), 28);
	this.inventoryButtonPos = Vec2f(0, 0);
	this.getCurrentScript().tickFrequency = 60;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getDistanceTo(this) <= 11.0f && canSeeButtons(this, forBlob);
}