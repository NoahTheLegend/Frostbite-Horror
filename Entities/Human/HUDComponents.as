const u8 hud_transparency = 160;

void InitTemperatureComponent(CBlob@ this)
{
    this.set_f32("body_temperature", 0);
}

void UpdateTemperature(CBlob@ this)
{
    
}

bool was_lmb = false;
bool temperature_hidden = false;
f32 temperature_last_hidden_offset = 0;
u8 temperature_last_text_alpha = 255;

void DrawTemperature(CSprite@ this) // hardcoded because meh
{
	CBlob@ blob = this.getBlob();
    if (blob is null || !blob.isMyPlayer()) return;

    CRules@ rules = getRules();
    if (rules is null) return;

    CControls@ controls = getControls();
    if (controls is null) return;
    Vec2f mpos = controls.getMouseScreenPos();

    u16 width = getDriver().getScreenWidth();
    u16 height = getDriver().getScreenHeight();

    f32 canvas_width = 145;
    u8 canvas_hidden_width = 10;

    f32 hide_offset = Maths::Lerp(temperature_last_hidden_offset, temperature_hidden ? canvas_width-canvas_hidden_width : 0, 0.1f);
    temperature_last_hidden_offset = hide_offset;
    if (hide_offset <= 1) hide_offset = Maths::Round(hide_offset);

    // bottom left corner
    Vec2f cdim = Vec2f(canvas_width-hide_offset, 200); // canvas dimensions
    Vec2f drawpos = Vec2f(-10-hide_offset, height-200);
    Vec2f t_drawpos = Vec2f(10-hide_offset, height - 180);
    Vec2f temperature_text_offset = drawpos+Vec2f(110, 25);

    if (mouseHover(mpos, drawpos, Vec2f(cdim.x, height)))
    {
        if (controls.isKeyPressed(KEY_LBUTTON))
        {
            if (!was_lmb)
            {
                was_lmb = true;
                temperature_hidden = !temperature_hidden;
            }
        }
        else was_lmb = false;
    }

    f32 global_temperature = rules.get_f32("temperature");
    f32 global_temperature_f = (global_temperature * 9.0f/5.0f) + 32.0f;
    f32 gauge_shift = Maths::Abs(global_temperature/75.0f);
    f32 gauge_offset = 25.0f + gauge_shift * 10.0f;

    global_temperature = Maths::Round(global_temperature*100)/100;
    global_temperature_f = Maths::Round(global_temperature_f*100)/100;

    SColor color_global = SColor(255,100,100,200);
    SColor color_body = SColor(255,215,100,25);

    // canvas
    GUI::DrawPane(Vec2f(drawpos.x, height-cdim.y), Vec2f(cdim.x, height+15), SColor(hud_transparency,255,255,255));
    if (hide_offset >= canvas_width-canvas_hidden_width-1) return;

    // details
    if (cdim.x > 70)
    {
        // global temperature
        GUI::DrawPane(Vec2f(70, height-cdim.y+10), Vec2f(cdim.x-10, height-146), SColor(hud_transparency,255,255,255));
        GUI::DrawFramedPane(Vec2f(cdim.x-15, height-cdim.y+5), Vec2f(cdim.x, height-140));

        // body temperature
        GUI::DrawPane(Vec2f(70, height-cdim.y+150), Vec2f(cdim.x-10, height-6), SColor(hud_transparency,255,255,255));
        GUI::DrawFramedPane(Vec2f(cdim.x-15, height-cdim.y+145), Vec2f(cdim.x, height));
    }
    // indicators
    GUI::DrawPane(t_drawpos-Vec2f(10,10), t_drawpos+Vec2f(24,85)*2+Vec2f(10,10), SColor(hud_transparency,255,255,255)); // background
    GUI::DrawIcon("Thermometer.png", 2, Vec2f(24, 85*(1.0f-gauge_shift)), t_drawpos + Vec2f(0, gauge_offset+85*gauge_shift), 1.0f, 0.55f, color_global); // global temperature
    GUI::DrawIcon("Thermometer.png", 1, Vec2f(24, 85), t_drawpos, 1.0f, 1.0f, color_body); // body temperature
    GUI::DrawIcon("Thermometer.png", 0, Vec2f(24, 85), t_drawpos, 1.0f); // icon
    GUI::DrawText("°F        °C", t_drawpos + Vec2f(-2, 6), SColor(255,0,0,0)); // metrics
    // arrows
    s8 rate = blob.get_s8("temperature_rate");
    rate = 0;
    
    u8 icon = 0;
    SColor color_arrows = SColor(255,100,100,100);
    if (rate != 0)
    {
        icon = rate < 0 ? Maths::Abs(rate)+3 : rate;
        color_arrows = rate < 0 ? color_global : color_body;
    }
    GUI::DrawIcon("WideArrows.png", icon, Vec2f(32,48), t_drawpos+Vec2f(60, 34), 1.0f, 1.0f, color_arrows); // global temperature
    // text
    if (hide_offset > 1)
    {
        temperature_last_text_alpha = 0;
        return;
    }
    u8 text_alpha = Maths::Lerp(temperature_last_text_alpha, 255, 0.25f);
    temperature_last_text_alpha = text_alpha;

    GUI::SetFont("CascadiaCodePL_12");
    GUI::DrawTextCentered(global_temperature+"°C", temperature_text_offset, SColor(text_alpha,255,255,255));
    GUI::DrawTextCentered(global_temperature_f+"°F", temperature_text_offset+Vec2f(0,12), SColor(text_alpha,255,255,255));
}