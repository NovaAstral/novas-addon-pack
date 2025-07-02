AddCSLuaFile()

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Railgun"
SWEP.Purpose = "Pew Pew"
SWEP.Instructions = "LMB - Fire"
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

    self.BeamShoot = false

    self.StartPos = Vector()
    self.EndPos = Vector()

    if CLIENT then
        self.BeamScale = 20

        hook.Add("PostDrawTranslucentRenderables","Draw_Railgun_Beam"..self:EntIndex(), function()
            if(self.BeamShoot == true) then
                render.SetColorMaterial()
                render.SetMaterial(Material("effects/blueblacklargebeam"))
                
                render.DrawBeam(self.StartPos,self.EndPos,self.BeamScale,0,1)
            end
        end)
    else -- SERVER
        function TakeDamage(ent)
            local direction = (self:GetOwner():GetPos() - ent:GetPos()):GetNormalized()

			if(ent:IsPlayer()) then
				ent:SetVelocity(direction * -500)
			elseif(IsValid(ent:GetPhysicsObject())) then
				ent:GetPhysicsObject():AddVelocity(direction * -500)
			end

            local dmg = DamageInfo()
            dmg:SetDamage(50)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_DIRECT)

            ent:TakeDamageInfo(dmg)
        end
    end
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime()+1.6)
    local ply = self:GetOwner()

    self.BeamScale = 20

    self:EmitSound("railgun_fire.wav",80,100,1)

    timer.Simple(0.5,function()
        local tr = ply:GetEyeTraceNoCursor()

        self.StartPos = ply:EyePos() + ply:GetRight() * 10 + ply:GetUp() * -5
        self.EndPos = tr.HitPos

        self.BeamShoot = true

        if SERVER then
            if(tr.Entity ~= nil) then
                TakeDamage(tr.Entity)
            end
        end
    end)
    
    timer.Simple(1.5,function()
        self.BeamShoot = false
    end)

    if CLIENT then
        timer.Create("railgun_width"..self:EntIndex(),0.05,20,function()
            self.BeamScale = self.BeamScale - 1
        end)
    end
end

function SWEP:Remove()
    hook.Remove("PostDrawTranslucentRenderables","Draw_Railgun_Beam"..self:EntIndex())
    timer.Remove("railgun_width")
end

function SWEP:Drop()
    hook.Remove("PostDrawTranslucentRenderables","Draw_Railgun_Beam"..self:EntIndex())
    timer.Remove("railgun_width")
end

timer.Simple(0.1, function() weapons.Register(SWEP,"nova_railgun", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused