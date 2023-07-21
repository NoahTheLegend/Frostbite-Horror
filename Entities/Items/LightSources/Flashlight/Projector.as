const f32 max_distance = 256.0f;

void onInit(CBlob@ this)
{
	this.Tag("no shitty rotation reset");

	//this.SetLight(true);
	//this.SetLightRadius(96.0f);
	//this.SetLightColor(SColor(255, 180, 230, 255));

	makeLight(this);
}

void makeLight(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ blob = server_CreateBlobNoInit("projector_light");
		blob.set_u16("remote_netid", this.getNetworkID());
		blob.setPosition(this.getPosition());

		blob.Init();

		this.set_u16("remote_netid", blob.getNetworkID());
	}
}

void onTick(CBlob@ this)
{
	// TODO: decrease light radius and transparency depending on the distance;
	if (isServer())
	{
		if (this.getVelocity() != Vec2f_zero || this.isAttached()) //only tick if moving 
		{
			bool flip = this.isFacingLeft();
			f32 angle = this.getAngleDegrees();

			Vec2f hitPos;
			Vec2f dir = Vec2f((flip ? -1 : 1), 0.0f).RotateBy(angle);
			Vec2f startPos = this.getPosition();
			Vec2f endPos = startPos + dir * max_distance;

			HitInfo@[] hitInfos;
			bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
			f32 length = (hitPos - startPos).Length();
			bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (flip ? 180.0f : 0.0f), length, this, @hitInfos);

			CBlob@ light = getBlobByNetworkID(this.get_u16("remote_netid"));
			if (light !is null)
			{
				light.setPosition(hitPos);
			}
		}

		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		if (holder !is null)
		{
			this.setAngleDegrees(getAimAngle(this, holder));
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	onDie(this);
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	makeLight(this);
}

void onDie(CBlob@ this)
{
	CBlob@ light = getBlobByNetworkID(this.get_u16("remote_netid"));
	if (light !is null) light.server_Die();
}

f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
	Vec2f aimvector = holder.getAimPos() - (this.hasTag("place45") /*&& this.hasTag("a1"))*/ ? holder.getInterpolatedPosition() : this.getInterpolatedPosition());
	f32 angle = holder.isFacingLeft() ? -aimvector.Angle() + 180.0f : -aimvector.Angle();
	if (holder.isAttached()) this.SetFacingLeft(holder.isFacingLeft());
	return angle;
}