
void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u8("decay step", 1);
  }

  this.maxQuantity = 30;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
