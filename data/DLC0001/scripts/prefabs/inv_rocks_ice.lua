local assets=
{
	Asset("ANIM", "anim/ice.zip"),
}

local names = {"f1","f2","f3"}

local function onsave(inst, data)
	data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
	    inst.AnimState:PlayAnimation(inst.animname)
	end
end

local function onperish(inst)
    local player = GetPlayer()
    if inst.components.inventoryitem and player and inst.components.inventoryitem:IsHeldBy(player) then
        if player.components.moisture then
            local stacksize = inst.components.stackable:StackSize()
            player.components.moisture:DoDelta(2*stacksize)
        end
        inst:Remove()
    elseif inst.components.inventoryitem:GetContainer() then
        inst:Remove()
    else
        inst.components.inventoryitem.canbepickedup = false
        inst.AnimState:PlayAnimation("melt")
        inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("ice")
    inst.AnimState:SetBuild("ice")
    inst.animname = names[math.random(#names)]
    inst.AnimState:PlayAnimation(inst.animname)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "GENERIC"
    inst.components.edible.healthvalue = TUNING.HEALING_TINY/2
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/4
    inst.components.edible.degrades_with_spoilage = false
    inst.components.edible.temperaturedelta = TUNING.COLD_FOOD_BONUS_TEMP
    inst.components.edible.temperatureduration = TUNING.FOOD_TEMP_BRIEF * 1.5

    inst:AddComponent("smotherer")

    inst:AddTag("frozen")

    inst:ListenForEvent("firemelt", function(inst)
        inst.components.perishable.frozenfiremult = true
    end)
    inst:ListenForEvent("stopfiremelt", function(inst)
        inst.components.perishable.frozenfiremult = false
    end)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(onperish)

    inst:AddComponent("tradable")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "ice"
    inst.components.inventoryitem:SetOnPickupFn(function(inst, owner)
        inst.components.perishable.frozenfiremult = false
    end)

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = "ICE"
    inst.components.repairer.perishrepairvalue = .05

    inst:AddComponent("bait")
    inst:AddTag("molebait")

    inst.OnSave = onsave 
    inst.OnLoad = onload 
    return inst
end

return Prefab( "common/inventory/ice", fn, assets) 
