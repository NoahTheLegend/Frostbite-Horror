#define CLIENT_ONLY

#include "ClientVars.as";
#include "ClientConfig.as";
#include "Utilities.as";

const u16 savetime_fadeout = 10;
const u16 savetime_delay = 60;
u16 savetime = 0;

void onInit(CRules@ this)
{
    if (isClient())
	{
        // init
        ClientVars setvars();
	    this.set("ClientVars", @setvars);

		ClientVars@ vars;
        if (this.get("ClientVars", @vars))
        {
            LoadConfig(this, vars);
            updateRulesProps(this);
        }

        SetupUI(this);
    }
}

void onRestart(CRules@ this)
{
    if (isServer() && getLocalPlayer() !is null) // localhost fix
        onInit(this);

    updateRulesProps(this);
}

void updateRulesProps(CRules@ this)
{
    
}

// hack
void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
    if (player !is null && player.isMyPlayer())
    {
        updateRulesProps(this);
    }
}

void LoadConfig(CRules@ this, ClientVars@ vars) // load cfg from cache
{
    ConfigFile cfg = ConfigFile();

	if (!cfg.loadFile("../Cache/FB/clientconfig.cfg"))
	{
        error("Client config or vars could not load");

		cfg.add_bool("mute_messages", false);
        cfg.add_f32("messages_volume", 0.25f);
        cfg.add_f32("messages_pitch", 1.0f);
		cfg.saveFile("FB/clientconfig.cfg");
	}
    else if (vars !is null)
    {
        vars.msg_mute = cfg.read_bool("mute_messages");
        vars.msg_volume = cfg.read_f32("messages_volume");
        vars.msg_pitch = cfg.read_f32("messages_pitch");

        vars.msg_volume_final = min_vol + vars.msg_volume * (max_vol-min_vol);
        vars.msg_pitch_final = min_pitch + vars.msg_pitch * (max_pitch-min_pitch);
    }
}

void SetupUI(CRules@ this) // add options here
{
    Vec2f menu_pos = Vec2f(15,15);
    Vec2f menu_dim = Vec2f(400, 400);
    ConfigMenu setmenu(menu_pos, menu_dim);
    
    // keep order with saving vars
    ClientVars@ vars = getVars();
    if (vars !is null)
    {
        Vec2f section_pos = menu_pos;
        Section messages("Messages", section_pos, Vec2f(menu_dim.x/2, menu_pos.y + 150));

        // slider increases every build up from initializing, pls fix 

        Option mute("Mute sound", section_pos+messages.padding+Vec2f(0,35), false, true);
        mute.setCheck(vars.msg_mute);
        messages.addOption(mute);

        Option volume("Sound volume modifier", mute.pos+Vec2f(0,25), true, false);
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

void WriteConfig(CRules@ this, ConfigMenu@ menu) // save config
{
    this.Untag("update_clientvars");

    if (menu is null)
    {
        error("Could not save vars, menu is null");
        return;
    }

    ClientVars@ vars;
    if (getRules().get("ClientVars", @vars))
    {
        //camera
        //====================================================
        if (menu.sections.size() != 0)
        {
            if (menu.sections[0].options.size() != 0)
            {
                // section 0: Messages
                Option mute             = menu.sections[0].options[0];
                vars.msg_mute           = mute.check.state;

                Option volume           = menu.sections[0].options[1];
                vars.msg_volume         = volume.slider.scrolled * max_vol;
                vars.msg_volume_final   = min_vol + volume.slider.scrolled * (max_vol-min_vol);

                Option pitch            = menu.sections[0].options[2];
                vars.msg_pitch          = pitch.slider.scrolled * max_pitch;
                vars.msg_pitch_final    = min_pitch + pitch.slider.scrolled * (max_pitch-min_pitch);
            }
        
            //====================================================
            ConfigFile cfg = ConfigFile();
	        if (cfg.loadFile("../Cache/FB/clientconfig.cfg"))
	        {
                // write config
                //====================================================
                cfg.add_bool("mute_messages",  vars.msg_mute);
                cfg.add_f32("messages_volume", vars.msg_volume);
                cfg.add_f32("messages_pitch",  vars.msg_pitch);
                //====================================================
                // save config
	        	cfg.saveFile("FB/clientconfig.cfg");

                savetime = savetime_fadeout + savetime_delay;
	        }
            else
            {
                error("Could not load config to save vars code 1");
                error("Loading default preset");
                //====================================================
                cfg.add_bool("mute_messages",  vars.msg_mute);
                cfg.add_f32("messages_volume", vars.msg_volume);
                cfg.add_f32("messages_pitch",  vars.msg_pitch);
                //====================================================
		        cfg.saveFile("FB/clientconfig.cfg");
            }
        }
        else error("Could not load config to save vars code 2");
    }
}

void onRender(CRules@ this) // renderer for class, saves config if class throws update tag
{
    if (isClient())
    {
        bool need_update = this.hasTag("update_clientvars");
        
        ConfigMenu@ menu;
        if (this.get("ConfigMenu", @menu))
        {
            menu.render();

            GUI::SetFont("menu");
            if (savetime > 0)
            {
                GUI::DrawText("Saved!", menu.pos+Vec2f(menu.target_dim.x + 6, 7),
                    SColor(185 * Maths::Min(1.0f, f32(savetime)/savetime_fadeout), 25, 255, 50));
                savetime--;
            }

            if (need_update)
            {
                WriteConfig(this, menu);
            }
        }

        // put common stuff to update here, otherwise keep in relative scripts
        if (need_update)
        {
		    ClientVars@ vars;
    	    if (this.get("ClientVars", @vars))
    	    {
                updateRulesProps(this);
    	    }
        }
    }
}