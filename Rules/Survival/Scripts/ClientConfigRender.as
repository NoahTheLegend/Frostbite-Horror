#define CLIENT_ONLY

#include "ClientVars.as";
#include "ClientConfig.as";

void onInit(CRules@ this)
{
    if (getLocalPlayer() !is null)
	{
        // init the class
        ClientVars setvars();
	    this.set("ClientVars", @setvars);

        bool vars_loaded = false;
		ClientVars@ vars;
        if (this.get("ClientVars", @vars))
        {
            vars_loaded = true;
        }
 
        ConfigFile cfg = ConfigFile();
	    if (!cfg.loadFile("../Cache/FB/clientconfig.cfg") || !vars_loaded)
	    {
            error("Client config or vars could not load");

	    	cfg.add_bool("mute_messages", false);
            cfg.add_f32("messages_volume", 0.5f);
            cfg.add_f32("messages_pitch", 1.0f);
	    	cfg.saveFile("FB/clientconfig.cfg");
	    }
        else if (vars_loaded && vars !is null)
        {
            vars.msg_mute = cfg.read_bool("mute_messages", vars.msg_mute);
            vars.msg_volume = cfg.read_f32("messages_volume", vars.msg_volume);
            vars.msg_pitch = cfg.read_f32("messages_pitch", vars.msg_pitch);
        }

        Vec2f menu_pos = Vec2f(15,15);
        Vec2f menu_dim = Vec2f(400, 400);
        ConfigMenu setmenu(menu_pos, menu_dim);

        {
            Vec2f section_pos = menu_pos;
            Section messages("Messages", section_pos, Vec2f(menu_dim.x/2, menu_pos.y + 100));

            Option mute("Mute sound", section_pos+messages.padding+Vec2f(0,30), false, true);
            messages.addOption(mute);

            setmenu.addSection(messages);
        }

		this.set("ConfigMenu", @setmenu);
    }
}

void onRestart(CRules@ this)
{
    if (isClient() && isServer())
    {
        if (getLocalPlayer() !is null)
	    {
            onInit(this);
        }
    }
}

void onRender(CRules@ this)
{
    if (getLocalPlayer() !is null)
    {
        ConfigMenu@ menu;
        if (this.get("ConfigMenu", @menu))
        {
            menu.render();
        }
    }
}