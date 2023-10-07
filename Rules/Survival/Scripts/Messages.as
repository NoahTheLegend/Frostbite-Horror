#include "Slider.as";

const u16 scrw = getDriver().getScreenWidth();
const u16 scrh = getDriver().getScreenHeight();

u8 hud_transparency = 190;
const u8 line_height = 12;

class Message
{
    string text;
    string title; // todo
    string[] text_lines;
    f32 height;
    bool playsound; // todo
    u16 max_length; // todo
    string text_to_write;
    u8 delay;

    bool completed;
    Vec2f old_pos;

    Message(string _text, string _title, bool _playsound = true, u16 _max_length = 255, u8 _delay = 1)
    {
        text = _text;
        title = _title;
        playsound = _playsound;
        max_length = _max_length;
        delay = _delay;

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
    u16 lines_scrolled;
    u8 message_gap;

    Vec2f tl;
    Vec2f br;

    MessageBox(u8 _max_history_size, Vec2f _dim, Vec2f _padding, u8 _message_gap = 0)
    {
        max_history_size = _max_history_size;
        dim = _dim;
        padding = _padding;
        wait_time = 0;
        message_gap = _message_gap;

        tl = Vec2f(scrw-dim.x, 0);
        br = Vec2f(scrw, dim.y);
        wrap_edge = dim.x-padding.x*2;
        lines_scrolled = 0;

        slider = Slider("scroll", tl-Vec2f(15,0), Vec2f(15, dim.y), Vec2f(15,15), Vec2f(16,16), 1.0f, 0);
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
            string l_text = l_size == 0 ? msg.text_to_write : msg.text_to_write.substr(getLineIndex(msg)-1);
            
            // get rid of spaces in beginning of lines
            u8 spaces = 0;
            for (u8 i = 0; i < l_text.size(); i++)
            {
                if (l_text.substr(i, 1) == " ") spaces++;
                else break;
            }
            l_text = l_text.substr(spaces);

            Vec2f l_dim;
            GUI::GetTextDimensions(l_text, l_dim);
            
            Vec2f text_dim;
            GUI::GetTextDimensions(msg.text_to_write, text_dim);
            msg.height = (text_dim.y*(l_size+1))+message_gap;

            Vec2f msg_pos = br - Vec2f(dim.x, text_dim.y) + Vec2f(padding.x, -padding.y);
            msg.old_pos = msg_pos+Vec2f(0, text_dim.y);
            
            u16 index = msg.text_to_write.size();
            bool endline = msg.ended();
            
            // draw on-going message
            if (lines_scrolled == 0)
            {
                if (l_size > 0)
                {
                    for (u8 i = 0; i < l_size; i++)
                    {
                        string newtext = msg.text_lines[l_size-(i+1)];
                        Vec2f l_pos = msg_pos-Vec2f(0, line_height*(i+1));

                        GUI::DrawText(newtext, l_pos, color_white);
                    }
                }
                GUI::DrawText(l_text, msg_pos, color_white);
            }

            // separate lines once it passes edge
            if (l_dim.x > wrap_edge || endline) // also test w\o spaces
            {
                for (u16 i = 1; i <= 12; i++)
                {
                    if (i < 12)
                    {
                        u16 check_index = index-i;
                        string wrap_line = l_text.substr(check_index, 1);

                        if (wrap_line == " " || endline)
                        {
                            msg.text_lines.push_back(l_text.substr(0, check_index+1));
                            break;
                        }
                    }
                    else // the word is too long
                    {
                        msg.text_lines.push_back(l_text.substr(0, index)+(endline?"":"-"));
                    }
                }
            }
        }

        // draw history of messages by lines, apply effects here
        f32 scroll = slider.scrolled;
        u16 lines_outbound = 0;
        f32 total_offset = 0;

        string[] lines;
        Vec2f[] offsets;

        for (u8 i = 0; i < history.size(); i++)
        {
            Message@ msg = history[i];
            Message@ prev = order_list.size() > 0 && lines_scrolled == 0 ? order_list[0] : null;

            f32 prev_height = 0;
            if (prev !is null) prev_height = prev.height;

            Vec2f l_padding = Vec2f(padding.x, -padding.y);
            u8 l_size = msg.text_lines.size();
            f32 offset = total_offset+prev_height;

            Vec2f msg_pos = Vec2f_lerp(msg.old_pos, br - Vec2f(dim.x, offset) + l_padding, lines_scrolled == 0 ? 0.5f : 1.0f);
            msg.old_pos = msg_pos;

            for (u8 j = 0; j < l_size; j++)
            {
                string newtext = msg.text_lines[l_size-(j+1)];
                Vec2f l_pos = msg_pos-Vec2f(0, line_height*(j+1)+3);

                lines.push_back(newtext);
                offsets.push_back(l_pos);

                if (l_pos.y < padding.y) lines_outbound++;
            }
            total_offset += msg.height;

            // draw title
        }

        lines_scrolled = lines_outbound - Maths::Round(lines_outbound*scroll);
        Vec2f scroll_offset = Vec2f(0, line_height*lines_scrolled);

        for (u8 i = lines_scrolled; i < lines.size(); i++)
        {
            Vec2f l_pos = offsets[i]+scroll_offset+Vec2f(0,3*lines_scrolled); // i rly dont know why this should exist
            if (l_pos.y < padding.y) break;

            GUI::DrawText(lines[i], l_pos, color_white);
        }

        //slider.setSnap(lines_outbound);
        GUI::DrawText("out: "+lines_outbound+"\nscrolled: "+scroll+"\nlines scrolled: "+lines_scrolled+"\noffset: "+scroll_offset, tl - Vec2f(150, -20), color_black);
    }

    void write(Message@ msg)
    {
        msg.write();
        wait_time = msg.delay;

        if (msg.ended())
        {
            if (history.size() > max_history_size)
            {
                history.pop_back();
            }

            history.insertAt(0, msg);
            order_list.removeAt(0);
        }
    }

    // returns index in whole text where the line starts from
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