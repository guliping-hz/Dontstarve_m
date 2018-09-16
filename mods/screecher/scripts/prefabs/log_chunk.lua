local assets=
{
	Asset("ANIM", "exportedanim/log_chunk.zip"),
	Asset("ANIM", "exportedanim/woodpile.zip"),
	Asset("ANIM", "exportedanim/sitting_log.zip"),
}

local function fn(Sim, bankname)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 2.5, 1.25 )
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bankname)
    inst.AnimState:SetBuild(bankname)
    inst.AnimState:PlayAnimation("idle")
    
    return inst
end

return 
	Prefab( "common/inventory/log_chunk",	function(Sim) return fn(Sim, "log_chunk") end, assets),
	Prefab( "common/inventory/woodpile", 	function(Sim) return fn(Sim, "woodpile") end, assets),
	Prefab( "common/inventory/sitting_log",	function(Sim) return fn(Sim, "sitting_log") end, assets) 

