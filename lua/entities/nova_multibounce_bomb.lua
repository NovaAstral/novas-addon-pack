AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Multibounce Bomb"
ENT.Author = "Nova Astral"
ENT.Category = "Novas Addon Pack"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "boing"
ENT.Instructions = "bouncy"

ENT.Spawnable = true

if CLIENT then
	function ENT:Draw()
		self:DrawEntityOutline(0.0)
		self.Entity:DrawModel()
	end

	function ENT:DrawEntityOutline() return	end
else
	function ENT:SpawnFunction(ply, tr)
		local ent = ents.Create("nova_multibounce_bomb")
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
			self.WireDebugName = "Multibounce Bomb"

			self.Inputs = WireLib.CreateSpecialInputs(self.Entity,{"Activate"},{"NORMAL"})
		end

		self.MaxHP = 25
		self.Entity:SetMaxHealth(self.MaxHP)
		self.Entity:SetHealth(self.MaxHP)

		self.Entity:SetSkin(1)

		self.Bounces = 0
		
		self.Active = false
		self.Exploded = false
	end

	function ENT:Use()
		self:ActivateBomb()
	end

	function ENT:PhysicsCollide(data,collider)
		local Phys = self.Entity:GetPhysicsObject()

		if(Phys:IsValid() and self.Active) then
			Phys:SetVelocity(Vector(math.random(-500,500),math.random(-500,500),math.random(-500,500)))

			self.Bounces = self.Bounces+1
			
			self:Explode()
			
			if(snd == 1) then
				self.Entity:EmitSound("physics/metal/metal_barrel_impact_hard1.wav")
			elseif(snd == 2) then
				self.Entity:EmitSound("physics/metal/metal_barrel_impact_hard2.wav")
			else
				self.Entity:EmitSound("physics/metal/metal_barrel_impact_hard3.wav")
			end

			if(self.Entity:GetSkin() == 0) then
				self.Entity:SetSkin(1)
			else
				self.Entity:SetSkin(0)
			end

			if(self.Bounces >= 25) then
				self.Entity:Remove()
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
	end

	function ENT:ActivateBomb()
		self.Active = true

		local Phys = self.Entity:GetPhysicsObject()

		if(Phys:IsValid()) then
			Phys:SetVelocity(Vector(0,0,100))
		end
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
end