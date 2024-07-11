AddCSLuaFile()

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Recoil Gun"
SWEP.Purpose = "Weeeeeeeeee"
SWEP.Instructions = "LMB - Yeet yourself\nRMB - Yeet yourself harder"
SWEP.DrawCrosshair = true
SWEP.SlotPos = 10
SWEP.Slot = 3
SWEP.Spawnable = true
SWEP.Weight = 1
SWEP.HoldType = "normal"
SWEP.Primary.Ammo = "none" --This stops it from giving pistol ammo when you get the swep
SWEP.Primary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = true
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.ViewModel = "models/weapons/v_shotgun.mdl"

SWEP.Category = "Nova's Weapons"

function SWEP:CanPrimaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end
function SWEP:Holster() return true end
function SWEP:ShouldDropOnDie() return false end

function SWEP:Initialize()
    if(self.SetHoldType) then
		self:SetHoldType("shotgun")
	end

	self:DrawShadow(false)
end

if SERVER then
	function SWEP:PrimaryAttack()
        self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) --this might not work? --ACT_VM_SECONDARYATTACK
        self:SetNextPrimaryFire(CurTime()+1)
        self:SetNextSecondaryFire(CurTime()+1)

		local ply = self:GetOwner()

		if(not IsValid(ply)) then return end

        ply:SetVelocity(-ply:GetAimVector() * 1100)
	end

    function SWEP:SecondaryAttack()
        self:SetNextPrimaryFire(CurTime()+1)
        self:SetNextSecondaryFire(CurTime()+1)

		local ply = self:GetOwner()

		if(not IsValid(ply)) then return end

        ply:SetVelocity(-ply:GetAimVector() * 2200)
    end
end

timer.Simple(0.1, function() weapons.Register(SWEP,"recoil_gun", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused