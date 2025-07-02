AddCSLuaFile()

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Blood Laser"
SWEP.Purpose = "Sacrifice Life to deal damage"
SWEP.Instructions = "LMB - Fire Laser\nRMB - Fire Powerful Laser"
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
    self.BeamSecondary = false

    self.StartPos = Vector()
    self.EndPos = Vector()

    if CLIENT then
        self.BeamScale = 1

        hook.Add("PostDrawTranslucentRenderables","Draw_Railgun_Beam"..self:EntIndex(), function()
            if(self.BeamShoot == true) then
                render.SetColorMaterial()
                render.SetMaterial(Material("particle/redblacklargebeam"))

                Col = Color(255,255,255,255)

                if(self.BeamSecondary == true) then
                    Col = Color(255,255,255,255)
                end
                
                render.DrawBeam(self.StartPos,self.EndPos,self.BeamScale,0,1,Col)
            end
        end)
    else -- SERVER
        function TakeDamage(ent,damg,hitpos)
            local direction = (self:GetOwner():GetPos() - ent:GetPos()):GetNormalized()

			if(ent:IsPlayer()) then
				ent:SetVelocity(direction * -500)
			elseif(IsValid(ent:GetPhysicsObject())) then
				ent:GetPhysicsObject():AddVelocity(direction * -500)
			end

            local dmg = DamageInfo()
            dmg:SetDamage(damg)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_DIRECT)

            ent:TakeDamageInfo(dmg)

            if(self.BeamSecondary and hitpos ~= nil) then
                util.BlastDamage(self:GetOwner(),self,hitpos,damg,damg)
            end
        end
    end
end

function SWEP:FireBeam(dmg,bsize,bsizedown,firetime)
    local ply = self:GetOwner()

    timer.Simple(firetime,function()
        local tr = ply:GetEyeTraceNoCursor()

        self.StartPos = ply:EyePos() + ply:GetRight() * 10 + ply:GetUp() * -5
        self.EndPos = tr.HitPos

        if CLIENT then
            self.BeamShoot = true
            self.BeamScale = bsize
        end

        if SERVER then
            if(tr.Entity ~= nil) then
                TakeDamage(tr.Entity,dmg * 3,tr.HitPos)
            end
        end
    end)

    if CLIENT then
        if(self.BeamSecondary == true) then
            beamtime = 3
        else
            beamtime = 1.5
        end

        timer.Simple(beamtime,function()
            self.BeamShoot = false
        end)

        timer.Create("railgun_width"..self:EntIndex(),0.05,100,function()
            if(IsValid(self)) then
                self.BeamScale = math.Clamp(self.BeamScale - bsizedown*2,0,100)
            end
        end)
    end
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime()+1.6)
    self:SetNextSecondaryFire(CurTime()+1.6)
    local ply = self:GetOwner()

    local TakeHP = 10

    self.BeamSecondary = false

    if SERVER then
        timer.Simple(0.4,function()
            TakeDamage(ply,TakeHP)
        end)
    end

    self:EmitSound("railgun_fire.wav",80,100,1)

    self:FireBeam(TakeHP * 3,20,1,0.4)
end

function SWEP:SecondaryAttack()
    self:SetNextPrimaryFire(CurTime()+3.1)
    self:SetNextSecondaryFire(CurTime()+3.1)
    local ply = self:GetOwner()

    local TakeHP = 35

    self.BeamSecondary = true

    if SERVER then
         timer.Simple(1,function()
            TakeDamage(ply,TakeHP)
        end)
    end

    self:EmitSound("blood_laser_secondary.wav",80,100,1)

    self:FireBeam(TakeHP * 3,40,0.5,1)
end

function SWEP:Remove()
    timer.Simple(5,function()
        hook.Remove("PostDrawTranslucentRenderables","Draw_Railgun_Beam"..self:EntIndex())
        timer.Remove("railgun_width")
    end)
end

function SWEP:Drop()
    timer.Simple(5,function()
        hook.Remove("PostDrawTranslucentRenderables","Draw_Railgun_Beam"..self:EntIndex())
        timer.Remove("railgun_width")
    end)
end

timer.Simple(0.1, function() weapons.Register(SWEP,"blood_laser", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused