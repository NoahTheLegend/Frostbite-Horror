
const f32 min_vol = 0.0f;
const f32 max_vol = 1.0f;
const f32 min_pitch = 0.25f;
const f32 max_pitch = 2.0f;

class ClientVars {
    bool msg_mute;
    f32 msg_volume;
    f32 msg_pitch;

    ClientVars()
    {
        msg_mute = false;
        msg_volume = 0.5f;
        msg_pitch = 1.0f;
    }
};