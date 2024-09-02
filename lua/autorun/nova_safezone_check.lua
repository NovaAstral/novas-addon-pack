if SERVER then
    hook.Add("EntityTakeDamage","nova_safezone_damagecheck",function(ent,dmg)
        if(IsValid(ent) and IsValid(dmg)) then
            attacker = dmg:GetAttacker()
                
            for k,v in ents.Iterator() do
                if(IsValid(v) and v:GetClass() == "nova_safezone") then
                    if(ent:GetPos():Distance(v:GetPos()) <= v.Radius) then
                        dmg:SetDamage(0)
                        return true --block damage event
                    elseif(IsValid(attacker) and attacker:GetPos():Distance(v:GetPos()) <= v.Radius) then
                        dmg:SetDamage(0)
                        return true --block damage event
                    end
                end
            end
        end
    end)
end

if CLIENT then
    surface.CreateFont("Nova_SafeZone_Font",{
        font = "Arial",
        extended = false,
        size = 20,
        weight = 5000,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = true,
    })

    hook.Add("Think", "nova_safezone_hud_think",function() --doesnt work properly if more than 1 safezone, will only show hud around the last safezone spawned
        Counter = 0
        plypos = LocalPlayer():GetPos()

        for k,v in ents.Iterator() do
            if(IsValid(v) and v:GetClass() == "nova_safezone") then
                if(plypos:Distance(v:GetPos()) <= v:GetNWInt("Radius",500)) then
                    Counter = Counter+1
                end
            end
        end

        if(Counter > 0) then
            hook.Add("HUDPaint","Nova_SafeZone_HUD",function() 
                draw.DrawText("You are inside a Safe Zone","Nova_SafeZone_Font",ScrW() * 0.5,ScrH() * 0.1,Color(255,255,255),TEXT_ALIGN_CENTER)
            end)
        else
            hook.Remove("HUDPaint","Nova_SafeZone_HUD")
        end
    end)
end
