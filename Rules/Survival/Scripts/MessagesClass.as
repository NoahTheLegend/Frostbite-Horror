// capped to framerate
// staging may have issues
//
// TODO: MessageBox is using screen boundaries to remove text overflowing, should be rewritten
// in a way to let the container slide over screen and be independent

#include "Slider.as";
#include "ClientVars.as";
#include "MessagesCommon.as";
#include "Utilities.as";

const u16 scrw = getDriver().getScreenWidth();
const u16 scrh = getDriver().getScreenHeight();
bool was_press = false;

u8 hud_transparency = 190;
const u8 line_height = 12;

// contains text and properties for default text runner
class MessageText
{
    string text;
    string title;
    u8 title_offset;
    SColor title_color; // todo

    u16 max_length;
    u8 delay;
    bool playsound;

    MessageText(string _text, string _title, u8 _title_offset, u16 _max_length, u8 _delay, bool _playsound)
    {
        text = _text;                 // full text
        title = _title;               // constant title
        title_offset = _title_offset; // gap between title and text
        max_length = _max_length;     // max message length
        delay = _delay;               // amount of ticks to wait for next symbom to write
        playsound = _playsound;       // play bzzt sound
    }
};

// wraps and splits text in lines for container, writes text char by char, manages title
class Message
{
    MessageText messageText;
    string text_to_write;
    string[] text_lines;

    f32 height;
    u8 title_alpha;
    bool completed;
    Vec2f old_pos;          // lerped sliding
    
    Message(MessageText _messageText)
    {
        messageText = _messageText;
        height = 0;         // relative dimension
        title_alpha = 55;   // opacity on-create
        text_to_write = ""; // render text
        completed = false;
    }

    string write()
    {
        if (!ended())
        {
            string text = messageText.text;

            string full = text_to_write = text.substr(0, text_to_write.size()+1);
            string char = full.substr(full.size()-1, 1);
            return char;
        }
        return "";
    }    

    bool ended()
    {
        if (!completed) completed = text_to_write.size() == messageText.text.size();
        return completed;
    }

    void fadeIn(u8 fade)
    {
        this.title_alpha = Maths::Min(255, title_alpha+fade);
    }
};

// handler
class MessageBox
{
    Vec2f dim;
    Vec2f padding;

    ClientVars vars;
    Slider slider;

    u8 max_history_size;
    u8 wait_time;
    
    u16 lines_scrolled;
    f32 wrap_edge;
    u8 message_gap;

    Vec2f hidebar_tl;
    Vec2f hidebar_br;

    Vec2f tl;
    Vec2f br;

    bool hidden;

    string[] lines;
    Vec2f[] offsets;
    bool[] is_title;

    u8 msg_count_slidetime;
    u8 msg_count_slidetime_current;

    MessageBox(u8 _max_history_size, Vec2f _dim, Vec2f _padding, u8 _message_gap = 0)
    {
        dim = _dim;
        padding = _padding;
        
        tl = Vec2f(scrw-dim.x, 0);              // box top left
        br = Vec2f(scrw, dim.y);                // box bottom right

        slider = Slider("scroll", tl-Vec2f(15,0), Vec2f(15, dim.y), Vec2f(15,15), Vec2f(16,16), 1.0f, 0);

        max_history_size = _max_history_size;   // max amount of messages to buffer in array
        wait_time = 0;                          // initial wait time for next symbol to write

        message_gap = _message_gap;             // is applied when gap between messages is lesser than value
        
        hidebar_tl = Vec2f(tl.x, br.y-10);
        hidebar_br = Vec2f(br.x, br.y+5);
        wrap_edge = dim.x-padding.x*4;
        lines_scrolled = 0;

        hidden = true;
        msg_count_slidetime = 10; // should not be 0
        msg_count_slidetime_current = 0; 
    }

    Message@[] order_list; // messages waiting to be written
    Message@[] history;    // buffer

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
        if (vars is null) return;
        GUI::SetFont("CascadiaCodePL_12");

        slider.render(255);
        GUI::DrawPane(tl-Vec2f(0,10), br, SColor(hud_transparency,255,255,255));
        
        if (wait_time != 0)
        {
            wait_time--;
        }
        
        handleOrder();
        int history_size = handleHistory(); // in lines
        handleHideBar();

        u8 was_scroll = wasMouseScroll(); // 1 - up, 2 - down
        if (was_scroll != 0 && mouseHovered(this, slider))
        {
            slider.scrollBy(was_scroll == 1 ? Maths::Min(-1, -25+history_size/4) : Maths::Max(1, 25-history_size/4));
        }

