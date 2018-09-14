local assets =
{
	Asset("ANIM", "anim/nightstick.zip"),
	Asset("ANIM", "anim/swap_nightstick.zip"),
	Asset("SOUND", "sound/common.fsb"),
}
 
local prefabs =
{
	"nightstickfire",
}    


local function onequip(inst, owner) 
    inst.components.burnable:Ignite()
    owner.AnimState:OverrideSymbol("swap_object", "swap_nightstick", "swap_nightstick")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
    
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/morningstar", "torch")
--    inst.SoundEmitter:SetParameter( "torch", "intensity", 1 )

    inst.fire = SpawnPrefab( "nightstickfire" )
    local follower = inst.fire.entity:AddFollower()
    follower:FollowSymbol( owner.GUID, "swap_object", 0, -110, 1 )
    
    --take a percent of fuel next frame instead of this one, so we can remove the torch properly if it runs out at that point
	inst:DoTaskInTime(0, function()
 	    if inst.components.fueled.currentfuel < inst.components.fueled.maxfuel then
		    inst.components.fueled:DoDelta(-inst.components.fueled.maxfuel*.01)
	    end
	end)
end

local function onunequip(inst,owner) 
	inst.fire:Remove()
    inst.fire = nil
    
    inst.components.burnable:Extinguish()
    owner.components.combat.damage = owner.components.combat.defaultdamage 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
    inst.SoundEmitter:KillSound("torch")
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    anim:SetBank("nightstick")
    anim:SetBuild("nightstick")
    anim:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.NIGHTSTICK_DAMAGE)
    inst.components.weapon:SetOnAttack(function(inst)
        if inst and inst:IsValid() and inst.fire and inst.fire:IsValid() then
            inst.fire:OnAttack()
        end
    end)
    inst.components.weapon:SetElectric()
    
    
    -- inst.components.weapon:SetAttackCallback(
    --     function(attacker, target)
    --         if target.components.burnable then
    --             if math.random() < TUNING.TORCH_ATTACK_IGNITE_PERCENT*target.components.burnable.flammability then
    --                 target.components.burnable:Ignite()
    --             end
    --         end
    --     end
    -- )
    
    -- -----------------------------------
    -- inst:AddComponent("lighter")
    -- -----------------------------------
    
    inst:AddComponent("inventoryitem")
    -----------------------------------
    
    inst:AddComponent("equippable")

    inst.components.equippable:SetOnPocket( function(owner) inst.components.burnable:Extinguish()  end)
    
    inst.components.equippable:SetOnEquip( onequip )
     
    inst.components.equippable:SetOnUnequip( onunequip )
    

    -----------------------------------
    
    inst:AddComponent("inspectable")
 
    -----------------------------------
    
    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil
    --inst.components.burnable:AddFXOffset(Vector3(0,1.5,-.01))
    
    -----------------------------------
    
    inst:AddComponent("fueled")
    

    -- inst.components.fueled:SetUpdateFn( function()
    --     if GetSeasonManager():IsRaining() then
    --         inst.components.fueled.rate = 1 + TUNING.TORCH_RAIN_RATE*GetSeasonManager():GetPrecipitationRate()
    --     else
    --         inst.components.fueled.rate = 1
    --     end
    -- end)


    inst.components.fueled:SetSectionCallback(
        function(section)
            if section == 0 then
                --when we burn out
                if inst.components.burnable then 
					inst.components.burnable:Extinguish() 
				end
				
                if inst.components.inventoryitem and inst.components.inventoryitem:IsHeld() then
                    local owner = inst.components.inventoryitem.owner
                    inst:Remove()
                    
                    if owner then
                        owner:PushEvent("nightstickranout", {nightstick = inst})
                    end
                end
                
            end
        end)
    inst.components.fueled:InitializeFuelLevel(TUNING.NIGHTSTICK_FUEL)
    inst.components.fueled:SetDepletedFn(function(inst) inst:Remove() end)
    
    return inst
end

return Prefab( "common/inventory/nightstick", fn, assets, prefabs) 
