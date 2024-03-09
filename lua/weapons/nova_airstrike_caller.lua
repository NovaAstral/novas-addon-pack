AddCSLuaFile()

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Airstrike Caller"
SWEP.Purpose = "Call in the rain"
SWEP.Instructions = "LMB - Call Airstrike"
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
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
SWEP.ViewModel = "models/weapons/v_toolgun.mdl"

SWEP.Category = "Nova's Weapons"

function SWEP:CanPrimaryAttack() return false end
function SWEP:CanSecondaryAttack() return false end
function SWEP:Holster() return true end
function SWEP:ShouldDropOnDie() return false end

function SWEP:Initialize()
    if(self.SetHoldType) then
		self:SetHoldType("pistol")
	end

	self:DrawShadow(false)
end

if SERVER then
	function SWEP:PrimaryAttack()
        self:SetNextPrimaryFire(CurTime()+1)
        self:SetNextSecondaryFire(CurTime()+1)

		local ply = self:GetOwner()

		if(not IsValid(ply)) then return end

        tr = ply:GetEyeTrace()
        hitpos = tr.HitPos

        for I = 1,10 do
            local ent = ents.Create("nova_contact_bomb")
            ent:Initialize()
            local Phys = ent:GetPhysicsObject()

            ent:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
            ent:SetPos(hitpos + Vector(math.random(-1000,1000),math.random(-1000,1000),5000))

            ent:ActivateBomb()

            if(IsValid(Phys)) then
                Phys:SetVelocity(Vector(0,0,-10000))
            end

            timer.Simple(10,function() --incase it gets stuck on something and doesn't explode
                if(IsValid(ent)) then
                    ent:Remove()
                end
            end)
        end
	end
end

if(CLIENT)then
	local matScreen = Material("models/weapons/v_toolgun/screen")
    local rtTexture = GetRenderTarget("GModToolgunScreen",256,256)

    surface.CreateFont("AirStrikeFont",{
        font = "Helvetica",
        size = 40,
        weight = 900
    })

    function SWEP:RenderScreen()
        matScreen:SetTexture("$basetexture",rtTexture)

        local oldRT = render.GetRenderTarget()

        render.SetViewPort(0,0,ScrW(),ScrH())
        render.PushRenderTarget(rtTexture)

        cam.Start2D()
            surface.SetDrawColor(Color(100,100,100))
            surface.DrawRect(0,0,256,256)
            self:drawShadowedText("Air Strike",128,110,"AirStrikeFont")
            self:drawShadowedText("Caller",128,145,"AirStrikeFont")
        cam.End2D()

        render.SetRenderTarget(oldRT)
        render.SetViewPort(0,0,ScrW(),ScrH())
        render.PopRenderTarget()
    end

    function SWEP:drawShadowedText(text, x, y, font)
        draw.SimpleText( text, font, x + 3, y + 3, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText( text, font, x , y , Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

timer.Simple(0.1, function() weapons.Register(SWEP,"nova_airstrike_caller", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused