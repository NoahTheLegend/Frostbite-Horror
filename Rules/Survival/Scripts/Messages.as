const u16 scrw = getDriver().getScreenWidth();
const u16 scrh = getDriver().getScreenHeight();

u8 hud_transparency = 190;

class Message
{
    string text;
    string title;
    bool playsound;
    u16 max_length;
    string text_to_show;
    u8 delay;
    bool completed;

    Message(string _text, string _title, bool _playsound = true, u16 _max_length = 255, u8 _delay = 1)
    {
        text = _text;
        title = _title;
        playsound = _playsound;
        max_length = _max_length;
        delay = _delay;
        text_to_show = "";
        completed = false;
    }

    void write()
    {
        if (!ended())
        {
            this.text_to_show = text.substr(0, text_to_show.size()+1);
        }
    }    

    bool ended()
    {
        if (!completed) completed = text_to_show.size() == text.size();
        return completed;
    }
};

class MessageBox
{
    u8 max_history_size;
    Vec2f dim;
    Vec2f padding;
    u8 wait_time;
    f32 wrap_edge;

    Vec2f tl;
    Vec2f br;

    MessageBox(u8 _max_history_size, Vec2f _dim, Vec2f _padding)
    {
        max_history_size = _max_history_size;
        dim = _dim;
        padding = _padding;
        wait_time = 0;

        tl = Vec2f(scrw-dim.x, 0);
        br = Vec2f(scrw, dim.y);
        wrap_edge = dim.x-padding.x*4;
    }

    Message@[] order_list;
    Message@[] history;

    void addMessage(Message msg)
    {
        

        this.order_list.push_back(msg);
    }
    
    void render()
    {
        GUI::SetFont("CascadiaCodePL_12");
        GUI::DrawPane(tl-Vec2f(0,10), br, SColor(hud_transparency,255,255,255));
        
        if (wait_time != 0)
        {
            wait_time--;
        }

        if (order_list.size() > 0)
        {
            Message@ msg = order_list[0];

            if (wait_time == 0)
            {
                msg.write();
                wait_time = msg.delay;

                if (msg.ended())
                {
                    if (history.size() > max_history_size)
                    {
                        history.removeAt(0);
                    }
                    
                    history.insertAt(0, msg);
                    order_list.removeAt(0);
                }
            }

            Vec2f text_dim;
            GUI::GetTextDimensions(msg.text_to_show, text_dim);
            
            u16 index = msg.text_to_show.size();
            if (text_dim.x > wrap_edge) // also test w\o spaces
            {
                for (u16 i = 1; i < index; i++)
                {
                    u16 check_index = index-i;
                    if (msg.text_to_show.substr(check_index, 1) == " ")
                    {
                        msg.text = msg.text.substr(0, check_index) + "\n" + msg.text.substr(check_index);
                        break;
                    }
                }
            }

            GUI::DrawText(msg.text_to_show, br - Vec2f(dim.x, text_dim.y) + Vec2f(padding.x, -padding.y), color_white);
        }
        
        f32 total_offset = 0;
        for (u8 i = 0; i < history.size(); i++)
        {
            Message@ msg = history[i];
            Message@ showing = order_list.size() > 0 ? order_list[0] : null;

            Vec2f text_dim = Vec2f_zero;
            GUI::GetTextDimensions(msg.text, text_dim);

            Vec2f showing_text_dim = Vec2f_zero;
            if (showing !is null) GUI::GetTextDimensions(showing.text_to_show, showing_text_dim);

            GUI::DrawText(msg.text, br - Vec2f(dim.x, text_dim.y+total_offset+showing_text_dim.y) + Vec2f(padding.x, -padding.y), color_white);
            total_offset += text_dim.y;
        }
        //GUI::DrawText(""+history.size(), tl + Vec2f(-20, 100), color_white);
    }
};

string formDefaultTitle(CPlayer@ this)
{
    if (this is null) return "Unknown source";
    else return this.getCharacterName()+" said:";
}

void addMessage(string text)
{
    Message msg(text, "", true, 255, 1);
    addMessage(msg);
}

void addMessage(string text, string title)
{
    Message msg(text, title, true, 255, 1);
    addMessage(msg);
}

void addMessage(string text, string title, bool playsound, u16 length, u8 delay)
{
    Message msg(text, title, playsound, length, delay);
    addMessage(msg);
}

void addMessage(Message msg)
{
    MessageBox@ box;
    if (getRules().get("MessageBox", @box))
    {
        if (box !is null)
        {
            box.addMessage(msg);
        }
    }
}