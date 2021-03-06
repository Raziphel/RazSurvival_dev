#include "WizardCommon.as";

void onInit( CBlob@ this )
{
	this.set_u32("last teleport", 0 );
	this.set_bool("teleport ready", true );
}


void onTick( CBlob@ this ) 
{	
	bool ready = this.get_bool("teleport ready");
	const u32 gametime = getGameTime();
	
	if(ready) {
		if(this.isKeyJustPressed( key_action2 )) {
			Vec2f delta = this.getPosition() - this.getAimPos();
			if(delta.Length() < TELEPORT_DISTANCE){
				this.set_u32("last teleport", gametime);
				this.set_bool("teleport ready", false );
				SummonElemental(this, this.getAimPos());
			} else if(this.isMyPlayer()) {
				Sound::Play("option.ogg");
			}
		}
	} else {		
		u32 lastTeleport = this.get_u32("last teleport");
		int diff = gametime - (lastTeleport + TELEPORT_FREQUENCY);
		
		if(this.isKeyJustPressed( key_action2 ) && this.isMyPlayer()){
			Sound::Play("Entities/Characters/Sounds/NoAmmo.ogg");
		}

		if (diff > 0)
		{
			this.set_bool("teleport ready", true );
			this.getSprite().PlaySound("/Cooldown1.ogg"); 
		}
	}
}

void SummonElemental( CBlob@ this, Vec2f aimpos)	
{	
	CBlob@[] raven_blobs;
	getBlobsByName("raven", @raven_blobs );
	u8 num_raven = raven_blobs.length;
	
	if (getNet().isServer())
	{
		if(num_raven<1)
		{
			server_CreateBlob( "raven", 0, this.getPosition() );
		}
	}

	//whoosh, teleport us
	ParticleAnimated( "MagicSmoke.png", this.getPosition(), Vec2f(0,0), 0.0f, 1.0f, 1.5, -0.1f, false );
	this.getSprite().PlaySound("Thunder2.ogg");
    this.setPosition( aimpos );
    this.setVelocity( Vec2f_zero );
	ParticleAnimated( "MagicSmoke.png", this.getPosition(), Vec2f(0,0), 0.0f, 1.0f, 1.5, -0.1f, false );          
    this.getSprite().PlaySound("/Respawn.ogg");
}
