AddCSLuaFile()

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Rocket Jumper"
SWEP.Purpose = "Weeeeeee"
SWEP.Instructions = "LMB - Fire Rocket"
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

        local direction = ply:GetAimVector()

        local ent = ents.Create("jumper_rocket")
        ent:Initialize()
        ent:SetPos(ply:EyePos()) --x23.5, y12, z-3 | y0 if its the original
        ent.Active = true

        local Phys = ent:GetPhysicsObject()

        if(IsValid(Phys)) then
            Phys:EnableGravity(false)
            Phys:SetVelocity(ply:GetVelocity() + direction * 1100)
        end
	end
end

if(CLIENT)then
	local matScreen = Material("models/weapons/v_toolgun/screen")
    local rtTexture = GetRenderTarget("GModToolgunScreen",256,256)

    surface.CreateFont("TFBridgeController",{
        font = "Helvetica",
        size = 40,
        weight = 900
    })

    function SWEP:RenderScreen()
        matScreen:SetTexture("$basetexture",rtTexture)

        local oldRT = render.GetRenderTarget()

        render.PushRenderTarget(rtTexture,0,0,256,256)

        cam.Start2D()
            surface.SetDrawColor(Color(100,100,100))
            surface.DrawRect(0,0,256,256)
            self:drawShadowedText("Rocket",128,110,"TFBridgeController")
            self:drawShadowedText("Jumper",128,145,"TFBridgeController")
        cam.End2D()

        render.PopRenderTarget()
        render.PushRenderTarget(oldRT,0,0,ScrW(),ScrH())
        
    end

    function SWEP:drawShadowedText(text, x, y, font)
        draw.SimpleText( text, font, x + 3, y + 3, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText( text, font, x , y , Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

timer.Simple(0.1, function() weapons.Register(SWEP,"rocket_jumper", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused