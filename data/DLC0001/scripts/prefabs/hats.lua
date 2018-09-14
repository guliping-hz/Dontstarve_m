
function MakeHat(name)

    local fname = "hat_"..name
    local symname = name.."hat"
    local texture = symname..".tex"
    local prefabname = symname
    local assets=
        {
            Asset("ANIM", "anim/"..fname..".zip"),
            --Asset("IMAGE", texture),
        }

    if name == "miner" then
        table.insert(assets, Asset("ANIM", "anim/hat_miner_off.zip"))
    end

    if name == "mole" then
        table.insert(assets, Asset("IMAGE", "images/colour_cubes/mole_vision_on_cc.tex"))
        table.insert(assets, Asset("IMAGE", "images/colour_cubes/mole_vision_off_cc.tex"))
    end

    local function generic_perish(inst)
        inst:Remove()
    end

    local function onequip(inst, owner, fname_override)
        local build = fname_override or fname
        owner.AnimState:OverrideSymbol("swap_hat", build, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")
        
        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAIR")
        end
        
        if inst.components.fueled then
            inst.components.fueled:StartConsuming()        
        end
    end

    local function onunequip(inst, owner)
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAIR")
        end

        if inst.components.fueled then
            inst.components.fueled:StopConsuming()        
        end
    end
    
    local function opentop_onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")
        
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAIR")

        if inst.components.fueled then
            inst.components.fueled:StartConsuming()        
        end
    end


    local function simple()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(symname)
        inst.AnimState:SetBuild(fname)
        inst.AnimState:PlayAnimation("anim")

        inst:AddTag("hat")

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD

        inst.components.equippable:SetOnEquip( onequip )

        inst.components.equippable:SetOnUnequip( onunequip )

        return inst
    end

    local function straw()
        local inst = simple()
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.STRAWHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)

        return inst
    end

    local function bee()
        local inst = simple()
        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_BEEHAT, TUNING.ARMOR_BEEHAT_ABSORPTION)
        inst.components.armor:SetTags({"bee"})
        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
        return inst
    end
   
   
   
    local function earmuffs()
        local inst = simple()
        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)
        inst.components.equippable:SetOnEquip( opentop_onequip )
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.EARMUFF_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
		inst.AnimState:SetRayTestOnBB(true)
		return inst
    end
   
    local function winter()
        local inst = simple()
		inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
        
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.WINTERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
        
		return inst
    end

    local function football()
        local inst = simple()
		inst:AddComponent("armor")

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
		
        inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)
		return inst
    end

    local function ruinshat_proc(inst, owner)
        inst:AddTag("forcefield")
        inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
        local fx = SpawnPrefab("forcefieldfx")
        fx.entity:SetParent(owner.entity)
        fx.Transform:SetPosition(0, 0.2, 0)
        local fx_hitanim = function()
            fx.AnimState:PlayAnimation("hit")
            fx.AnimState:PushAnimation("idle_loop")
        end
        fx:ListenForEvent("blocked", fx_hitanim, owner)

        inst.components.armor.ontakedamage = function(inst, damage_amount)
            if owner then
                local sanity = owner.components.sanity
                if sanity then
                    local unsaneness = damage_amount * TUNING.ARMOR_RUINSHAT_DMG_AS_SANITY
                    sanity:DoDelta(-unsaneness, false)
                end
            end
        end

        inst.active = true

        owner:DoTaskInTime(--[[Duration]] TUNING.ARMOR_RUINSHAT_DURATION, function()
            fx:RemoveEventCallback("blocked", fx_hitanim, owner)
            fx.kill_fx(fx)
            if inst:IsValid() then
                inst:RemoveTag("forcefield")
                inst.components.armor.ontakedamage = nil
                inst.components.armor:SetAbsorption(TUNING.ARMOR_RUINSHAT_ABSORPTION)
                owner:DoTaskInTime(--[[Cooldown]] TUNING.ARMOR_RUINSHAT_COOLDOWN, function() inst.active = false end)
            end
        end)
    end

    local function tryproc(inst, owner)
        if not inst.active and math.random() < --[[ Chance to proc ]] TUNING.ARMOR_RUINSHAT_PROC_CHANCE then
           ruinshat_proc(inst, owner)
        end
    end

    local function ruins_onunequip(inst, owner)
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAIR")
        end

        owner:RemoveEventCallback("attacked", inst.procfn)

    end
    
    local function ruins_onequip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")
        
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAIR")
        inst.procfn = function() tryproc(inst, owner) end
        owner:ListenForEvent("attacked", inst.procfn)
    end

    local function ruins()
        local inst = simple()
        inst:AddComponent("armor")
        inst:AddTag("metal")
        inst.components.armor:InitCondition(TUNING.ARMOR_RUINSHAT, TUNING.ARMOR_RUINSHAT_ABSORPTION)

        inst.components.equippable:SetOnEquip(ruins_onequip)
        inst.components.equippable:SetOnUnequip(ruins_onunequip)

        return inst
    end

    local function feather_equip(inst, owner)
        onequip(inst, owner)
        local ground = GetWorld()
        if ground and ground.components.birdspawner then
            ground.components.birdspawner:SetSpawnTimes(TUNING.BIRD_SPAWN_DELAY_FEATHERHAT)
            ground.components.birdspawner:SetMaxBirds(TUNING.BIRD_SPAWN_MAX_FEATHERHAT)
        end
    end
    local function feather_unequip(inst, owner)
        onunequip(inst, owner)
        local ground = GetWorld()
        if ground and ground.components.birdspawner then
            ground.components.birdspawner:SetSpawnTimes(TUNING.BIRD_SPAWN_DELAY)
            ground.components.birdspawner:SetMaxBirds(TUNING.BIRD_SPAWN_MAX)
        end
    end
    local function feather()
        local inst = simple()
        
		inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
        
        inst.components.equippable:SetOnEquip( feather_equip )
        inst.components.equippable:SetOnUnequip( feather_unequip )
        
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.FEATHERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
        
		return inst
    end

    local function beefalo_equip(inst, owner)
        onequip(inst, owner)
        owner:AddTag("beefalo")
    end
    local function beefalo_unequip(inst, owner)
        onunequip(inst, owner)
        owner:RemoveTag("beefalo")
    end
    local function beefalo()
        local inst = simple()
        inst.components.equippable:SetOnEquip( beefalo_equip )
        inst.components.equippable:SetOnUnequip( beefalo_unequip )

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
        
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.BEEFALOHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
        
        
        return inst
    end

    local function walrus()
        local inst = simple()

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
        
        
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
        
        return inst
    end
    local function miner_turnon(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if inst.components.fueled:IsEmpty() then
            if owner then
                onequip(inst, owner, "hat_miner_off")
            end
        else
            if owner then
                onequip(inst, owner)
            end

            inst.components.fueled:StartConsuming()
            inst.SoundEmitter:PlaySound("dontstarve/common/minerhatAddFuel")
            inst.Light:Enable(true)
        end
    end

    local function miner_turnoff(inst, ranout)
        if inst.components.equippable and inst.components.equippable:IsEquipped() then
            local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
            if owner then
                onequip(inst, owner, "hat_miner_off")
            end
        end
        inst.components.fueled:StopConsuming()
        inst.SoundEmitter:PlaySound("dontstarve/common/minerhatOut")

        inst.Light:Enable(false)
    end

    local function miner_equip(inst, owner)
        miner_turnon(inst)
    end
    local function miner_unequip(inst, owner)
        onunequip(inst, owner)
        miner_turnoff(inst)
    end
    local function miner_perish(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner then
            owner:PushEvent("torchranout", {torch = inst})
        end
        miner_turnoff(inst)
    end
    local function miner_drop(inst)
        miner_turnoff(inst)
    end
    local function miner_takefuel(inst)
        if inst.components.equippable and inst.components.equippable:IsEquipped() then
            miner_turnon(inst)
        end
    end

    local function miner()
        local inst = simple()

        inst.entity:AddSoundEmitter()        

        local light = inst.entity:AddLight()
        light:SetFalloff(0.4)
        light:SetIntensity(.7)
        light:SetRadius(2.5)
        light:SetColour(180/255, 195/255, 150/255)
        light:Enable(false)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.inventoryitem:SetOnDroppedFn( miner_drop )
        inst.components.equippable:SetOnEquip( miner_equip )
        inst.components.equippable:SetOnUnequip( miner_unequip )

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "CAVE"
        inst.components.fueled:InitializeFuelLevel(TUNING.MINERHAT_LIGHTTIME)
        inst.components.fueled:SetDepletedFn(miner_perish)
        inst.components.fueled.ontakefuelfn = miner_takefuel
        inst.components.fueled.accepting = true
        return inst
    end


    local function spider_disable(inst)
        if inst.updatetask then
            inst.updatetask:Cancel()
            inst.updatetask = nil
        end
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            
            if not owner:HasTag("spiderwhisperer") then --Webber has to stay a monster.
                owner:RemoveTag("monster")

                for k,v in pairs(owner.components.leader.followers) do
                    if k:HasTag("spider") and k.components.combat then
                        k.components.combat:SuggestTarget(owner)
                    end
                end
                owner.components.leader:RemoveFollowersByTag("spider")
            else
                owner.components.leader:RemoveFollowersByTag("spider", function(follower)
                    if follower and follower.components.follower then
                        if follower.components.follower:GetLoyaltyPercent() > 0 then
                            return false
                        else
                            return true
                        end
                    end
                end)
            end

        end
    end
    local function spider_update(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner.components.leader:RemoveFollowersByTag("pig")
            local x,y,z = owner.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x,y,z, TUNING.SPIDERHAT_RANGE, {"spider"})
            for k,v in pairs(ents) do
                if v.components.follower and not v.components.follower.leader and not owner.components.leader:IsFollower(v) and owner.components.leader.numfollowers < 10 then
                    owner.components.leader:AddFollower(v)
                end
            end
        end
    end
    local function spider_enable(inst)
        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
        if owner and owner.components.leader then
            owner.components.leader:RemoveFollowersByTag("pig")
            owner:AddTag("monster")
        end
        inst.updatetask = inst:DoPeriodicTask(0.5, spider_update, 1)
    end
    local function spider_equip(inst, owner)
        onequip(inst, owner)
        spider_enable(inst)
    end
    local function spider_unequip(inst, owner)
        onunequip(inst, owner)
        spider_disable(inst)
    end

    local function spider_perish(inst)
        spider_disable(inst)
        inst:Remove()
    end


	local function top()
		local inst = simple()
		inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.TOPHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

		return inst
	end
	
    local function spider()
        local inst = simple()

		inst.components.equippable.dapperness = -TUNING.DAPPERNESS_SMALL

        inst.components.inventoryitem:SetOnDroppedFn( spider_disable )
        inst.components.equippable:SetOnEquip( spider_equip )
        inst.components.equippable:SetOnUnequip( spider_unequip )
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "SPIDERHAT"
        inst.components.fueled:InitializeFuelLevel(TUNING.SPIDERHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(spider_perish)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end

    local function stopusingbush(inst, data)
        local hat = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if hat and not (data.statename == "hide_idle" or data.statename == "hide") then
            hat.components.useableitem:StopUsingItem()
        end
    end

    local function onequipbush(inst, owner)
        owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")
        
        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAIR")
        end
        
        if inst.components.fueled then
            inst.components.fueled:StartConsuming()        
        end

        inst:ListenForEvent("newstate", stopusingbush, owner) 
    end

    local function onunequipbush(inst, owner)
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAIR")
        end

        if inst.components.fueled then
            inst.components.fueled:StopConsuming()        
        end

        inst:RemoveEventCallback("newstate", stopusingbush, owner)
    end

    local function onusebush(inst)
        local owner = inst.components.inventoryitem.owner
        if owner then
            owner.sg:GoToState("hide")
        end
    end
    
    local function bush()
        local inst = simple()

        inst:AddTag("hide")
        inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/bushhat"

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(onusebush)

        inst.components.equippable:SetOnEquip( onequipbush )
        inst.components.equippable:SetOnUnequip( onunequipbush )


        return inst
    end
    
	local function flower()
		local inst = simple()
		inst.components.equippable.dapperness = TUNING.DAPPERNESS_TINY
	
        inst:AddTag("show_spoilage")

		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
		inst.components.perishable:StartPerishing()
		inst.components.perishable:SetOnPerishFn(generic_perish)
        inst.components.equippable:SetOnEquip( opentop_onequip )
		return inst
    end 

    local function slurtle()
        local inst = simple()
        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_SLURTLEHAT, TUNING.ARMOR_SLURTLEHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
        
        return inst
    end
    
    local function wathgrithr()
        local inst = simple()
        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_WATHGRITHRHAT, TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("characterspecific")
        inst.components.characterspecific:SetOwner("wathgrithr")

        return inst
    end

    local function ice()
        local inst = simple()
        
        inst:AddComponent("heater")
        inst.components.heater.iscooler = true
        inst.components.heater.equippedheat = TUNING.ICEHAT_COOLER

        inst.components.equippable.walkspeedmult = 0.9
        inst.components.equippable.equippedmoisture = 1
        inst.components.equippable.maxequippedmoisture = 49 -- Meter reading rounds up, so set 1 below

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()

        inst:AddComponent("waterproofer")
        inst.components.waterproofer.effectiveness = 0 

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_FASTISH)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(function(inst)
            local player = GetPlayer()
            if inst.components.inventoryitem and player and inst.components.inventoryitem:IsHeldBy(player) then
                if player.components.moisture then
                    player.components.moisture:DoDelta(20)
                end
            end
            inst:Remove()
        end)

        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = "ICE"
        inst.components.repairable.announcecanfix = false

        inst:AddTag("show_spoilage")
        inst:AddTag("frozen")

        return inst
    end

    local function mole_onequip(inst, owner)
		onequip(inst, owner)
        if owner ~= GetPlayer() then return end
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_on")
        if GetClock() and GetWorld() and GetWorld().components.colourcubemanager then
            GetClock():SetNightVision(true)
            if GetClock():IsDay() and not GetWorld():IsCave() then
                GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_off_cc.tex", .25)
            else -- Dusk and Night
                GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_on_cc.tex", .25)
            end
        end
    end

    local function mole_onunequip(inst, owner)
        onunequip(inst, owner)
        if owner ~= GetPlayer() then return end
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_off")
        if GetClock() then
            GetClock():SetNightVision(false)
        end
        if GetWorld() and GetWorld().components.colourcubemanager then
            GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
        end
    end

    local function mole_perish(inst)
        if inst.components.inventoryitem:GetGrandOwner() == GetPlayer() and inst.components.equippable and inst.components.equippable:IsEquipped() then
            if GetClock() then
                GetClock():SetNightVision(false)
            end
            if GetWorld() and GetWorld().components.colourcubemanager then
                GetWorld().components.colourcubemanager:SetOverrideColourCube(nil, .5)
            end
        end
        generic_perish(inst)
    end

    local function mole()
        local inst = simple()
        inst.components.equippable:SetOnEquip( mole_onequip )
        inst.components.equippable:SetOnUnequip( mole_onunequip )

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "MOLEHAT"
        inst.components.fueled:InitializeFuelLevel(TUNING.MOLEHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn( mole_perish )
        inst.components.fueled.accepting = true
        inst:AddTag("no_sewing")

        inst:ListenForEvent("daytime", function(it)
            if GetWorld():IsCave() then return end
            if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() and not GetWorld():IsCave() then
                GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_off_cc.tex", 2)
            end
        end, GetWorld())
        inst:ListenForEvent("dusktime", function(it)
            if GetWorld():IsCave() then return end
            if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() then
                GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_on_cc.tex", 2)
            end
        end, GetWorld())
        inst:ListenForEvent("nighttime", function(it)
            if GetWorld():IsCave() then return end
            if inst.components.equippable and inst.components.equippable:IsEquipped() and inst.components.inventoryitem:GetGrandOwner() == GetPlayer() then
                GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/mole_vision_on_cc.tex", 2)
            end
        end, GetWorld())

        return inst
    end

    local function rain()
        local inst = simple()
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.RAINHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)
        
        inst.components.equippable.insulated = true

        return inst
    end

    local function eyebrella_updatesound(inst)
        local soundShouldPlay = GetSeasonManager():IsRaining() and inst.components.equippable:IsEquipped()
        if soundShouldPlay ~= inst.SoundEmitter:PlayingSound("umbrellarainsound") then
            if soundShouldPlay then
                inst.SoundEmitter:PlaySound("dontstarve/rain/rain_on_umbrella", "umbrellarainsound") 
            else
                inst.SoundEmitter:KillSound("umbrellarainsound")
            end
        end
    end  
        
    local function eyebrella_onequip(inst, owner) 
        opentop_onequip(inst, owner)
        eyebrella_updatesound(inst)
        
        owner.DynamicShadow:SetSize(2.2, 1.4)
    end

    local function eyebrella_onunequip(inst, owner) 
        onunequip(inst, owner)
        eyebrella_updatesound(inst)

        owner.DynamicShadow:SetSize(1.3, 0.6)
    end
    
    local function eyebrella_perish(inst)
        inst.SoundEmitter:KillSound("umbrellarainsound")
        if inst.components.inventoryitem and inst.components.inventoryitem.owner then
            inst.components.inventoryitem.owner.DynamicShadow:SetSize(1.3, 0.6)
        end
        generic_perish(inst)
    end

    local function eyebrella()
        local inst = simple()

        inst.entity:AddSoundEmitter()

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.EYEBRELLA_PERISHTIME)
        inst.components.fueled:SetDepletedFn( eyebrella_perish )

        inst.components.equippable:SetOnEquip( eyebrella_onequip )
        inst.components.equippable:SetOnUnequip( eyebrella_onunequip )

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()
        
        inst.components.equippable.insulated = true


        inst:ListenForEvent("rainstop", function() eyebrella_updatesound(inst) end, GetWorld()) 
        inst:ListenForEvent("rainstart", function() eyebrella_updatesound(inst) end, GetWorld()) 

        return inst
    end

    local function catcoon()
        local inst = simple()
        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.CATCOONHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL)

        return inst
    end

    local function watermelon()
        local inst = simple()
        
        inst:AddComponent("heater")
        inst.components.heater.iscooler = true
        inst.components.heater.equippedheat = TUNING.WATERMELON_COOLER

        inst.components.equippable.equippedmoisture = 0.5
        inst.components.equippable.maxequippedmoisture = 32 -- Meter reading rounds up, so set 1 below

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)
        inst.components.insulator:SetSummer()

        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
        inst.components.perishable:StartPerishing()
        inst.components.perishable:SetOnPerishFn(generic_perish)
        inst:AddTag("show_spoilage")

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_SMALL

        inst:AddTag("icebox_valid")

        return inst
    end

    local fn = nil
    local prefabs = nil
    if name == "bee" then
        fn = bee
    elseif name == "straw" then
        fn = straw
    elseif name == "top" then
		fn = top
    elseif name == "feather" then
		fn = feather
    elseif name == "football" then
		fn = football
    elseif name == "flower" then
		fn = flower
    elseif name == "spider" then
		fn = spider
    elseif name == "miner" then
        fn = miner
        prefabs =
        {
            "strawhat",
        }
    elseif name == "earmuffs" then
		fn = earmuffs
    elseif name == "winter" then
		fn = winter
    elseif name == "beefalo" then
		fn = beefalo
    elseif name == "bush" then
        fn = bush
    elseif name == "walrus" then
        fn = walrus
    elseif name == "slurtle" then
        fn = slurtle
    elseif name == "ruins" then
        prefabs = {"forcefieldfx"}
        fn = ruins
    elseif name == "wathgrithr" then
        fn = wathgrithr
    elseif name == "ice" then
        fn = ice
    elseif name == "mole" then
        fn = mole
    elseif name == "rain" then
        fn = rain
    elseif name == "catcoon" then
        fn = catcoon
    elseif name == "watermelon" then
        fn = watermelon
    elseif name == "eyebrella" then
        fn = eyebrella
    end


    return Prefab( "common/inventory/"..prefabname, fn or simple, assets, prefabs)
end

return  MakeHat("straw"),
        MakeHat("top"),
        MakeHat("beefalo"),
        MakeHat("feather"),
        MakeHat("bee"),
        MakeHat("miner"),
        MakeHat("spider"),
        MakeHat("football"),
        MakeHat("earmuffs"),
        MakeHat("winter"),
        MakeHat("bush"),
        MakeHat("flower"),
        MakeHat("walrus"),
        MakeHat("slurtle"),
        MakeHat("ruins"),
        MakeHat("wathgrithr", true),
        MakeHat("ice", true),
        MakeHat("mole", true),
        MakeHat("rain", true),
        MakeHat("catcoon", true),
        MakeHat("watermelon", true),
        MakeHat("eyebrella", true)
