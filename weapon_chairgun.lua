SWEP.PrintName			= "Warrior Launcher" -- The name of the weapon in the spawn menu and in the weapon selection menu
SWEP.Author			= "SaNMiTTaNz" -- Who made the SWEP
SWEP.Instructions		= "WHY ARE YOU RUNNING?" -- Instructions that the game will show when the we

SWEP.Spawnable = true -- makes it so that the weapon is spawnable
SWEP.AdminOnly = true -- makes sure that only the admin can spawn the item

SWEP.Primary.ClipSize		= -1 -- making the clipsize -1 makes the weapon fire unlimited
SWEP.Primary.DefaultClip	= -1 -- making the default clip size -1 makes it so that it never runs out of ammo
SWEP.Primary.Automatic		= true -- sets the fire rate to automatic
SWEP.Primary.Ammo		= "none" -- ensures that the weapon doesnt use any type of ammo

SWEP.Weight			= 5 -- sets the weight of the weapon to 5 so that the player moves slower
SWEP.AutoSwitchTo		= false -- makes sure that the weapon is not automatically switched to when the player is out of ammo
SWEP.AutoSwitchFrom		= false -- makes sure the weapon is not automatically switched away when the player is out of ammo

SWEP.Slot			= 1 -- sets the slot the SWEP is stored to 1
SWEP.SlotPos			= 2 -- sets the position of the SWEP to 2
SWEP.DrawAmmo			= false -- the ammo is not drawn on the HUD
SWEP.DrawCrosshair		= true -- displays a crosshair

SWEP.ViewModel			= "models/weapons/v_RPG.mdl" -- sets the players view model to an RPG
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl" -- sets the world model to a rocket launcher

local ShootSound = Sound( "click.wav" ) -- sources the sound the weapon makes to a clicking noise

function SWEP:PrimaryAttack() -- when the left mouse button is pressed then run this function below
	self:FireWarrior( "models/player/guerilla.mdl" ) -- fire a warrior from the gun sourcing the model from this filepath
	self.Owner:ViewPunch( Angle( -1, 0, 0 ) ) -- make the screen shake a little bit for recoil effects
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.1 ) -- the weapon will fire once again after 0.1 seconds, in order to retain the automatic fire rate
end -- closes the primary attack function

function SWEP:SecondaryAttack() -- when the right mouse button is pressed run this function below
	self.Weapon:EmitSound( "running.wav" ) -- emit the sound of the running effect from the vine
end -- closes the secondary attack function

function SWEP:FireWarrior( model_file ) -- a custom function to fire the actual warrior
	self:EmitSound( ShootSound ) -- play the shooting sound
	if ( CLIENT ) then return end -- if we are the client with the weapon do the task if not, then we will not do anything based on prediction
	local ent = ents.Create( "prop_physics" ) -- Create a prop_physics entity

	if ( !IsValid( ent ) ) then return end -- make sure that the prop entities are actually created
	ent:SetModel( model_file ) -- Set the entity's model to the passed in model
	ent:SetPos( self.Owner:EyePos() + ( self.Owner:GetAimVector() * 16 ) ) -- Set the position of the entity the player's eye position plus 16 units forward.
	ent:SetAngles( self.Owner:EyeAngles() ) -- Set the angles to the player'e eye angles
	ent:Spawn() -- spawn the object at this position
	local phys = ent:GetPhysicsObject() -- locate the physics object

	if ( !IsValid( phys ) ) then ent:Remove() return end -- Make sure the physics entity is valid, if it is not then do not use it

	local velocity = self.Owner:GetAimVector() -- Velocity vectors to ensure that the object moves instead of just spawning on the ground
	velocity = velocity * 100000 -- how fast we are throwing the warriors
	velocity = velocity + ( VectorRand() * 100 ) -- a random element
	phys:ApplyForceCenter( velocity ) -- apply the force to the center of the object with the selected velocity

	cleanup.Add( self.Owner, "props", ent ) -- add the object to the cleanup entity if we are playing in sandbox
	undo.Create( "Launched_Warrior" ) -- call the object launched warrior
		undo.AddEntity( ent ) -- resets entity
		undo.SetPlayer( self.Owner ) -- resets player
	undo.Finish() -- finishes undoing the command
end -- closes the custom function
