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
    Message msg(text, "", 4, true && !areMessagesMuted(), 255, 1);
    addMessage(msg);
}

void addMessage(string text, string title)
{
    Message msg(text, title, 4, true && !areMessagesMuted(), 255, 1);
    addMessage(msg);
}

void addMessage(string text, string title, u8 title_offset, bool playsound, u16 length, u8 delay)
{
    Message msg(text, title, title_offset, playsound && !areMessagesMuted(), length, delay);
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

bool hover(Vec2f mpos, Vec2f tl, Vec2f br)
{
    return mpos.x >= tl.x && mpos.x <= br.x
        && mpos.y >= tl.y && mpos.y <= br.y;
}