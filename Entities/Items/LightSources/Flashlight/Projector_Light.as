
const f32 max_light_radius = 64.0f;
const f32 distance_factor = 4.0f;

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(max_light_radius);
	this.SetLightColor(SColor(255, 225, 200, 150));
	
	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;

	this.addCommandID("sync");

	if (isClient())
	{
		CBitStream params;
		params.write_bool(true);
		params.write_u16(0);
		this.SendCommand(this.getCommandID("sync"), params);
	}
}

void onTick(CBlob@ this)
{
	if (this.get_u16("remote_id") == 0) return;
	CBlob@ follow = getBlobByNetworkID(this.get_u16("remote_id"));
	this.SetLight(follow !is null && follow.isAttached());
	if (follow is null) return;

	f32 rad = Maths::Max(24, max_light_radius - Maths::Abs(follow.getDistanceTo(this) / distance_factor));
	this.SetLightRadius(Maths::Min(max_light_radius, rad));

	if (!isClient()) return;
	if (getMap() is null) return;
	getMap().UpdateLightingAtPosition(this.getOldPosition(), rad+4.0f);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync"))
	{
		bool init = params.read_bool();
		if (init && isServer())
		{
			u16 id = params.read_u16();

			CBitStream nextparams;
			nextparams.write_bool(false);
			nextparams.write_u16(this.get_u16("remote_id"));
			this.SendCommand(this.getCommandID("sync"), nextparams);
		}
		if (!init && isClient())
		{
			u16 id = params.read_u16();
			this.set_u16("remote_id", id);
		}
	}
}