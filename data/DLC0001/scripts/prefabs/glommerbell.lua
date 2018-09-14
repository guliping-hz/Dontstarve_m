local assets =
{
	Asset("anim", "anim/bell.zip"),
}

local function OnPlayed(inst, musician)
	if GetWorld().components.bigfooter then
		GetWorld().components.bigfooter:SummonFoot(musician:GetPosition())
	end
end

local function shine(inst)
    inst.task = nil
    inst.AnimState:PlayAnimation("sparkle")
    inst.AnimState:PushAnimation("idle")
    inst.task = inst:DoTaskInTime(4+math.random()*5, function() shine(inst) end)
end

local function OnPutInInv(inst, owner)
    if owner.prefab == "mole" or owner.prefab == "krampus" then
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/glommer_bell")
        OnPlayed(inst, owner)
        if inst.components.finiteuses then inst.components.finiteuses:Use() end
    end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("bell")
	inst.AnimState:SetBuild("bell")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("bell")
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst:AddTag("molebait")
    inst:ListenForEvent( "onstolen", function(inst, data) 
        if data.thief.components.inventory then
            data.thief.components.inventory:GiveItem(inst)
        end 
    end)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInv)
    
    inst:AddComponent("instrument")
    inst.components.instrument.onplayed = OnPlayed

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.GLOMMERBELL_USES)
    inst.components.finiteuses:SetUses(TUNING.GLOMMERBELL_USES)
    inst.components.finiteuses:SetOnFinished( onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)
    shine(inst)
	return inst
end

return Prefab("bell", fn, assets)