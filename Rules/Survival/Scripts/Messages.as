
class Message
{
    string text;
    bool playsound;
    u16 max_length;

    Message(string _text, bool _playsound = true, u16 _max_length = 255);
    {
        text = _text;
        playsound = _playsound;
        max_length = _max_length;
    }

    bool ended()
    {

    }
}

class MessageBox
{
    u8 pos_type;
    Vec2f dim;
    u8 max_size;

    MessageBox(u8 _pos_type, Vec2f _dim, u8 _max_size)
    {
        pos_type = _pos_type;
        dim = _dim;
        max_size = _max_size;
    }

    Message[] order_list;
    Message[] history;

    void render()
    {

    }
}