        drawOrderCount();
    }

    void drawOrderCount()
    {
        u16 order_list_size = order_list.size();
        string count_text = "";

        if (order_list_size == 0)
        {
            count_text = "✓";
            if (msg_count_slidetime_current > 0) msg_count_slidetime_current--;
        }
        else
        {
            count_text = order_list_size+"!";
            if (msg_count_slidetime_current < msg_count_slidetime) msg_count_slidetime_current++;
        }

        f32 p = 32;
        Vec2f otl = br - Vec2f(p+6, dim.y + p * (1.0f-(f32(msg_count_slidetime_current)/f32(msg_count_slidetime))));
        Vec2f obr = otl + Vec2f(p, p);

        GUI::SetFont("RockwellMT_18");
        GUI::DrawSunkenPane(otl, obr);
        GUI::DrawTextCentered(count_text, otl + Vec2f(p/2-2, p/2), SColor(255, 255, 255, 0));
    }

    void handleHideBar()
    {
        CControls@ controls = getControls();
        if (controls !is null)
        {
            Vec2f mpos = controls.getInterpMouseScreenPos();
            bool hovering_hidebar = hover(mpos, hidebar_tl+Vec2f(17,0), hidebar_br);
            if ((controls.isKeyPressed(KEY_LBUTTON) || controls.isKeyPressed(KEY_RBUTTON)))
            {
                if (!was_press)
                {
                    if (hovering_hidebar) hidden = !hidden;
                    was_press = true;
                }
            }
            else was_press = false;

            if (!hidden)
            {
                tl.y = Maths::Lerp(tl.y, -dim.y+5, 0.25f);
                br.y = Maths::Lerp(br.y, 5, 0.25f);
            }
            else
            {
                tl.y = Maths::Lerp(tl.y, 0, 0.25f);
                br.y = Maths::Lerp(br.y, dim.y, 0.25f);             
            }

            if (Maths::Ceil(hidebar_tl.y) != Maths::Ceil(br.y-10))
            {
                hidebar_tl = Vec2f(tl.x, br.y-10);
                hidebar_br = Vec2f(br.x, br.y+5);
                slider.pos = tl-Vec2f(15,0);
                slider.recalculatePos(); 
            }

            drawHideBar(hidebar_tl, hidebar_br, hovering_hidebar);
        }
    }

    void drawHideBar(Vec2f htl, Vec2f hbr, bool hovering)
    {
        hovering ? GUI::DrawPane(htl, hbr) : GUI::DrawSunkenPane(htl, hbr);
    }

    // process and draw last message
    void handleOrder()
    {
        // runs until message is completed, then decrements .size()
        // TODO: can be optimized, cache some params in class?
        // in example predefined line dimensions and lines to fill
        // keep only rendering and timer here if possible,
        // and move processing into separated method
        if (order_list.size() > 0) 
        {
            Message@ msg = order_list[0];
            string written;
            string title = msg.messageText.title;
            u8 title_offset = msg.messageText.title_offset;
            bool endline = msg.ended();
            
            // timer until next symbol
            u8 delay = msg.messageText.delay;
            if (wait_time == 0)
            {
                written = this.writeMessage(msg);

                u8 extra_delay = getPunctuationDelay(written);
                wait_time = delay + extra_delay;
            }
            msg.fadeIn(20);

            // fill text from line to line 
            u8 l_size = msg.text_lines.size();
            string l_text = l_size == 0 ? msg.text_to_write : msg.text_to_write.substr(getLineIndex(msg)-1);
            
            // get rid of spaces in beginning of lines
            l_text = ignoreEmpty(l_text);

            // complete line dimensions
            Vec2f l_dim;
            GUI::GetTextDimensions(l_text, l_dim);
            
            // current text dimensions
            Vec2f text_dim;
            GUI::GetTextDimensions(msg.text_to_write, text_dim);

            // apply TOTAL height of the message (and offset from previous message)
            msg.height = (text_dim.y*(l_size+1))+message_gap;

            Vec2f msg_pos = br - Vec2f(dim.x, text_dim.y) + Vec2f(padding.x, -padding.y);
            msg.old_pos = msg_pos+Vec2f(0, text_dim.y);
        
            u16 index = msg.text_to_write.size();
            if (lines_scrolled == 0) // ignore, last line isnt rendering if false
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
                        newtext = title;
                        l_pos.y -= title_offset;
                        copy_color_white.setAlpha(msg.title_alpha);
                    }
                    else if (l_size > 0)
                    {
                        newtext = msg.text_lines[l_size-(i+1)];
                    }
                    
                    // draw title
                    GUI::DrawText(newtext, l_pos, copy_color_white);
                }

                // draw filling line
                GUI::SetFont("CascadiaCodePL_12");
                GUI::DrawText(l_text, msg_pos, color_white);
            }

            // separate lines once it passes edge
            if (l_dim.x > wrap_edge || endline)
            {
                wrapText(msg, l_text, index, endline, 12);
            }
        }
    }

    string ignoreEmpty(string text)
    {
        u8 spaces = 0;
        for (u8 i = 0; i < text.size(); i++)
        {
            if (text.substr(i, 1) == " ") spaces++;
            else break;
        }
        return text.substr(spaces);
    }

    // wraps text line at position when close to screen border, specify if line is last and is message ending line
    void wrapText(Message@ msg, string l_text, u16 index, bool message_end, u8 max_offset = 12)
    {
        for (u16 i = 1; i <= max_offset; i++)
        {
            if (i < max_offset)
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
    // TODO: should be implemented in another way to not run when idle
    u16 handleHistory()
    {
        f32 scroll = slider.scrolled;
        u16 lines_outbound = 0;
        f32 total_offset = 0;

        lines = array<string>();
        offsets = array<Vec2f>();
        is_title = array<bool>();

        for (u8 i = 0; i < history.size(); i++)
        {
            Message@ msg = history[i];
            Message@ prev = order_list.size() > 0 && lines_scrolled == 0 ? order_list[0] : null;

            string title = msg.messageText.title;
            u8 title_offset = msg.messageText.title_offset;

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
                    newtext = title;
                    l_pos.y -= title_offset;
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

    // draws history
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

        //GUI::DrawText("out: "+lines_outbound+"\nscrolled: "+scroll+"\nlines scrolled: "+lines_scrolled+"\noffset: "+scroll_offset, tl - Vec2f(170, -20), color_black);
    }

    // start message's text runner
    string writeMessage(Message@ msg)
    {
        if (msg.messageText.playsound)
        {
            Sound::Play("text_write.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), vars.msg_volume_final, vars.msg_pitch_final+XORRandom(11)*0.01f);
        }

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

    // returns the index of last line if line is not specified
    int getLineIndex(Message@ msg)
    {
        return getLineIndex(msg, msg.text_lines.size());
    }

    // returns the index of line in text to show
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