AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Jumper Rocket"
ENT.Author = "Nova Astral"
ENT.Category = "Novas Addon Pack"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "boing"
ENT.Instructions = "bouncy"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then
	language.Add( "Cleanup_contact_bomb","Contact Bomb")
	language.Add( "Cleanup_contact_bomb","Contact Bomb")

	function ENT:Draw()
		self:DrawEntityOutline(0.0)
		self.Entity:DrawModel()
	end

	function ENT:DrawEntityOutline() return	end
else

function ENT:SpawnFunction(ply, tr)
	local ent = ents.Create("jumper_rocket")
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

    self.Entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		
	self.Entity:DrawShadow(false)
		
	local phys = self.Entity:GetPhysicsObject()

	if(phys:IsValid()) then
		phys:SetMass(100)
		phys:EnableGravity(true)
		phys:Wake()
	end

	self.MaxHP = 25
	self.Entity:SetMaxHealth(self.MaxHP)
	self.Entity:SetHealth(self.MaxHP)

	self.Entity:SetSkin(1)
    
    self.Active = false
end

function ENT:PhysicsCollide(data,collider)
    local Phys = self.Entity:GetPhysicsObject()

    if(Phys:IsValid() and self.Active) then
        self:Explode()
    end
end

function ENT:Explode()
    local targets = ents.FindInSphere(self.Entity:GetPos(),500)

	for k,v in pairs(targets) do
		local direction = (v:GetPos() - self.Entity:GetPos()):GetNormalized()

		if(v:IsPlayer()) then
			v:SetVelocity(direction * 500)
		elseif(IsValid(v:GetPhysicsObject())) then
			v:GetPhysicsObject():AddVelocity(direction * 500)
		end
	end

	self.Entity:EmitSound("phx/explode06.wav",80,100,1)

	--util.BlastDamage(self.Entity,self.Entity,self.Entity:GetPos(),500,200)
	
	local effectdata = EffectData()
	effectdata:SetOrigin(self.Entity:GetPos())
	effectdata:SetStart(self.Entity:GetPos())
	effectdata:SetScale(20)
	util.Effect("HelicopterMegaBomb", effectdata)

	self.Entity:Remove()
end
end