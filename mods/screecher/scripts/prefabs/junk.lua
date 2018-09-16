local assets=
{
	Asset("ANIM", "exportedanim/junkpile.zip"),
	--Asset("ANIM", "exportedanim/cooler.zip"),
	Asset("ANIM", "exportedanim/cooler_small.zip"),
}

local function fn(Sim, bankname)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bankname)
    inst.AnimState:SetBuild(bankname)
    inst.AnimState:PlayAnimation("idle")
    
    return inst
end

return 
	Prefab( "common/inventory/junkpile", 		function(Sim) return fn(Sim, "junkpile") end, assets),
	--Prefab( "common/inventory/cooler", 			function(Sim) return fn(Sim, "cooler") end, assets),
	Prefab( "common/inventory/cooler_small",	function(Sim) return fn(Sim, "cooler_small") end, assets) 

