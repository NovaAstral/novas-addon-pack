AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Safe Zone"
ENT.Author = "Nova Astral"
ENT.Category = "Novas Addon Pack"
ENT.Contact	= "https://github.com/NovaAstral"
ENT.Purpose	= "Being safe"
ENT.Instructions = "Press E on it when you're admin"

ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then
    language.Add( "Cleanup_safe_zone", "Cleanup Safe Zone")
    language.Add( "Cleaned_safe_zone", "Cleaned up Safe Zone")
    
    function ENT:Draw()
       self:DrawEntityOutline( 0.0 )
       self.Entity:DrawModel()	
    end
    
    function ENT:DrawEntityOutline()
        return
    end

	function ENT:ShowRadiusEnt() --scaling doesnt work properly currently
		RadiusEnt = ClientsideModel("models/nova/unit_sphere.mdl")
		RadiusEnt:SetPos(self.Entity:GetPos())
		RadiusEnt:SetParent(self.Entity)
		RadiusEnt:SetMaterial("models/props_combine/stasisshield_sheet")
		RadiusEnt:Spawn()

		Rad = self.Entity:GetNWInt("Radius",10)
		local MatrixScale = Matrix()
		MatrixScale:Scale(Vector(Rad,Rad,Rad))
		RadiusEnt:EnableMatrix("RenderMultiply",MatrixScale)

		RadiusEnt:SetRenderBounds(Vector(-Rad,-Rad,-Rad),Vector(Rad,Rad,Rad),Vector( 0, 0, 0 ))
	end

	function ENT:OnRemove()
		timer.Simple(0,function()
			if(not IsValid(self)) then
				if(IsValid(RadiusEnt)) then
					RadiusEnt:Remove()
				end
			end
		end)
	end

	function ENT:Initialize()
		if(LocalPlayer() == self.Entity:GetVar("Owner")) then
			self:ShowRadiusEnt()

			timer.simple(5,function()
				if(IsValid(RadiusEnt)) then
					RadiusEnt:Remove()
				end
			end)
		end

		net.Receive("nova_safezone_radius_hud_activate_net",function(len)
			ply = net.ReadEntity()
	
			if(LocalPlayer() == ply and ply:IsAdmin()) then
				local DermaPanel = vgui.Create("DFrame")
				DermaPanel:SetTitle("Set the Radius of the Safe Zone")
				DermaPanel:SetSize(400,150)
				DermaPanel:Center()
				DermaPanel:MakePopup()
	
				local RadiusEntry = vgui.Create("DTextEntry",DermaPanel)
				RadiusEntry:Dock(TOP)
	
				RadiusEntry.OnEnter = function(self)
					num = math.Clamp(tonumber(self:GetValue()),1,65535)
	
					net.Start("nova_safezone_radius_net")
						net.WriteInt(num,17)
					net.SendToServer()
	
					chat.AddText("Radius Set To: ",Color(150,220,0),tostring(num))
					DermaPanel:Close()
				end
	
				local ToggleRadiusEntButton = vgui.Create("DButton",DermaPanel)
				ToggleRadiusEntButton:SetText("Toggle showing the radius of the Safe Zone for you")
				ToggleRadiusEntButton:Dock(TOP)
				ToggleRadiusEntButton.DoClick = function()
					if(IsValid(RadiusEnt)) then
						RadiusEnt:Remove()
					else
						self.Entity:ShowRadiusEnt()
					end
				end
	
				ToggleRadiusEntButton.DoRightClick = function()
	
				end
			end
		end)
	end
else --server

function ENT:SpawnFunction(ply, tr)
	if(!ply:IsSuperAdmin()) then
		ply:SendLua("GAMEMODE:AddNotify(\"Only SuperAdmins can spawn this!\", NOTIFY_ERROR, 8); surface.PlaySound( \"buttons/button2.wav\" )")
		return
	end

	local ent = ents.Create("nova_safezone")
	ent:SetPos(tr.HitPos + Vector(0, 0, 0))
	ent:SetVar("Owner",ply)
	ent:Spawn()
	return ent 
end

function ENT:Initialize()
	self.Entity:SetModel("models/props_lab/huladoll.mdl")
	
	--self.Entity:PhysicsInit(SOLID_NONE)

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	--self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	--self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
		
	self.Entity:DrawShadow(false)
	self.Entity:SetUseType(SIMPLE_USE)

	self.Radius = 500

	self.Entity:SetNWInt("Radius",self.Radius)

	util.AddNetworkString("nova_safezone_radius_hud_activate_net")
	util.AddNetworkString("nova_safezone_radius_net")

	net.Receive("nova_safezone_radius_net",function(len,ply)
		local radius = net.ReadInt(17)
	
		if(ply:IsSuperAdmin() or ply:ISAdmin() and radius > 0 and radius < 65535) then
			self.Radius = radius
			self.Entity:SetNWInt("Radius",radius)
		end
	end)
end

function ENT:Use(ply)
	if(ply:IsSuperAdmin()) then
		net.Start("nova_safezone_radius_hud_activate_net")
			net.WriteEntity(ply)
		net.Send(ply)
	end
end

end --end server