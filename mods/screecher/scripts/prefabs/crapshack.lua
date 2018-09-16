local assets =
{
	Asset("ANIM", "anim/pig_house.zip"),
}

local prefabs = 
{
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "mermhouse.png" )
    
    MakeObstaclePhysics(inst, 1)

    anim:SetBank("pig_house")
    anim:SetBuild("pig_house")
    anim:PlayAnimation("rundown")

    inst:AddComponent("inspectable")
	
	MakeSnowCovered(inst, .01)
    return inst
end

return Prefab( "common/objects/crapshack", fn, assets, prefabs )  
