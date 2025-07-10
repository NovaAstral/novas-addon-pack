AddCSLuaFile()

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Deadmans Switch"
SWEP.Purpose = "kaboom :333"
SWEP.Instructions = "LMB - Turn On\nRMB - Turn Off"
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

SWEP.Category = "Nova's Weapons"

function SWEP:DrawWorldModel() end
function SWEP:DrawWorldModelTranslucent() end
function SWEP:CanPrimaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end
function SWEP:Holster() return true end
function SWEP:ShouldDropOnDie() return false end
function SWEP:PreDrawViewModel() return true end -- This stops it from displaying as a pistol in your hands

function SWEP:Initialize()
    if(self.SetHoldType) then
		self:SetHoldType("normal")
	else
		self:SetWeaponHoldType("normal") -- This makes your arms go to your sides
	end

	self:DrawShadow(false)

    self.Active = false
end

function SWEP:ActivateSwitch(on)
    if(on == true and self.Active == false) then
        self.Active = true

        local ply = self.Owner

        hook.Add("DoPlayerDeath","DeadmansSwitchDeath"..self:EntIndex(),function(victim,inflictor,attacker)
            if(victim == ply and self.Active == true) then
                ply:EmitSound("phx/explode06.wav",80,100,1)

                ply:SetVelocity(Vector(0,0,100))

                util.BlastDamage(ply,ply,ply:GetPos(),500,200)
                
                local effectdata = EffectData()
                effectdata:SetOrigin(ply:GetPos())
                effectdata:SetStart(ply:GetPos())
                effectdata:SetScale(20)
                util.Effect("HelicopterMegaBomb", effectdata)

                hook.Remove("DoPlayerDeath","DeadmansSwitchDeath"..self:EntIndex())

                timer.Simple(1,function()
                    
                end)
            end
        end)
    end

    if(on == false and self.Active == true) then
        self.Active = false

        hook.Remove("DoPlayerDeath","DeadmansSwitchDeath"..self:EntIndex())
    end
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime()+0.5)
    self:SetNextSecondaryFire(CurTime()+0.5)
    
    if(self.Active ~= false) then return end

    self:ActivateSwitch(true)
    self:EmitSound("buttons/button9.wav")
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime()+0.5)
    self:SetNextPrimaryFire(CurTime()+0.5)

    if(self.Active ~= true) then return end

    self:ActivateSwitch(false)
    self:EmitSound("buttons/button8.wav")
end

function SWEP:Remove()
    hook.Remove("DoPlayerDeath","DeadmansSwitchDeath"..self:EntIndex())
end

function SWEP:Drop()
    hook.Remove("DoPlayerDeath","DeadmansSwitchDeath"..self:EntIndex())
end

timer.Simple(0.1, function() weapons.Register(SWEP,"deadmans_switch", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused