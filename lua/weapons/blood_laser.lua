AddCSLuaFile() --Makes it show up in singleplayer

local SWEP = {Primary = {}, Secondary = {}}
SWEP.Author = "Nova Astral"
SWEP.PrintName = "Blood Laser"
SWEP.Purpose = "Fire a laser"
SWEP.Instructions = "LMB - Fire Laser\nRMB- Fire Powerful Laser"
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

if SERVER then
    util.AddNetworkString("Nova_Laser")
end

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

        self:SetNWBool("Fire",true)
        self:SetNWEntity("FirePly",ply)
        self:SetNWVector("Hitpos",hitpos)
	end
end

if(CLIENT)then
	local matScreen = Material("models/weapons/v_toolgun/screen")
    local rtTexture = GetRenderTarget("GModToolgunScreen",256,256)

    surface.CreateFont("NovaLaser",{
        font = "Helvetica",
        size = 40,
        weight = 900
    })
    /*
    function SWEP:RenderScreen()
        matScreen:SetTexture("$basetexture",rtTexture)

        local oldRT = render.GetRenderTarget()

        render.PushRenderTarget(rtTexture,0,0,256,256)

        cam.Start2D()
            surface.SetDrawColor(Color(255,20,20))
            surface.DrawRect(0,0,256,256)
            self:drawShadowedText("Blood",128,110,"NovaLaser")
            self:drawShadowedText("Laser",128,145,"NovaLaser")
        cam.End2D()

        render.PopRenderTarget()
        render.PushRenderTarget(oldRT,0,0,ScrW(),ScrH())
        
    end

    function SWEP:drawShadowedText(text, x, y, font)
        draw.SimpleText( text, font, x + 3, y + 3, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText( text, font, x , y , Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    */

    lasermat = Material("trails/plasma")
    --muzzle = self:LookupAttachment("muzzle")

    function SWEP:DrawWorldModel(flags) --Draws laser in thirdperson
        self:DrawModel(flags)
        --PrintTable(self:GetAttachments())
        muzzle = self:GetAttachment(self:LookupAttachment("muzzle"))

        if(self:GetNWBool("Fire") == true) then
            local laserwidth = 10
            local fireply = self:GetNWEntity("FirePly")
            local hitpos = self:GetNWVector("Hitpos")
            local muzzlepos = muzzle.pos
            if(IsValid(fireply)) then
                render.SetMaterial(lasermat)
                render.DrawBeam(muzzlepos,hitpos,laserwidth,1,0,Color(255,50,50))
            end
        end
    end
end

timer.Simple(0.1, function() weapons.Register(SWEP,"blood_laser", true) end) --Putting this in a timer stops bugs from happening if the weapon is given while the game is paused