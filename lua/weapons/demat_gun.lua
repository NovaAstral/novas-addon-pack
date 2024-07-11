AddCSLuaFile()

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "De-mat Gun"
SWEP.Purpose = "Remove something from existence"
SWEP.Instructions = "LMB - Fire Gun"
SWEP.DrawCrosshair = true
SWEP.SlotPos = 10
SWEP.Slot = 3
SWEP.Spawnable = false
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

    self.DematAlphas={ --'borrowed' from the TARDIS Legacy addon
		150,
		200,
		100,
		150,
		50,
		100,
		0
	}
    -- use the table with self.DematAlphas[self.Step] where self.Step is the table index you want to access
    self.Step = 1 --7 steps total
end

if SERVER then
	function SWEP:PrimaryAttack()
        self:SetNextPrimaryFire(CurTime()+1)

		local ply = self:GetOwner()

		if(not IsValid(ply)) then return end

        local trent = ply:GetEyeTrace().Entity

        if(IsValid(trent)) then
            self:SetNextPrimaryFire(CurTime()+10)

        end
        
	end
end

if(CLIENT)then
	local matScreen = Material("models/weapons/v_toolgun/screen")
    local rtTexture = GetRenderTarget("GModToolgunScreen",256,256)

    surface.CreateFont("DMatGun",{
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
            self:drawShadowedText("Demat",128,110,"DMatGun")
            self:drawShadowedText("Gun",128,145,"DMatGun")
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

timer.Simple(0.1, function() weapons.Register(SWEP,"demat_gun", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused