local function makefeather(name)
    
    local assetname = "feather_"..name
    local assets = 
    {
	    Asset("ANIM", "anim/"..assetname..".zip"),
    }
    
    local function fn()
	    local inst = CreateEntity()
	    inst.entity:AddTransform()
	    inst.entity:AddAnimState()
        
        inst.AnimState:SetBank(assetname)
        inst.AnimState:SetBuild(assetname)
        inst.AnimState:PlayAnimation("idle")
        MakeInventoryPhysics(inst)
        
        inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)
        inst.components.burnable:MakeDragonflyBait(3)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.TINY_FUEL

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.nobounce = true

        inst:AddTag("cattoy")
        inst:AddComponent("tradable")
        
        return inst
    end
    return Prefab( "common/inventory/"..assetname, fn, assets)
end

return makefeather("crow"),
       makefeather("robin"),
	   makefeather("robin_winter") 
