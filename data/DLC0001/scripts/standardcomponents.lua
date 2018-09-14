function DefaultIgniteFn(inst)
	if inst.components.burnable then inst.components.burnable:Ignite() end 
end

function DefaultBurnFn(inst)
    if inst.components.inventoryitem and not inst.components.inventoryitem:IsHeld() then
        inst.inventoryitemdata = 
        {
            {"foleysound", inst.components.inventoryitem.foleysound},
            {"onputininventoryfn", inst.components.inventoryitem.onputininventoryfn},
            {"cangoincontainer", inst.components.inventoryitem.cangoincontainer},
            {"nobounce", inst.components.inventoryitem.nobounce},
            {"canbepickedup", inst.components.inventoryitem.canbepickedup},
            {"imagename", inst.components.inventoryitem.imagename},
            {"atlasname", inst.components.inventoryitem.atlasname},
            {"ondropfn", inst.components.inventoryitem.ondropfn},
            {"onpickupfn", inst.components.inventoryitem.onpickupfn},
            {"trappable", inst.components.inventoryitem.trappable},
            {"isnew", inst.components.inventoryitem.isnew},
            {"keepondeath", inst.components.inventoryitem.keepondeath},
            {"onactiveitemfn", inst.components.inventoryitem.onactiveitemfn},
            {"candrop", inst.components.inventoryitem.candrop},
        }
        inst:RemoveComponent("inventoryitem")
    end
    if not inst:HasTag("tree") and not inst:HasTag("structure") and not inst.persists == false then
        inst.persists = false
    end
end

function DefaultBurntFn(inst)
    if inst.components.growable then
        inst:RemoveComponent("growable")
    end

    if inst.inventoryitemdata then inst.inventoryitemdata = nil end

    if inst.components.workable and inst.components.workable.action ~= ACTIONS.HAMMER then
        inst.components.workable:SetWorkLeft(0)
    end

    local ash = SpawnPrefab("ash")
    ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
    
    if inst.components.stackable then
        ash.components.stackable.stacksize = inst.components.stackable.stacksize
    end

    inst:Remove()
end

function DefaultExtinguishFn(inst)
    if not inst:HasTag("tree") and not inst:HasTag("structure") then
        inst.persists = true
    end
end

function DefaultBurntStructureFn(inst)
    inst:AddTag("burnt")
    inst.components.burnable.canlight = false
    if inst.AnimState then
        inst.AnimState:PlayAnimation("burnt", true)
    end
    inst:PushEvent("burntup")
    if inst.SoundEmitter then
        inst.SoundEmitter:KillSound("idlesound")
        inst.SoundEmitter:KillSound("sound")
        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:KillSound("snd")
    end
    if inst.MiniMapEntity then
        inst.MiniMapEntity:SetEnabled(false)
    end
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
    end
    if inst.components.childspawner then
        if inst:GetTimeAlive() > 5 then inst.components.childspawner:ReleaseAllChildren() end
        inst.components.childspawner:StopSpawning()
        inst:RemoveComponent("childspawner")
    end
    if inst.components.container then
        inst.components.container:DropEverything()
        inst.components.container:Close()
        inst:RemoveComponent("container")
    end
    if inst.components.dryer then
        inst.components.dryer:StopDrying("fire")
        inst:RemoveComponent("dryer")
    end
    if inst.components.stewer then
       inst.components.stewer:StopCooking("fire") 
       inst:RemoveComponent("stewer")
    end
    if inst.components.harvestable then
        inst.components.harvestable:StopGrowing()
        inst:RemoveComponent("harvestable")
    end
    if inst.components.sleepingbag then
        inst:RemoveComponent("sleepingbag")
    end
    if inst.components.grower then
        inst.components.grower:Reset("fire")
        inst:RemoveComponent("grower")
    end
    if inst.components.spawner then
        if inst:GetTimeAlive() > 5 then inst.components.spawner:ReleaseChild() end
        inst:RemoveComponent("spawner")
    end
    if inst.components.prototyper then
        inst:RemoveComponent("prototyper")
    end
    if inst.Light then
        inst.Light:Enable(false)
    end
    if inst.components.burnable then
        inst:RemoveComponent("burnable")
    end
    inst:RemoveTag("dragonflybait_lowprio")
    inst:RemoveTag("dragonflybait_medprio")
    inst:RemoveTag("dragonflybait_highprio")
end

local burnfx = 
{
    character = "character_fire",
    generic = "fire",
}

function MakeSmallBurnable(inst, time, offset, structure)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(time or 5)
    inst.components.burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0) )
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)
    if structure then
        inst.components.burnable:SetOnBurntFn(DefaultBurntStructureFn)
        inst.components.burnable:MakeDragonflyBait(2)
    else
        inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
    end
end

function MakeMediumBurnable(inst, time, offset, structure)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable:SetBurnTime(time or 10)
    inst.components.burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0) )
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)

    if structure then
        inst.components.burnable:SetOnBurntFn(DefaultBurntStructureFn)
        inst.components.burnable:MakeDragonflyBait(2)
    else
        inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
    end
end

function MakeLargeBurnable(inst, time, offset, structure)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(4)
    inst.components.burnable:SetBurnTime(time or 15)
    inst.components.burnable:AddBurnFX(burnfx.generic, offset or Vector3(0, 0, 0) )
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)

    if structure then
        inst.components.burnable:SetOnBurntFn(DefaultBurntStructureFn)
        inst.components.burnable:MakeDragonflyBait(2)
    else
        inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
    end
end

function MakeSmallPropagator(inst)
   
    inst:AddComponent("propagator")
    inst.components.propagator.acceptsheat = true
    inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
    inst.components.propagator.flashpoint = 5 + math.random()*5
    inst.components.propagator.decayrate = 1
    inst.components.propagator.propagaterange = 3
    inst.components.propagator.heatoutput = 8
    
    inst.components.propagator.damagerange = 2
    inst.components.propagator.damages = true
end

function MakeLargePropagator(inst)
    
    inst:AddComponent("propagator")
    inst.components.propagator.acceptsheat = true
    inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
    inst.components.propagator.flashpoint = 15+math.random()*10
    inst.components.propagator.decayrate = 1
    inst.components.propagator.propagaterange = 6
    inst.components.propagator.heatoutput = 12
    
    inst.components.propagator.damagerange = 3
    inst.components.propagator.damages = true
end

function MakeSmallBurnableCharacter(inst, sym, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(1)
    inst.components.burnable:SetBurnTime(6)
    inst.components.burnable.canlight = false
    inst.components.burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym)
    MakeSmallPropagator(inst)
    inst.components.propagator.acceptsheat = false
end

function MakeMediumBurnableCharacter(inst, sym, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable.canlight = false
    inst.components.burnable:SetBurnTime(8)
    inst.components.burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym)
    MakeSmallPropagator(inst)
    inst.components.propagator.acceptsheat = false
end

function MakeLargeBurnableCharacter(inst, sym, offset)
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable.canlight = false
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable:AddBurnFX(burnfx.character, offset or Vector3(0, 0, 1), sym)
    MakeLargePropagator(inst)
    inst.components.propagator.acceptsheat = false
end

local shatterfx = 
{
    character = "shatter",
}

function MakeTinyFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(1)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeSmallFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(2)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeMediumFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(3)
    inst.components.freezable:SetResistance(2)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeLargeFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(4)
    inst.components.freezable:SetResistance(3)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeHugeFreezableCharacter(inst, sym, offset)
    inst:AddComponent("freezable")
    inst.components.freezable:SetShatterFXLevel(5)
    inst.components.freezable:SetResistance(4)
    inst.components.freezable:AddShatterFX(shatterfx.character, offset or Vector3(0, 0, 0), sym)
end

