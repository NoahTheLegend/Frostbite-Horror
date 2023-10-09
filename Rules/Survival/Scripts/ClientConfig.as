#define CLIENT_ONLY

#include "ClientVars.as";

void onInit(CRules@ this)
{
    if (getLocalPlayer() !is null)
	{
        ConfigFile cfg = ConfigFile();
	    if (!cfg.loadFile("Cache/FB/clientconfig.cfg"))
	    {
	    	cfg.add_bool("mute_messages", msg_mute);
            cfg.add_f32("messages_volume", msg_volume);
            cfg.add_f32("messages_pitch", msg_pitch);
	    	cfg.saveFile("FB/clientconfig.cfg");
	    }
        else
        {
            msg_mute = cfg.read_bool("mute_messages", msg_mute);
            msg_volume = cfg.read_f32("messages_volume", msg_volume);
            msg_pitch = cfg.read_f32("messages_pitch", msg_pitch);
        }
    }
}