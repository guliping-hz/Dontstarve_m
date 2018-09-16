local assets =
{
	Asset("ANIM", "anim/pig_house.zip"),
}

local prefabs = 
{
}

local function LightsOn(inst)
    inst.Light:Enable(true)
    inst.AnimState:PlayAnimation("lit", true)
    inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
    inst.lightson = true
end

local function LightsOff(inst)
    inst.Light:Enable(false)
    inst.AnimState:PlayAnimation("idle", true)
    inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
    inst.lightson = false
    inst.components.playerprox:SetOnPlayerNear(function() end) --turn off this function so SFX don't keep playing
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local light = inst.entity:AddLight()
    inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "pighouse.png" )
    
    light:SetFalloff(1)
    light:SetIntensity(.5)
    light:SetRadius(1)
    light:Enable(false)
    light:SetColour(180/255, 195/255, 50/255)

    MakeObstaclePhysics(inst, 1)

    anim:SetBank("pig_house")
    anim:SetBuild("pig_house")
    anim:PlayAnimation("idle")
 
	inst:AddComponent( "playerprox" )
    inst.components.playerprox:SetDist(10,13)
    inst.components.playerprox:SetOnPlayerNear(LightsOff)


    inst:AddComponent("inspectable")
	
	LightsOn(inst)

	MakeSnowCovered(inst, .01)
    return inst
end

return Prefab( "common/objects/goodshack", fn, assets, prefabs )  
