AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Timed Bouncy Bomb"
ENT.Author = "Nova Astral"
ENT.Category = "Novas Addon Pack"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "boing"
ENT.Instructions = "bouncy but timed"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then
	language.Add( "Cleanup_timed_bouncy_bomb","Timed Bouncy Bomb")
	language.Add( "Cleanup_timed_bouncy_bomb","Timed Bouncy Bomb")

	function ENT:Draw()
		self:DrawEntityOutline(0.0)
		self.Entity:DrawModel()
	end

	function ENT:DrawEntityOutline() return	end
else

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("nova_bouncy_bomb_timed")
	ent:SetPos(tr.HitPos)
	ent:SetVar("Owner",ply)
	ent:Spawn()
	return ent 
end

function ENT:Initialize()
	util.PrecacheModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
		
	self.Entity:DrawShadow(false)
		
	local phys = self.Entity:GetPhysicsObject()

	if(phys:IsValid()) then
		phys:SetMass(100)
		phys:EnableGravity(true)
		phys:Wake()
	end

	if(WireLib != nil) then
		self.WireDebugName = "Timed Bouncy Bomb"

		self.Inputs = WireLib.CreateSpecialInputs(self.Entity,{"Activate"},{"NORMAL"})
	end

	self.MaxHP = 25
	self.Entity:SetMaxHealth(self.MaxHP)
	self.Entity:SetHealth(self.MaxHP)

	self.Entity:SetSkin(1)
    
    self.Active = false
	self.Exploded = false

	self.Timer = 0
end

function ENT:Use()
	if(!self.Active) then
		self:ActivateBomb()
	end
end

function ENT:PhysicsCollide(data,collider)
    local Phys = self.Entity:GetPhysicsObject()

    if(Phys:IsValid() and self.Active) then
        Phys:SetVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))

		local snd = math.random(1,3)
		
		if(snd == 1) then
			self.Entity:EmitSound("physics/metal/metal_barrel_impact_hard1.wav")
		elseif(snd == 2) then
			self.Entity:EmitSound("physics/metal/metal_barrel_impact_hard2.wav")
		else
			self.Entity:EmitSound("physics/metal/metal_barrel_impact_hard3.wav")
		end
    end
end

function ENT:Explode()
	self.Entity:EmitSound("phx/explode06.wav",80,100,1)

	util.BlastDamage(self.Entity,self.Entity,self.Entity:GetPos(),500,200)
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self.Entity:GetPos())
	effectdata:SetStart(self.Entity:GetPos())
	effectdata:SetScale(20)
	util.Effect("HelicopterMegaBomb", effectdata)

	self.Entity:Remove()
end

function ENT:ActivateBomb()
	self.Entity:EmitSound("buttons/button14.wav")
	self.Active = true

    local Phys = self.Entity:GetPhysicsObject()

    if(Phys:IsValid()) then
        Phys:SetVelocity(Vector(0,0,100))
    end

	timer.Create("BombTimer"..self:EntIndex(),1,10,function()
		self.Timer = self.Timer+1

		if(IsValid(self.Entity)) then
			self.Entity:EmitSound("weapons/c4/c4_click.wav")

			if(self.Entity:GetSkin() == 0) then
				self.Entity:SetSkin(1)
			else
				self.Entity:SetSkin(0)
			end
		end

		if(self.Timer == 10) then
			self:Explode()
		end
	end)
end

function ENT:OnTakeDamage(damage)
	local dmg = damage:GetDamage()
	
	if(!self.Exploded) then
		self.Entity:SetHealth(math.Clamp(self.Entity:Health() - dmg,0,self.Entity:GetMaxHealth()))
		
		if(self.Entity:Health() <= 0) then
			self.Exploded = true
			self:Explode()
		end
	end
end

function ENT:TriggerInput(iname, value)
	if(iname == "Activate" and value >= 1) then
		self:ActivateBomb()
	end
end

function ENT:PreEntityCopy()
	if WireAddon then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",WireLib.BuildDupeInfo(self.Entity))
	end
end

function ENT:PostEntityPaste(ply, ent, createdEnts)
	if WireAddon then
		local emods = ent.EntityMods
		if not emods then return end
		WireLib.ApplyDupeInfo(ply, ent, emods.WireDupeInfo, function(id) return createdEnts[id] end)
	end
end

function ENT:OnRemove()
	timer.Remove("BombTimer"..self:EntIndex())
end

end