AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Fragmentation Bomb"
ENT.Author = "Nova Astral"
ENT.Category = "Novas Addon Pack"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "kaboom"
ENT.Instructions = "just explode it"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then
	language.Add( "Cleanup_fragmentation_bomb","Fragmentation Bomb")
	language.Add( "Cleanup_fragmentation_bomb","Fragmentation Bomb")

	function ENT:Draw()
		self:DrawEntityOutline(0.0)
		self.Entity:DrawModel()
	end

	function ENT:DrawEntityOutline() return	end
else

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("nova_frag_bomb")
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
		self.WireDebugName = "Fragmentation Bomb"

		self.Inputs = WireLib.CreateSpecialInputs(self.Entity,{"Activate"},{"NORMAL"})
	end

	self.MaxHP = 25
	self.Entity:SetMaxHealth(self.MaxHP)
	self.Entity:SetHealth(self.MaxHP)

	self.Entity:SetSkin(1)

	self.Timer = 0
	self.MaxGibVel = 5000
	self.MinGibVel = -5000

	self.Exploded = false
end

function ENT:Use()
	if(!timer.Exists("BombTimer"..self:EntIndex())) then
		self:ActivateBomb()
	end
end

function ENT:Explode()
	for I = 1,20 do
		local GibEnt = ents.Create("prop_physics")
		local ModelRandNum = math.random(1,3)
		
		if(ModelRandNum == 1) then
			GibEnt:SetModel("models/combine_helicopter/bomb_debris_1.mdl")
		elseif(ModelRandNum == 2) then
			GibEnt:SetModel("models/combine_helicopter/bomb_debris_2.mdl")
		else
			GibEnt:SetModel("models/combine_helicopter/bomb_debris_3.mdl")
		end

		GibEnt:PhysicsInit(SOLID_VPHYSICS)
		GibEnt:SetMoveType(MOVETYPE_VPHYSICS)
		GibEnt:SetSolid(SOLID_VPHYSICS)

		local Phys = GibEnt:GetPhysicsObject()

		if(Phys:IsValid()) then
			Phys:SetMass(100)
			Phys:EnableGravity(true)
			Phys:Wake()
		end

		GibEnt:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
		GibEnt:SetPos(self.Entity:GetPos())

		if(IsValid(Phys)) then
			Phys:SetVelocity(VectorRand(self.MinGibVel,self.MaxGibVel))
		end

		timer.Simple(10,function()
			if(IsValid(GibEnt)) then
				GibEnt:Remove()
			end
		end)
	end

	self.Entity:EmitSound("phx/explode06.wav",80,100,1)

	util.BlastDamage(self.Entity,self.Entity,self.Entity:GetPos(),250,100)
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self.Entity:GetPos())
	effectdata:SetStart(self.Entity:GetPos())
	effectdata:SetScale(20)
	util.Effect("HelicopterMegaBomb", effectdata)

	self.Entity:Remove()
end

function ENT:ActivateBomb()
	timer.Create("BombTimer"..self:EntIndex(),1,5,function()
		self.Timer = self.Timer+1

		if(IsValid(self.Entity)) then
			self.Entity:EmitSound("weapons/c4/c4_click.wav")

			if(self.Entity:GetSkin() == 0) then
				self.Entity:SetSkin(1)
			else
				self.Entity:SetSkin(0)
			end
		end

		if(self.Timer == 5) then
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