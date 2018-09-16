local assets=
{
	Asset("ANIM", "exportedanim/beacon2.zip"),
}

local function OnActivate(inst, doer)
	inst:DoTaskInTime(0, function(inst)
		inst.components.activatable.inactive = true
	end)

	doer.components.talker:Say("Once these are lit the helicopter can land.", 2.5, false)
end

local function OnTempLit(inst)

    --GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/flashlight_out")
    inst.AnimState:PlayAnimation("on_loop")
    inst.AnimState:PushAnimation("idle")
    inst.lightduration = 0.8

end

local function OnLit(inst)

    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst.SoundEmitter:PlaySound("scary_mod/stuff/floodlight_on")
    inst.AnimState:PlayAnimation("on_loop", true)
    inst.lightduration = -1
	inst.components.activatable.inactive = false

end

local function OnUpdate(inst)

    if inst.lightduration == -1 then
        inst.Light:SetIntensity( 0.8 )
        inst.childlightentity.Light:SetIntensity( 0.8 )
    else
        inst.Light:SetIntensity( inst.lightduration )
        inst.childlightentity.Light:SetIntensity( inst.lightduration )
        inst.lightduration = inst.lightduration - FRAMES
    end

end

local function OnBreak(inst)

    print("breaking a light")
    inst.SoundEmitter:PlaySound("scary_mod/stuff/beacon_flicker")
    inst.SoundEmitter:PlaySound("scary_mod/stuff/break_light")

    inst.Light:SetIntensity( 0 )
    inst.lightduration = 0
    inst.broken = true

end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    
    inst:AddTag("beacon")
    inst:AddTag("CLICK")

    inst.AnimState:SetBank("beacon")
    inst.AnimState:SetBuild("beacon2")
    inst.AnimState:PlayAnimation("idle")
    
    local light = inst.entity:AddLight()
    light:SetFalloff(0.7)
    light:SetIntensity(0)
    light:SetRadius(20)
    light:SetColour(237/255, 0/255, 0/255)

    --secondary light
    local inst2 = CreateEntity()
    inst.childlightentity = inst2
    inst2.entity:AddTransform()

    local light2 = inst2.entity:AddLight()
    light2:SetFalloff(0.7)
    light2:SetIntensity(0)
    light2:SetRadius(3)
    light2:SetColour(237/255, 100/255, 100/255)

    inst:DoTaskInTime(0, function()
        local pos = inst:GetPosition()
        inst2.Transform:SetPosition(pos:Get())
    end)

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
	inst.components.activatable.distance = TUNING.SIGN_READ_DISTANCE
	inst.components.activatable.quickaction = true

	inst.name = "Landing Light"

    inst:AddComponent("scaryshadow")
    inst:DoTaskInTime(0, function()
        inst.components.scaryshadow:SpawnShadow(inst, 1.8)
    end)

    inst.lightduration = 0
    inst.broken = false

    inst:DoPeriodicTask(0, OnUpdate)

    inst:ListenForEvent("onbeacontemplit", OnTempLit)
    inst:ListenForEvent("onbeaconlit", OnLit)
    inst:ListenForEvent("onbeaconbreak", OnBreak)

    return inst
end

return Prefab( "common/inventory/helicopter_beacon", fn, assets)
