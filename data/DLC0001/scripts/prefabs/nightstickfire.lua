local prefabs = 
{
	"sparks",
}

local max_scale = 3

local function OnAttack(inst)
	local pos = Vector3(inst.Transform:GetWorldPosition())
    pos.y = pos.y - .5
    local spark = SpawnPrefab("sparks")
    spark.Transform:SetPosition(pos:Get())
end

local function fn(Sim)
	local inst = CreateEntity()
	inst:AddTag("FX")
	local trans = inst.entity:AddTransform()

	inst.entity:AddLight()
    inst.Light:Enable(true)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(252/255,251/255,237/255)
    inst.Light:SetFalloff( 0.6 )
    inst.Light:SetRadius( 4 )
    
    inst.persists = false

    inst.OnAttack = OnAttack
   
    return inst
end

return Prefab( "common/fx/nightstickfire", fn, nil, prefabs) 
 
