#include "Slider.as";
#include "ClientVars.as";

// capped to framerate
// staging may have issues

const u16 scrw = getDriver().getScreenWidth();
const u16 scrh = getDriver().getScreenHeight();

u8 hud_transparency = 190;
const u8 line_height = 12;

class Message
{
    string text;
    string title;
    u8 title_offset;
    SColor title_color; // todo
    string[] text_lines;
    f32 height;
    bool playsound; // todo
    u16 max_length;
    string text_to_write;
    u8 delay;
    u8 title_alpha;

    bool completed;
    Vec2f old_pos;

    Message(string _text, string _title, u8 _title_offset = 4, bool _playsound = true, u16 _max_length = 255, u8 _delay = 1)
    {
        text = _text;
        title = _title;
        title_offset = _title_offset;
        playsound = _playsound;
        max_length = _max_length;
        delay = _delay;

        title_alpha = 55;
        height = 0;
        text_to_write = "";
        completed = false;
    }

    string write()
    {
        if (!ended())
        {
            string full = this.text_to_write = text.substr(0, text_to_write.size()+1);
            string char = full.substr(full.size()-1, 1);
            return char;
        }
        return "";
    }    

    bool ended()
    {
        if (!completed) completed = text_to_write.size() == text.size();
        return completed;
    }

    void fadeIn(u8 fade)
    {
        this.title_alpha = Maths::Min(255, title_alpha+fade);
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
        message_gap = _message_gap; // applies if bigger than distance between last lines of messages

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

    u8 getPunctuationDelay(string l)
    {
        switch (l.getHash())
        {
            case 688690635: // ,
            case 604802540: // !
                return 10;
            case 722245873: // .
            case 1041020634: // ;
            case 1057798253: // :
            case 973910158: // ?
                return 20;
        }
        return 0;
    }
    
    void render()
    {
        GUI::SetFont("CascadiaCodePL_12");

        slider.render();
        GUI::DrawPane(tl-Vec2f(0,10), br, SColor(hud_transparency,255,255,255));
        
        if (wait_time != 0)
        {
            wait_time--;
        }
        
        handleOrder();
        int history_size = handleHistory(); // in lines

        u8 was_scroll = wasMouseScroll(); // 1 - up, 2 - down
        if (was_scroll != 0 && mouseHovered(this, slider))
        {
            slider.scrollBy(was_scroll == 1 ? Maths::Min(-1, -25+history_size/4) : Maths::Max(1, 25-history_size/4));
        }
    }

    // process and draw recent message
    void handleOrder()
    {
        if (order_list.size() > 0)
        {
            Message@ msg = order_list[0];
            string written;
            bool endline = msg.ended();
            // timer to draw next symbol
            if (wait_time == 0)
            {
                written = this.write(msg);

                u8 extra_delay = getPunctuationDelay(written);
                wait_time = msg.delay + extra_delay;
            }
            msg.fadeIn(20);

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

            // processed line (text filler) dimensions
            Vec2f l_dim;
            GUI::GetTextDimensions(l_text, l_dim);
            
            // reference for processing line dimensions
            Vec2f text_dim;
            GUI::GetTextDimensions(msg.text_to_write, text_dim);

            // apply height, including margin as message_gap
            msg.height = (text_dim.y*(l_size+1))+message_gap;

            Vec2f msg_pos = br - Vec2f(dim.x, text_dim.y) + Vec2f(padding.x, -padding.y);
            msg.old_pos = msg_pos+Vec2f(0, text_dim.y);
        
            u16 index = msg.text_to_write.size();
            // draw filler message
            if (lines_scrolled == 0)
            {
                SColor copy_color_white = color_white;
                bool has_title_alpha = false;
                for (u8 i = 0; i < l_size+1; i++)
                {
                    string newtext;
                    Vec2f l_pos = msg_pos-Vec2f(0, line_height*(i+1));
                    if (i == l_size) // reserved for title
                    {
                        GUI::SetFont("CascadiaCodePL-Bold_13");
                        newtext = msg.title;
                        l_pos.y -= msg.title_offset;
                        copy_color_white.setAlpha(msg.title_alpha);
                    }
                    else if (l_size > 0)
                    {
                        newtext = msg.text_lines[l_size-(i+1)];
                    }
                    
                    GUI::DrawText(newtext, l_pos, copy_color_white);
                }
                GUI::SetFont("CascadiaCodePL_12");
                GUI::DrawText(l_text, msg_pos, color_white);
            }

            // separate lines once it passes edge
            if (l_dim.x > wrap_edge || endline)
            {
                wrapText(msg, l_text, index, endline);
            }
        }
    }

    // wraps text line at position, specify if line is last and is message end 
    void wrapText(Message@ msg, string l_text, u16 index, bool message_end)
    {
        for (u16 i = 1; i <= 12; i++)
        {
            if (i < 12)
            {
                u16 check_index = index-i;
                string wrap_line = l_text.substr(check_index, 1);

                if (wrap_line == " " || message_end)
                {
                    msg.text_lines.push_back(l_text.substr(0, check_index+1));
                    break;
                }
            }
            else // the word is too long or message ended
            {
                msg.text_lines.push_back(l_text.substr(0, index)+(message_end?"":"-"));
            }
        }
    }

    // shatters messages from history into lines and assigns them positions relatively
    u16 handleHistory()
    {
        f32 scroll = slider.scrolled;
        u16 lines_outbound = 0;
        f32 total_offset = 0;

        string[] lines;
        Vec2f[] offsets;
        bool[] is_title;

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

            for (u8 j = 0; j < l_size+1; j++)
            {
                string newtext;
                Vec2f l_pos = msg_pos-Vec2f(0, line_height*(j+1)+3);
                bool l_title = false;

                if (j == l_size) // reserved for title
                {
                    newtext = msg.title;
                    l_pos.y -= msg.title_offset;
                    l_title = true;
                }
                else newtext = msg.text_lines[l_size-(j+1)];

                lines.push_back(newtext);
                offsets.push_back(l_pos);
                is_title.push_back(l_title);

                if (l_pos.y < padding.y) lines_outbound++;
            }
            total_offset += msg.height;
        }

        drawHistory(lines, offsets, is_title, lines_outbound, scroll);
        return lines.size();
    }

