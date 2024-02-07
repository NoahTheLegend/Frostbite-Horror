namespace Status
{
    enum statuses
    {
        hunger = 0,
        thirst
    };
}

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
    f32 scale;

    u8 id;
    u8 gap;
    

    StatusEffect(string _name, string _description, string _icon, Vec2f _size = Vec2f(32,32))
    {
        name = _name;
        icon = _icon;
        size = _size;
        frame = 0;
        scale = 1;
        description = _description;

        id = 0;
        gap = 8;
    }

};

class StatusHunger : StatusEffect {
    StatusHunger(string _name, string _description, string _icon, Vec2f _size = Vec2f(16,16))
    {
        super(_name, _description, _icon, _size);
        
        this.id = Status::hunger;
        this.scale = 1.5f;
    }
};