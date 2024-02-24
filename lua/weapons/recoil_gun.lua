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
            self:drawShadowedText("Recoil",128,110,"TFBridgeController")
            self:drawShadowedText("Gun",128,145,"TFBridgeController")
        cam.End2D()

        render.PopRenderTarget()
        render.PushRenderTarget(oldRT,0,0,ScrW(),ScrH())
        
    end

    function SWEP:drawShadowedText(text, x, y, font)
        draw.SimpleText( text, font, x + 3, y + 3, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText( text, font, x , y , Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

timer.Simple(0.1, function() weapons.Register(SWEP,"recoil_gun", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused