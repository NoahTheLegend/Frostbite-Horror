void onInit(CBlob@ this)
{
	if (!this.exists("eat sound")) this.set_string("eat sound", "/Eat.ogg");
    
    this.addCommandID("menu");

	this.addCommandID("open_canned");
    this.addCommandID("fill");
    
    this.addCommandID("eat_100");
    this.addCommandID("eat_50");
    this.addCommandID("eat_25");

	this.Tag("pushedByDoor");

    CSprite@ sprite = this.getSprite();
    if (sprite is null) return;

    AddIconToken("$icon_fill$", sprite.getConsts().filename, Vec2f(16, 16), this.get_u8("frame"));
	AddIconToken("$icon_eat100$", "EatIcons.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_eat50$", "EatIcons.png", Vec2f(16, 16), 1);
    AddIconToken("$icon_eat25$", "EatIcons.png", Vec2f(16, 16), 2);
    AddIconToken("$icon_opencanned$", "EatIcons.png", Vec2f(16, 16), 3);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
    if (ap !is null && ap.getOccupied() !is null && ap.getOccupied().isMyPlayer()) // caller doesnt work like this :\
    {
        CBitStream params;
        params.write_u16(ap.getOccupied().getNetworkID());
		caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("menu"), "");
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("menu"))
    {
        u16 callerid;
        if (!params.saferead_u16(callerid)) return;
        
        CBlob@ caller = getBlobByNetworkID(callerid);
        if (caller is null) return;

        Menu(this, caller);
    }
}

void Menu(CBlob@ this, CBlob@ caller)
{
	if (caller !is null && caller.isMyPlayer())
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());

        bool canned = this.hasTag("canned_food");
		CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, 3 + canned ? 1 : 0, "Options");

		if (menu !is null)
		{
			menu.deleteAfterClick = true;

            f32 hp = this.getHealth();
            f32 ihp = this.getInitialHealth();

            if (canned)
            {
                CGridButton@ btn = menu.AddButton("$icon_opencanned$", "Open", this.getCommandID("open_canned"), Vec2f(1, 1), params);
                btn.SetEnabled(false);
            }
            {
			    CGridButton@ btn = menu.AddButton("$icon_eat100$", "Eat whole", this.getCommandID("eat100"), Vec2f(1, 1), params);
			    if ((btn !is null && hp < ihp) || canned)
                    btn.SetEnabled(false);
            }
            {
                CGridButton@ btn = menu.AddButton("$icon_eat50$", "Eat half", this.getCommandID("eat50"), Vec2f(1, 1), params);
			    if ((btn !is null && hp < ihp*0.5f) || canned)
                    btn.SetEnabled(false);
            }
            {
                CGridButton@ btn = menu.AddButton("$icon_eat25$", "Eat quarter", this.getCommandID("eat25"), Vec2f(1, 1), params);
			    if ((btn !is null && hp < ihp*0.25f) || canned)
                    btn.SetEnabled(false);
            }
        }
	}
}