#include "Slider.as";

const u16 scrw = getDriver().getScreenWidth();
const u16 scrh = getDriver().getScreenHeight();

u8 hud_transparency = 190;

class Message
{
    string text;
    string title;
    string[] text_lines;
    f32 height;
    u8 line_height;
    bool playsound; // todo
    u16 max_length; // todo
    string text_to_write;
    u8 delay;
    bool completed;

    Vec2f old_pos;

    Message(string _text, string _title, bool _playsound = true, u16 _max_length = 255, u8 _delay = 1, u8 _line_height = 12)
    {
        text = _text;
        title = _title;
        playsound = _playsound;
        max_length = _max_length;
        delay = _delay;
        delay = 5;
        line_height = _line_height;

        height = 0;
        text_to_write = "";
        completed = false;
    }

    void write()
    {
        if (!ended())
        {
            this.text_to_write = text.substr(0, text_to_write.size()+1);
        }
    }    

    bool ended()
    {
        if (!completed) completed = text_to_write.size() == text.size();
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
    Slider slider;

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
        wrap_edge = dim.x-padding.x*2;

        slider = Slider("scroll", tl-Vec2f(15,0), Vec2f(15, dim.y), Vec2f(15,15), Vec2f(16,16), 1.0f, 5);
    }

    Message@[] order_list;
    Message@[] history;

    void addMessage(Message msg)
    {
        msg.old_pos = Vec2f(tl.x, br.y);
        this.order_list.push_back(msg);
    }
    
    void render()
    {
        slider.render();

        GUI::SetFont("CascadiaCodePL_12");
        GUI::DrawPane(tl-Vec2f(0,10), br, SColor(hud_transparency,255,255,255));
        
        if (wait_time != 0)
        {
            wait_time--;
        }

        // draw new message filling
        if (order_list.size() > 0)
        {
            Message@ msg = order_list[0];

            if (wait_time == 0)
            {
                this.write(msg);
            }

            u8 l_size = msg.text_lines.size();
            string l_text = l_size == 0 ? msg.text_to_write : msg.text_to_write.substr(getLineIndex(msg));
            Vec2f l_dim;
            GUI::GetTextDimensions(l_text, l_dim);
            
            Vec2f text_dim;
            GUI::GetTextDimensions(msg.text_to_write, text_dim);
            msg.height = text_dim.y*(l_size+1);

            Vec2f msg_pos = br - Vec2f(dim.x, text_dim.y) + Vec2f(padding.x, -padding.y);
            msg.old_pos = msg_pos+Vec2f(0, text_dim.y);
            
            u16 index = msg.text_to_write.size();
            // separate lines once it passes edge
            if (l_dim.x > wrap_edge || msg.ended()) // also test w\o spaces
            {
                for (u16 i = 1; i < index; i++)
                {
                    u16 check_index = index-i;
                    string wrap_line = l_text.substr(check_index, 1);
                    if (wrap_line == " " || msg.ended())
                    {
                        msg.text_lines.push_back(l_text.substr(0, check_index+1));

                        break;
                    }
                }
            }

            if (l_size > 0)
            {
                for (u8 i = 0; i < l_size; i++)
                {
                    string newtext = msg.text_lines[l_size-(i+1)];
                    Vec2f l_pos = msg_pos-Vec2f(0,msg.line_height*(i+1));

                    GUI::DrawText(newtext, l_pos, color_white);
                }
            }
            GUI::DrawText(msg.text_to_write.substr(getLineIndex(msg)), msg_pos, color_white);
        }
        
        // draw history of messages by lines, apply effects here
        u16 lines_outbound = 0;
        f32 total_offset = 0;
        for (u8 i = 0; i < history.size(); i++)
        {
            Message@ msg = history[i];
            Message@ prev = order_list.size() > 0 ? order_list[0] : null;

            f32 prev_height = 0;
            if (prev !is null) prev_height = prev.height;

            Vec2f l_padding = Vec2f(padding.x, -padding.y);
            u8 l_size = msg.text_lines.size();
            f32 offset = total_offset+prev_height;

            Vec2f msg_pos = Vec2f_lerp(msg.old_pos, br - Vec2f(dim.x, offset) + l_padding, 0.5f);
            msg.old_pos = msg_pos;

            for (u8 j = 0; j < l_size; j++)
            {
                string newtext = msg.text_lines[l_size-(j+1)];
                Vec2f l_pos = msg_pos-Vec2f(0, msg.line_height*(j+1));

                if (msg_pos.y >= padding.y)
                    GUI::DrawText(newtext, l_pos, color_white);
                else lines_outbound++;
            }

            total_offset += msg.height;
        }

        GUI::DrawText(""+lines_outbound, tl - Vec2f(40, -20), color_black);
    }

    int getLineIndex(Message@ msg)
    {
        return getLineIndex(msg, msg.text_lines.size());
    }

    int getLineIndex(Message@ msg, u8 line)
    {
        int index = 0;
        for (u8 i = 0; i < Maths::Min(line, msg.text_lines.size()); i++)
        {
            index += msg.text_lines[i].size();
        }
        return index;
    }

    void write(Message@ msg)
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