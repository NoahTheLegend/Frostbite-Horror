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
            vars.msg_mute = cfg.read_bool("mute_messages");
            vars.msg_volume = cfg.read_f32("messages_volume");
            vars.msg_pitch = cfg.read_f32("messages_pitch");
        }

        SetupConfig(this);
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

            bool need_update = this.hasTag("update_clientvars");
            if (need_update)
            {
                SerializeVars(this, menu);
                this.Untag("update_clientvars");
            }
        }
    }
}

void SerializeVars(CRules@ this, ConfigMenu@ menu)
{
    if (menu is null)
    {
        this.Untag("update_clientvars");
        error("Could not save vars, menu is null");
        return;
    }

    ClientVars@ vars;
    if (getRules().get("ClientVars", @vars))
    {
        // section 0: Messages
        Option mute   = menu.sections[0].options[0];
        Option volume = menu.sections[0].options[1];
        Option pitch  = menu.sections[0].options[2];

        vars.msg_mute = mute.check.state;
        vars.msg_volume = volume.slider.scrolled;
        vars.msg_pitch = Maths::Max(min_pitch, pitch.slider.scrolled * max_pitch);

        //printf(getGameTime()+" saving "+vars.msg_mute+" "+vars.msg_volume+" "+vars.msg_pitch);

        ConfigFile cfg = ConfigFile();
	    if (cfg.loadFile("../Cache/FB/clientconfig.cfg"))
	    {
	    	cfg.add_bool("mute_messages",  vars.msg_mute);
            cfg.add_f32("messages_volume", vars.msg_volume);
            cfg.add_f32("messages_pitch",  vars.msg_pitch);
	    	cfg.saveFile("FB/clientconfig.cfg");
	    }
        else error("Could not load config to save vars");
    }
}

void SetupConfig(CRules@ this)
{
    Vec2f menu_pos = Vec2f(15,15);
    Vec2f menu_dim = Vec2f(400, 400);
    ConfigMenu setmenu(menu_pos, menu_dim);
    
    // keep order with saving vars
    ClientVars@ vars;
    if (getRules().get("ClientVars", @vars))
    {
        Vec2f section_pos = menu_pos;
        Section messages("Messages", section_pos, Vec2f(menu_dim.x/2, menu_pos.y + 150));

        // slider increases every build up from initializing, pls fix 

        Option mute("Mute sound", section_pos+messages.padding+Vec2f(0,35), false, true);
        mute.setCheck(vars.msg_mute);
        messages.addOption(mute);

        Option volume("Sound volume", mute.pos+Vec2f(0,25), true, false);
        volume.setSliderPos(vars.msg_volume/max_vol);
        messages.addOption(volume);

        Option pitch("Sound pitch modifier", volume.pos+Vec2f(0,45), true, false);
        pitch.setSliderPos(vars.msg_pitch/max_pitch);
        messages.addOption(pitch);

        setmenu.addSection(messages);
    }
    else error("Could not setup config UI, clientvars do not exist");

	this.set("ConfigMenu", @setmenu);
}