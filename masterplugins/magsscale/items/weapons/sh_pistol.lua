CSLuaFile()

SWEP.PrintName = ".9mm Pistol"

SWEP.Author = "TheLife"
SWEP.Purpose = "Roleplay"
SWEP.Instructions = "Left click to shoot."
SWEP.Category = "HL2 RP"

SWEP.Spawnable= true
SWEP.AdminOnly = false
SWEP.Drop = false

SWEP.Base = "weapon_base"

SWEP.Primary.Damage = 5
SWEP.Primary.TakeAmmo = 1
SWEP.Primary.ClipSize = 18
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.DefaultClip = 18
SWEP.Primary.Spread = 0.1
SWEP.Primary.NumberofShots = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = .2
SWEP.Primary.Delay = 0.2
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
SWEP.ViewModel			= "models/weapons/c_pistol.mdl"
SWEP.WorldModel			= "models/weapons/w_pistol.mdl"
SWEP.UseHands           = true

SWEP.FiresUnderwater = false

SWEP.CSMuzzleFlashes = true

SWEP.HoldType = "pistol" 
SWEP.AnimPrefix	 = "pistol"

function SWEP:Initialize()
    util.PrecacheSound("weapons/pistol/pistol_fire2.wav") 
    util.PrecacheSound("weapons/pistol/pistol_fire3.wav") 
    util.PrecacheSound("weapons/pistol/pistol_reload1.wav") 
    util.PrecacheSound("weapons/pistol/pistol_empty.wav") 
    self:SetHoldType( self.HoldType )
end 

SWEP.shootSound = "weapons/pistol/pistol_fire2.wav"
SWEP.shootSoundCP = "weapons/pistol/pistol_fire3.wav"
SWEP.reloadSound = "weapons/pistol/pistol_reload1.wav"
SWEP.reloadSoundCP = "weapons/smg1/smg1_reload.wav"
SWEP.emptySound = "weapons/pistol/pistol_empty.wav"

function SWEP:PlayFiringSound()
	local client = self.Owner
	
	local char = client:GetCharacter()
	local firingSound = self.shootSound
	if (char:IsCombine()) then
		firingSound = self.shootSoundCP
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