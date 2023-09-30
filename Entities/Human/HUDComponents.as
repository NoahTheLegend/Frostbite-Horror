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

void DrawTemperature(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    if (blob is null || !blob.isMyPlayer()) return;

    CRules@ rules = getRules();
    if (rules is null) return;

    CControls@ controls = getControls();
    if (controls is null) return;
    Vec2f mpos = controls.getMouseScreenPos();

    int width = getDriver().getScreenWidth();
    int height = getDriver().getScreenHeight();

    f32 canvas_width = 130;
    f32 h_offset = Maths::Lerp(temperature_last_hidden_offset, temperature_hidden ? canvas_width-10 : 0, 0.1f);
    temperature_last_hidden_offset = h_offset;
    if (h_offset <= 1) h_offset = Maths::Floor(h_offset);

    // bottom left corner
    Vec2f cdim = Vec2f(canvas_width-h_offset, 200); // canvas dimensions
    Vec2f drawpos = Vec2f(-10-h_offset, height-200);
    Vec2f t_drawpos = Vec2f(10-h_offset, height - 180);
    Vec2f temperature_text_offset = drawpos+Vec2f(97.5f, 25);

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
    f32 gauge_shift = Maths::Abs(global_temperature/100.0f);
    f32 gauge_offset = 25.0f + gauge_shift * 10.0f;

    global_temperature = Maths::Round(global_temperature*100)/100;
    global_temperature_f = Maths::Round(global_temperature_f*100)/100;

    SColor color_global = SColor(255,100,100,200);
    SColor color_body = SColor(255,215,100,25);

    // canvas
    GUI::DrawPane(Vec2f(drawpos.x, height-cdim.y), Vec2f(cdim.x, height+15), SColor(hud_transparency,255,255,255));
    // details
    if (cdim.x > 60) GUI::DrawPane(Vec2f(60, height-cdim.y+10), Vec2f(cdim.x-10, height-146), SColor(hud_transparency,255,255,255));
    GUI::DrawFramedPane(Vec2f(cdim.x-15, height-cdim.y+5), Vec2f(cdim.x, height-140));
    // indicators
    GUI::DrawIcon("Thermometer.png", 2, Vec2f(24, 85*(1.0f-gauge_shift)), t_drawpos + Vec2f(0, gauge_offset+85*gauge_shift), 1.0f, 0.55f, color_global); // global temperature
    GUI::DrawIcon("Thermometer.png", 1, Vec2f(24, 85), t_drawpos, 1.0f, 1.0f, color_body); // body temperature
    GUI::DrawIcon("Thermometer.png", 0, Vec2f(24, 85), t_drawpos, 1.0f); // icon
    
    if (h_offset > 1)
    {
        temperature_last_text_alpha = 0;
        return;
    }
    // text
    u8 text_alpha = Maths::Lerp(temperature_last_text_alpha, 255, 0.25f);
    temperature_last_text_alpha = text_alpha;

    GUI::SetFont("CascadiaCodePL_12");
    GUI::DrawTextCentered(global_temperature+"°C", temperature_text_offset, SColor(text_alpha,255,255,255));
    GUI::DrawTextCentered(global_temperature_f+"°F", temperature_text_offset+Vec2f(0,12), SColor(text_alpha,255,255,255));
}