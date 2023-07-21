void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(128.0f);
	this.SetLightColor(SColor(255, 255, 230, 180));
	
	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;
}