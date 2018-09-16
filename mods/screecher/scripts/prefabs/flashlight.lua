local assets =
{
	Asset("ANIM", "anim/torch.zip"),
	Asset("ANIM", "anim/swap_torch.zip"),
	Asset("SOUND", "sound/common.fsb"),
    Asset("ATLAS", "images/inventoryimages/flashlight.xml"),
    Asset("IMAGE", "images/inventoryimages/flashlight.tex"),
}
 
local prefabs =
{
    "flashlight_lightpiece",
    --"flashlight_particles",
}    


local function onequip(inst, owner) 
    -- Use torch burning and carry for now
    --inst.components.burnable:Ignite()
    
    -- Use torch sounds for now
	--inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "torch")
	--inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
	--inst.SoundEmitter:SetParameter( "torch", "intensity", 1 )

    -- We still want there to be particles, but they need to be a Follower, not a Child
    --inst.fire = SpawnPrefab( "flashlight_particles" )
    --local follower = inst.fire.entity:AddFollower()
    --follower:FollowSymbol( owner.GUID, "swap_object", 0, -110, 1 )

    -- Spawn 5 lights of increasing radius and offset from the player to fake a cone of light
    local light1 = SpawnPrefab("flashlight_lightpiece")
    light1.Light:SetRadius(0.5)
    local light15 = SpawnPrefab("flashlight_lightpiece")
    light15.Light:SetRadius(0.6)
    local light2 = SpawnPrefab("flashlight_lightpiece")
    light2.Light:SetRadius(0.75)
    local light25 = SpawnPrefab("flashlight_lightpiece")
    light25.Light:SetRadius(0.9)
    local light3 = SpawnPrefab("flashlight_lightpiece")
    light3.Light:SetRadius(1.10)
    local light35 = SpawnPrefab("flashlight_lightpiece")
    light35.Light:SetRadius(1.30)
    local light4 = SpawnPrefab("flashlight_lightpiece")
    light4.Light:SetRadius(1.55)
    local light45 = SpawnPrefab("flashlight_lightpiece")
    light45.Light:SetRadius(1.9)
    local light5 = SpawnPrefab("flashlight_lightpiece")
    light5.Light:SetRadius(2.2)

    ---[[
    local light6 = SpawnPrefab("flashlight_lightpiece")
    light6.Light:SetRadius(0.5)
    light6.Light:SetIntensity(0.5)
    local light7 = SpawnPrefab("flashlight_lightpiece")
    light7.Light:SetRadius(0.5)
    light7.Light:SetIntensity(0.5)
    local light8 = SpawnPrefab("flashlight_lightpiece")
    light7.Light:SetRadius(0.5)
    light7.Light:SetIntensity(0.5)
    ---]]
    --local light8 = SpawnPrefab("flashlight_lightpiece")
    --light8.Light:SetRadius(0.5)

    local lights = { light1, light15, light2, light25, light3, light35, light4, light45, light5, light6, light7, light8 }

    inst:AddComponent("flicker")
    inst:AddComponent("lightfueldimmer")
    inst:AddComponent("lightbeam")
    for i, v in ipairs(lights) do
        --Add the flicker component and give it knowledge of the lights
        inst.components.flicker:AddLight(v)    

        --Add the lightfueldimmer component and give it knowledge of the lights
        inst.components.lightfueldimmer:AddLight(v)

        --Give the lightbeam component knowledge of the lights
        inst.components.lightbeam:AddLight(v)
    end

    inst.components.flicker.normalintensity = 1
    inst.components.lightfueldimmer:SetMaxColour({197/255,197/255,50/255})
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    -- Use torch anims for now
    anim:SetBank("torch")
    anim:SetBuild("torch")
    anim:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    
    -----------------------------------
    --inst:AddComponent("lighter")
    -----------------------------------
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/flashlight.xml"
    -----------------------------------
    inst:AddComponent("equippable")

    inst.components.equippable:SetOnPocket( function(owner) inst.components.burnable:Extinguish()  end)
    
    inst.components.equippable:SetOnEquip( onequip )
    -----------------------------------  
    inst:AddComponent("inspectable")    
    -----------------------------------
    inst:AddComponent("heater")
    inst.components.heater.equippedheat = 5
    -----------------------------------
    --inst:AddComponent("burnable")
    --inst.components.burnable.canlight = false
    --inst.components.burnable.fxprefab = nil
    --inst.components.burnable:AddFXOffset(Vector3(0,1.5,-.01))
    -----------------------------------
    --inst:AddComponent("fueled")

    -- inst.components.fueled:SetUpdateFn( function()
    --     inst.components.fueled.rate = 0
    -- end)

    -- inst.components.fueled:SetSectionCallback(
    --     function(section)
    --         if section == 0 then
    --             --when we burn out
    --             if inst.components.burnable then 
				-- 	inst.components.burnable:Extinguish() 
				-- end
				
    --             if inst.components.inventoryitem and inst.components.inventoryitem:IsHeld() then
    --                 local owner = inst.components.inventoryitem.owner
    --                 inst:Remove()
                    
    --                 if owner then
    --                     owner:PushEvent("torchranout", {torch = inst})
    --                 end
    --             end
                
    --         end
    --     end)
    -- inst.components.fueled:InitializeFuelLevel(TUNING.TORCH_FUEL)
    -- inst.components.fueled:SetDepletedFn(function(inst) inst:Remove() end)
    
    return inst
end

return Prefab( "common/inventory/flashlight", fn, assets, prefabs) 