function MakeInventoryPhysics(inst)

    inst.entity:AddPhysics()
    inst.Physics:SetSphere(.5)
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(.1)
    inst.Physics:SetDamping(0)
    inst.Physics:SetRestitution(.5)
    inst.Physics:SetCollisionGroup(COLLISION.ITEMS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)

end


function MakeCharacterPhysics(inst, mass, rad)

    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
end

function MakeGhostPhysics(inst, mass, rad)

    local physics = inst.entity:AddPhysics()
    physics:SetMass(mass)
    physics:SetCapsule(rad, 1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    --inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
end

function ChangeToGhostPhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    --inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
end

function ChangeToCharacterPhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
end

function ChangeToObstaclePhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:SetMass(0) 
    --inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
end

function ChangeToInventoryPhysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
end

function MakeObstaclePhysics(inst, rad, height)

    height = height or 2

    inst:AddTag("blocker")
    inst.entity:AddPhysics()
    --this is lame. Bullet wants 0 mass for static objects, 
    -- for for some reason it is slow when we do that
    
    -- Doesnt seem to slow anything down now.
    inst.Physics:SetMass(0) 
    inst.Physics:SetCapsule(rad,height)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
end

function RemovePhysicsColliders(inst)
    inst.Physics:ClearCollisionMask()
    if inst.Physics:GetMass() > 0 then
        inst.Physics:CollidesWith(COLLISION.GROUND)
    end
end


local function OnGrowSeasonChange(inst)
	if not GetSeasonManager() then return end
	
	if inst.components.pickable then
		if GetSeasonManager():IsWinter() then
			inst.components.pickable:Pause()
		else
			inst.components.pickable:Resume()
		end
	end
end

function MakeNoGrowInWinter(inst)
	if not GetSeasonManager() then return end
	
	inst:ListenForEvent("seasonChange", function() OnGrowSeasonChange(inst) end, GetWorld())
	if GetSeasonManager():IsWinter() then
		OnGrowSeasonChange(inst)
	end
end


function MakeSnowCovered(inst)
	if not GetSeasonManager() then return end
	inst.AnimState:OverrideSymbol("snow", "snow", "snow")
	inst:AddTag("SnowCovered")

	if GetSeasonManager().ground_snow_level < SNOW_THRESH then
		inst.AnimState:Hide("snow")
	else
		inst.AnimState:Show("snow")
	end
end

function MakeFeedablePet(inst, starvetime, oninventory, ondropped)
    if not inst.components.eater then
        inst:AddComponent("eater")
    end

    inst.components.eater:SetOnEatFn(
        function(inst, food)   
            if inst.components.perishable then
                inst.components.perishable:SetPercent(1)
            end 
        end)

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(starvetime)
    inst.components.perishable:StopPerishing()
    inst.components.perishable:SetOnPerishFn(
        function(inst)
            local owner = inst.components.inventoryitem.owner

            inst.components.inventoryitem:RemoveFromOwner(true)

            local stacksize = 1
            if inst.components.stackable then
                stacksize = inst.components.stackable.stacksize
            end
            if owner then
                if inst.components.lootdropper then
                    for i = 1, stacksize do
                        local loots = inst.components.lootdropper:GenerateLoot()
                        for k, v in pairs(loots) do
                            local loot = SpawnPrefab(v)
                            if owner.components.inventory then
                                owner.components.inventory:GiveItem(loot)
                            elseif owner.components.container then
                                owner.components.container:GiveItem(loot)
                            else
                                loot:Remove()
                            end
                        end      
                    end
                end
            end
            inst:Remove()
        end)

    inst.components.inventoryitem:SetOnPutInInventoryFn(function(inst)
        inst.components.perishable:StartPerishing()
        if oninventory then
            oninventory(inst)
        end
    end)

    inst.components.inventoryitem:SetOnDroppedFn(function(inst)
        inst.components.perishable:StopPerishing()
        if ondropped then
            ondropped(inst)
        end
    end) 

    inst:AddTag("show_spoilage")
    inst:AddTag("pet")
end