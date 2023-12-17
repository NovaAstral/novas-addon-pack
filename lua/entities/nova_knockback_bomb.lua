AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Knockback Bomb"
ENT.Author = "Nova Astral"
ENT.Category = "Novas Addon Pack"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "kaboom"
ENT.Instructions = "just explode it"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then
	language.Add( "Cleanup_knockback_bomb","Knockback Bomb")
	language.Add( "Cleanup_knockback_bomb","Knockback Bomb")

	function ENT:Draw()
		self:DrawEntityOutline(0.0)
		self.Entity:DrawModel()
	end

	function ENT:DrawEntityOutline() return	end
else

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("nova_knockback_bomb")
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

	self.Exploded = false
end

function ENT:Use()
	if(!timer.Exists("BombTimer"..self:EntIndex())) then
		self:ActivateBomb()
	end
end

function ENT:Explode()
	self.Entity:EmitSound("phx/explode06.wav",80,100,1)

	local effectdata = EffectData()
	effectdata:SetOrigin(self.Entity:GetPos())
	effectdata:SetStart(self.Entity:GetPos())
	effectdata:SetScale(20)
	util.Effect("HelicopterMegaBomb", effectdata)

	local targets = ents.FindInSphere(self.Entity:GetPos(),500)

	for k,v in pairs(targets) do
		local direction = (v:GetPos() - self.Entity:GetPos()):GetNormalized()

		if(v:IsPlayer()) then
			v:SetVelocity(direction * 5000)
		elseif(IsValid(v:GetPhysicsObject())) then
			v:GetPhysicsObject():AddVelocity(direction * 5000)
		end
	end


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