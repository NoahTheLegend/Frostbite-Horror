
const StatusEffect@[] status_collection = {
    @StatusHunger("Hunger", "Your energy.\nGenerates heat and heal whilen saturated.", "Hunger.png")
};

StatusEffect getStatus(u8 id)
{
    StatusEffect status = status_collection[id];
    return status;
}

StatusEffect makeStatus(string name, string description = "", string icon = "", Vec2f size = Vec2f(32,32))
{
    return StatusEffect(name, description, icon, size);
}

class StatusEffect {
    string name;
    string description;

    string icon;
    Vec2f size;
    u8 frame;
    
    u8 id;
    f32 gap;

    StatusEffect(string _name, string _description, string _icon, Vec2f _size = Vec2f(32,32))
    {
        name = _name;
        icon = _icon;
        frame = 0;
        description = _description;
    }
};

class StatusHunger : StatusEffect {
    StatusHunger(string _name, string _description, string _icon, Vec2f _size = Vec2f(32,32))
    {
        super(_name, _description, _icon, _size);
    }
};