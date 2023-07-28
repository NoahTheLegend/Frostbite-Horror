#include "GenericButtonCommon.as"

void onInit(CBlob@ this)
{
	this.setPosition(this.getPosition()-Vec2f(0,24));
	this.getSprite().SetZ(-50.0f);

	this.CreateRespawnPoint("spawn", Vec2f(0.0f, -4.0f));
	this.Tag("spawn");

	this.inventoryButtonPos = Vec2f(-8, 12);

	// defaultnobuild
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{

}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{

}