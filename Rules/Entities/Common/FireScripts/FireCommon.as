
#include "Hitters.as"

const string burn_duration = "burn duration";
const string burn_hitter = "burn hitter";

const string burn_timer = "burn timer";

const string burning_tag = "burning";
const string spread_fire_tag = "spread fire";

const int fire_wait_ticks = 4;
const int burn_thresh = 70;

/**
 * Start this's fire and sync everything important
 */
void server_setFireOn(CBlob@ this)
{
	if (!getNet().isServer())
		return;
	this.Tag(burning_tag);
	this.Sync(burning_tag, true);
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

	this.set_s16(burn_timer, this.get_s16(burn_duration) / fire_wait_ticks);
	this.Sync(burn_timer, true);

	if ((this.getCurrentScript().runFlags & Script::tick_infire) != 0)
		this.Tag("had only fire flag");
	this.getCurrentScript().runFlags &= ~Script::tick_infire;
}

/**
 * Put out this's fire and sync everything important
 */
void server_setFireOff(CBlob@ this)
{
	if (!getNet().isServer())
		return;
	this.Untag(burning_tag);
	this.Sync(burning_tag, true);
	this.SetLight(false);

	this.set_s16(burn_timer, 0);
	this.Sync(burn_timer, true);

	if (this.hasTag("had only fire flag"))
		this.getCurrentScript().runFlags |= Script::tick_infire;
}

/**
 * Hitters that should start something burning when hit
 */
bool isIgniteHitter(u8 hitter)
{
	return hitter == Hitters::fire;
}

/**
 * Hitters that should put something out when hit
 */
bool isWaterHitter(u8 hitter)
{
	return hitter == Hitters::water ||
	       hitter == Hitters::water_stun ||
	       hitter == Hitters::water_stun_force;
}



string randomFireTexture(int smokeRandom = 1)
{
	string texture;

	switch (XORRandom(XORRandom(smokeRandom) == 0 ? 4 : 2))
	{
		case 0: texture = "Entities/Effects/Sprites/SmallFire1.png"; break;

		case 1: texture = "Entities/Effects/Sprites/SmallFire2.png"; break;

		case 2: texture = "Entities/Effects/Sprites/SmallSmoke1.png"; break;

		case 3: texture = "Entities/Effects/Sprites/SmallSmoke2.png"; break;
	}
	return texture;
}