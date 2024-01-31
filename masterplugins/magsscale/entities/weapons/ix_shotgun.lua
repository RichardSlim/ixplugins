AddCSLuaFile()

SWEP.PrintName = "Spas 12 Shotgun"

SWEP.Author = "Mags"
SWEP.Purpose = "Roleplay"
SWEP.Instructions = "Left click to fire. Right click to shoot a grenade."
SWEP.Category = "HL2 RP"

SWEP.Spawnable= true
SWEP.AdminOnly = false
SWEP.Drop = false

SWEP.Base = "weapon_base"

SWEP.Primary.Damage = 30
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 18
SWEP.Primary.Ammo = "shotgun"
SWEP.Primary.DefaultClip = 35
SWEP.Primary.Spread = 0.2
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Recoil = 10
SWEP.Primary.Delay = 0.1
SWEP.Primary.Force = 2

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= ""

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = true
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 60
SWEP.ViewModel			= "models/weapons/c_shotgun.mdl"
SWEP.WorldModel			= "models/weapons/w_shotgun.mdl"
SWEP.UseHands           = true

SWEP.FiresUnderwater = false

SWEP.CSMuzzleFlashes = true

SWEP.HoldType = "shotgun" 
SWEP.AnimPrefix	 = "shotgun"

function SWEP:Initialize()
    util.PrecacheSound("weapons/shotgun/shotgun_fire6.wav") 
    util.PrecacheSound("weapons/shotgun/shotgun_fire7.wav") 
    util.PrecacheSound("weapons/shotgun/shotgun_reload3.wav") 
    util.PrecacheSound("weapons/shotgun/shotgun_empty.wav
") 
    self:SetHoldType( self.HoldType )
end 

SWEP.shootSound = "weapons/shotgun/shotgun_fire6.wav"
SWEP.shootSoundCP = "weapons/shotgun/shotgun_fire6.wav"
SWEP.reloadSound = "weapons/shotgun/shotgun_reload1.wav"
SWEP.reloadSoundCP = "weapons/shotgun/shotgun_reload1.wav"
SWEP.emptySound = "weapons/shotgun/shotgun_empty.wav"

function SWEP:PlayFiringSound()
	local client = self.Owner
	
	local char = client:GetCharacter()
	local firingSound = nil
	if (char:IsCombine()) then
		firingSound = self.shootSoundCP
    else
        firingSound = self.shootSound
    end
	
	self:EmitSound(firingSound, 75, 100, 1, CHAN_WEAPON, 0, 1)
end

function SWEP:PrimaryAttack()
    
    if ( !self:CanPrimaryAttack() ) then return end

    if (!self.Owner:IsWepRaised()) then
		return
	end

    local bullet = {} 
    bullet.Num = self.Primary.NumberofShots 
    bullet.Src = self.Owner:GetShootPos() 
    bullet.Dir = self.Owner:GetAimVector() 
    bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
    bullet.Tracer = 1
    bullet.Force = self.Primary.Force 
    bullet.Damage = self.Primary.Damage 
    bullet.AmmoType = self.Primary.Ammo 
    
    local rnda = self.Primary.Recoil * -1 
    local rndb = self.Primary.Recoil * math.random(-1, 1) 
    
    self:ShootEffects()
    
    self.Owner:FireBullets( bullet ) 
	self:PlayFiringSound()
    self.Owner:ViewPunch( Angle( rnda,rndb,rnda ) ) 
    self:TakePrimaryAmmo(self.Primary.TakeAmmo) 
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay * math.random(1, 1.2) ) 
    
end 

function SWEP:SecondaryAttack()

end

function SWEP:Reload()
	local ammo = self.Owner:GetAmmoCount(self.Primary.Ammo)
	local clip = self:Clip1()
	
	local client = self.Owner
	
	local char = client:GetCharacter()
	local reloadSound = self.reloadSound
	if (char:IsCombine()) then
		reloadSound = self.reloadSoundCP
	end
	
	if (ammo <= 0) then return end
	
	if (clip >= self.Primary.ClipSize) then return end

	self:EmitSound(reloadSound, 75, 100, 1, CHAN_WEAPON, 0, 1)
    self.Weapon:DefaultReload( ACT_VM_RELOAD );
	
end