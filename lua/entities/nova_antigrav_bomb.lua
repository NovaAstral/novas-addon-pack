AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Anti-gravity Contact Bomb"
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
		local ent = ents.Create("nova_contact_bomb")
		ent:SetPos(tr.HitPos)
		ent:SetVar("Owner",ply)
		ent:Spawn()

		timer.Simple(0.1,function()
			local phys = ent:GetPhysicsObject()

			if(phys:IsValid()) then
				phys:SetMass(100)
				phys:EnableGravity(false)
				phys:Wake()
			end
		end)
		
		return ent
	end
end