void InitTemperatureComponent(CBlob@ this)
{
    this.set_f32("temperature", 0);
}

void UpdateTemperature(CBlob@ this)
{
    
}

void DrawTemperature(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
    if (blob is null || !blob.isMyPlayer()) return;

    f32 temperature = blob.get_f32("temperature");
    int width = getDriver().getScreenWidth();
    int height = getDriver().getScreenHeight();

    Vec2f drawpos = Vec2f(16, height - 185);
    GUI::DrawIcon("Thermometer.png", 0, Vec2f(24, 85), drawpos, 1.0f);
}