    // draws history messages by lines
    void drawHistory(string[] lines, Vec2f[] offsets, bool[] is_title, u16 lines_outbound, f32 scroll)
    {
        lines_scrolled = lines_outbound - Maths::Round(lines_outbound*scroll);
        Vec2f scroll_offset = Vec2f(0, line_height*lines_scrolled);

        for (u8 i = lines_scrolled; i < lines.size(); i++)
        {
            SColor copy_color_white = color_white;
            Vec2f l_pos = offsets[i]+scroll_offset+Vec2f(0,3.33f*lines_scrolled); // i rly dont know why this should exist
            
            if (l_pos.y < 0) break;

            GUI::SetFont(is_title[i] ? "CascadiaCodePL-Bold_13" : "CascadiaCodePL_12");
            GUI::DrawText(lines[i], l_pos, copy_color_white);
        }

        GUI::DrawText("out: "+lines_outbound+"\nscrolled: "+scroll+"\nlines scrolled: "+lines_scrolled+"\noffset: "+scroll_offset, tl - Vec2f(170, -20), color_black);
    }

    // writes a message symbol by symbol
    string write(Message@ msg)
    {
        if (msg.playsound)
            Sound::Play("text_write.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), msg_volume, msg_pitch+XORRandom(11)*0.01f);
        
        if (msg.ended())
        {
            if (history.size() > max_history_size)
            {
                history.pop_back();
            }

            history.insertAt(0, msg);
            order_list.removeAt(0);
        }
        return msg.write();
    }

    // returns the index of last line
    int getLineIndex(Message@ msg)
    {
        return getLineIndex(msg, msg.text_lines.size());
    }

    // returns index in whole text where the line starts from
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

u8 wasMouseScroll()
{
    CControls@ controls = getControls();
    if (controls is null) return 0;

    if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMIN))) return 1;
    else if (controls.isKeyJustPressed(controls.getActionKeyKey(AK_ZOOMOUT))) return 2;

    return 0;
}

bool mouseHovered(MessageBox@ this, Slider slider)
{
    CControls@ controls = getControls();
    Vec2f mpos = controls.getMouseScreenPos();

    bool isOnMessageBox = (mpos.x >= this.tl.x && mpos.x <= this.br.x && mpos.y >= this.tl.y && mpos.y <= this.br.y);
    if (isOnMessageBox) return true;

    bool isOnSlider = (mpos.x >= slider.tl.x && mpos.x <= slider.br.x && mpos.y >= slider.tl.y && mpos.y <= slider.br.y);
    if (isOnSlider) return true;
    
    return false;
}

string formDefaultTitle(CPlayer@ this)
{
    if (this is null) return "Unknown source";
    else return this.getCharacterName()+" said:";
}

void addMessage(string text)
{
    Message msg(text, "", 4, true, 255, 1);
    addMessage(msg);
}

void addMessage(string text, string title)
{
    Message msg(text, title, 4, true, 255, 1);
    addMessage(msg);
}

void addMessage(string text, string title, u8 title_offset, bool playsound, u16 length, u8 delay)
{
    Message msg(text, title, title_offset, playsound && !msg_mute, length, delay);
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