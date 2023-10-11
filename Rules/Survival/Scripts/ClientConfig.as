#define CLIENT_ONLY

#include "ClientVars.as";
#include "Slider.as";
#include "CheckBox.as";

class ConfigMenu {
    Vec2f pos;
    Vec2f dim;

    u8 global_alpha;
    u32 state_change_time;
    u8 state; // closed icon > expand X axis > expand Y axis and vice-versa

    Vec2f tl;
    Vec2f br;
    Section[] sections;

    ConfigMenu(Vec2f _pos, Vec2f _dim)
    {
        pos = _pos;
        dim = _dim;

        tl = pos;
        br = pos+dim;

        global_alpha = 0;
        state_change_time = 0;
        state = 0;
    }

    void addSection(Section@ section)
    {
        sections.push_back(section);
    }

    bool hover(Vec2f mpos, Vec2f etl, Vec2f ebr)
    {
        return mpos.x >= etl.x && mpos.x <= ebr.x
            && mpos.y >= etl.y && mpos.y <= ebr.y;
    }

    void render()
    {
        CControls@ controls = getControls();
        if (controls is null) return;

        Vec2f mpos = controls.getInterpMouseScreenPos();

        if (state == 0)
        {
            Vec2f btn_dim = Vec2f(32,32);

            bool hovering = hover(mpos, tl, tl+btn_dim);

            if (hovering && (controls.isKeyPressed(KEY_LBUTTON) || controls.isKeyPressed(KEY_RBUTTON)))
                state = 1;

            GUI::DrawPane(tl, tl+btn_dim, SColor(hovering?200:100,255,255,255));
            GUI::DrawIcon("SettingsMenuIcon.png", 0, btn_dim, tl, 0.5f, 0.5f, SColor(hovering?200:100,255,255,255));

            global_alpha = 0;
        }
        else if (state == 1 || state == 3) // 1 opening, 3 closing
        {
            // todo: open anim
            if (state == 1)
            {
                state = 2;
            }
            else
            {
                getRules().Tag("update_clientvars");
                state = 0;
            }
        }
        else
        {
            GUI::DrawPane(tl, br, SColor(155,255,255,255));

            bool hovering = hover(mpos, br, br+Vec2f(32,32)); // todo, close button
            if (hovering && (controls.isKeyPressed(KEY_LBUTTON) || controls.isKeyPressed(KEY_RBUTTON)))
                state = 3;

            global_alpha = Maths::Min(255, global_alpha+25);
            for (u8 i = 0; i < sections.size(); i++)
            {
                sections[i].render(global_alpha);
            }
        }
    }
};

class Section {
    string title;
    Vec2f pos;
    Vec2f dim;
    Vec2f padding;

    Vec2f tl;
    Vec2f br;
    Option[] options;

    Section(string _title, Vec2f _pos, Vec2f _dim)
    {
        title = _title;
        pos = _pos;
        dim = _dim;

        tl = pos;
        br = pos+dim;
        padding = Vec2f(15, 10);
    }

    void addOption(Option@ option)
    {
        options.push_back(option);
    }

    void render(u8 alpha)
    {
        SColor col_white = SColor(alpha,255,255,255);
        SColor col_grey = SColor(alpha,235,235,235);

        GUI::DrawPane(tl, br, SColor(55,255,255,255));
        {
            GUI::SetFont("RockwellMT-Bold_18");
            GUI::DrawText(title, pos+padding, col_white);
        }
        GUI::DrawRectangle(tl+padding + Vec2f(0,28), Vec2f(br.x-padding.x, tl.y+padding.y + 30), col_grey);
        
        for (u8 i = 0; i < options.size(); i++)
        {
            options[i].render(alpha);
        }
    }
};

class Option {
    string text;
    Vec2f pos;
    bool has_slider;
    f32 slider_startpos;
    bool has_check;

    Slider slider;
    CheckBox check;

    Option(string _text, Vec2f _pos, bool _has_slider, bool _has_check)
    {
        text = _text;
        pos = _pos;
        has_slider = _has_slider;
        has_check = _has_check;
        slider_startpos = 0.5f;

        if (has_slider)
        {
            slider = Slider("option_slider", pos+Vec2f(0,23), Vec2f(100,15), Vec2f(15,15), Vec2f(8,8), slider_startpos, 0);
        }
        if (has_check)
            check = CheckBox(false, pos+Vec2f(0,1), Vec2f(18,18));
    }

    void setSliderPos(f32 scroll)
    {
        slider.setScroll(scroll);
    }

    void setCheck(bool flagged)
    {
        check.state = flagged;
    }

    void render(u8 alpha)
    {
        SColor col_white = SColor(alpha,255,255,255);
        if (has_slider)
        {
            slider.render(alpha);
            GUI::DrawText((Maths::Round(slider.scrolled*100))+"%", slider.pos+slider.dim+Vec2f(10,-18), col_white);
        }
        if (has_check)
        {
            check.render(alpha);
        }
        
        {
            GUI::SetFont("RockwellMT_14");
            GUI::DrawText(text, has_check?pos+Vec2f(25,0):pos, col_white);
        }
    }
};