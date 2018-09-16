local assets=
{
	Asset("ANIM", "exportedanim/junkpile.zip"),
    Asset("ANIM", "exportedanim/radio.zip"),
}

local function OnActivate(inst)

    inst:DoTaskInTime(2, function()
        inst:DoTaskInTime(3*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("scary_mod/stuff/radio_LP", "radioloop")
            inst.components.talker:Say("We thought you were dead, Bill.", 2, false)
            inst:DoTaskInTime(2, function(inst)
                inst.SoundEmitter:KillSound("radioloop")
            end)
        end)
    end)

    inst:DoTaskInTime(4.5, function()    
        inst:DoTaskInTime(3*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("scary_mod/stuff/radio_LP", "radioloop")
            inst.components.talker:Say("We'll come get you. Turn on the beacon with the generator!", 4, false)
            inst:DoTaskInTime(4, function(inst)
                inst.SoundEmitter:KillSound("radioloop")
                GetPlayer():PushEvent("generatortutorial")
            end)
        end)
    end)

end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("radio")
    inst.AnimState:SetBuild("radio")
    inst.AnimState:PlayAnimation("idle")
    inst:AddTag("radio")
    
    inst:AddTag("CLICK")
    inst:AddComponent("activatable")
    inst.components.activatable.distance = nil
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
    inst.components.activatable.quickaction = false

    inst.name = "Radio"
    inst.nameoffset = 100

    inst:AddComponent("talker")
    inst.components.talker.colour = Vector3(0.4, 0.4, 0.5)
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.fontsize = 28
    inst.components.talker.offset = Vector3(0,-520,0)

    inst:AddComponent("scaryshadow")
    inst:DoTaskInTime(0, function()
        inst.components.scaryshadow:SpawnShadow(inst, 1.8)
    end)

    -- inst.timetoecholocate = 100
    -- inst.duration = 30
    -- inst.chirping = false
    -- inst.stopsound = false
    -- inst:DoPeriodicTask(0, function()
    --     local a,b,c = inst.Transform:GetWorldPosition()
    --     local x,y,z = GetPlayer().Transform:GetWorldPosition()
    --     print("radio: "..a.." "..b.." "..c)
    --     print("player: "..x.." "..y.." "..z)
    --     if inst.name ~= "" and not inst.stopstound then
    --         inst.timetoecholocate = inst.timetoecholocate - 1
    --         if inst.timetoecholocate <= 0 then
    --             inst.duration = inst.duration - 1
    --             if not inst.chirping then
    --                 inst.SoundEmitter:PlaySound("scary_mod/stuff/radio_LP", "radiochirp")
    --                 inst.chirping = true
    --             end
    --             if inst.duration <= 0 then
    --                 inst.SoundEmitter:KillSound("radiochirp")
    --                 inst.timetoecholocate = math.random(60, 120)
    --                 inst.duration = math.random(15, 30)
    --                 inst.chirping = false
    --             end
    --         end
    --     else
    --         inst.SoundEmitter:KillSound("radiochirp")
    --     end
    -- end)

    inst:ListenForEvent("removelootname", function(it, data) 
        if data.loot == inst then
            inst.name = ""
            inst.SoundEmitter:PlaySound("scary_mod/stuff/radio_on")
        end
    end, GetPlayer())
    inst:ListenForEvent("killallsounds", function()
        inst.SoundEmitter:KillSound("radioloop")
        inst.SoundEmitter:KillSound("radiochirp")
        inst.stopsound = true
    end, GetPlayer())

    return inst
end

return Prefab( "common/inventory/radio_stand", fn, assets)
