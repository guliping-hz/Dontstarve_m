local InventoryItem = Class(function(self, inst)
    self.inst = inst
    self.owner = nil
    self.canbepickedup = true
    self.onpickupfn = nil    
    self.isnew = true
    self.nobounce = false
    self.cangoincontainer = true
    self.inst:ListenForEvent("stacksizechange", function(inst, data) if self.owner then self.owner:PushEvent("stacksizechange", {item=self.inst, src_pos = data.src_pos}) end end)
	self.keepondeath = false
    self.imagename = nil
    self.onactiveitemfn = nil
    self.candrop = true

    --Variables specifically for moisture changes.

    self.drytask = nil
    self.wettask = nil
    self.dry = nil
    self.time_to_moisture_change = nil
    self.moisture_change_start = nil

    -- Trappable?
    self.trappable = true
    if self.canbepickedup and not self.inst.components.waterproofer then
        if not self.inst.components.moisturelistener then 
            self.inst:AddComponent("moisturelistener")
        end
    end
end)

function InventoryItem:GetDebugString()
    return "inventory image name set to: " ..tostring(self.imagename)
end

function InventoryItem:SetOwner(owner)
    self.owner = owner
end

function InventoryItem:ClearOwner(owner)
    self.owner = nil
end

function InventoryItem:SetOnDroppedFn(fn)
    self.ondropfn = fn
end

function InventoryItem:SetOnActiveItemFn(fn)
    self.onactiveitemfn = fn 
end

function InventoryItem:SetOnPickupFn(fn)
    self.onpickupfn = fn
end

function InventoryItem:SetOnPutInInventoryFn(fn)
    self.onputininventoryfn = fn
end

function InventoryItem:GetSlotNum()
    if self.owner then
        local ct = self.owner.components.container or self.owner.components.inventory

        if ct then
            return ct:GetItemSlot(self.inst)
        end
    end
end

function InventoryItem:GetContainer()
    if self.owner then
        return self.owner.components.container or self.owner.components.inventory
    end
end

function InventoryItem:HibernateLivingItem()
    if self.inst.components.brain then
        BrainManager:Hibernate(self.inst)
    end

    if self.inst.SoundEmitter then
        self.inst.SoundEmitter:KillAllSounds()
    end
end

function InventoryItem:WakeLivingItem()
    if self.inst.components.brain then
        BrainManager:Wake(self.inst)
    end
end

function InventoryItem:OnPutInInventory(owner)
--    print(string.format("InventoryItem:OnPutInInventory[%s]", self.inst.prefab))
--    print("   transform=", Point(self.inst.Transform:GetWorldPosition()))
    self.inst.components.inventoryitem:SetOwner(owner)
	owner:AddChild(self.inst)
	self.inst:RemoveFromScene()
    self.inst.Transform:SetPosition(0,0,0) -- transform is now local?
	self.inst.Transform:UpdateTransform()
--    print("   updated transform=", Point(self.inst.Transform:GetWorldPosition()))
    self:HibernateLivingItem()
    if self.onputininventoryfn then
        self.onputininventoryfn(self.inst, owner)
    end
    self.inst:PushEvent("onputininventory")
end

function InventoryItem:OnRemoved()
    if self.owner then
        self.owner:RemoveChild(self.inst)
    end
    self:ClearOwner()
    self.inst:ReturnToScene()
    self:WakeLivingItem()
end

function InventoryItem:IsSheltered()
    return self:IsHeld() and 
    ((self.owner.components.container) or (self.owner.components.inventory and self.owner.components.inventory:IsWaterproof()))
end

function InventoryItem:OnDropped(randomdir)
    --print("InventoryItem:OnDropped", self.inst, randomdir)
    
	if not self.inst:IsValid() then
		return
	end
	
    --print("OWNER", self.owner, self.owner and Point(self.owner.Transform:GetWorldPosition()))

    local x,y,z = self.inst.Transform:GetWorldPosition()
    --print("pos", x,y,z)

    if self.owner then
        -- if we're owned, our own coords are junk at this point
        x,y,z = self.owner.Transform:GetWorldPosition()
    end

    --print("REMOVED", self.inst)
	self:OnRemoved()

    -- now in world space, if we weren't already
    --print("setpos", x,y,z)
    self.inst.Transform:SetPosition(x,y,z)
    self.inst.Transform:UpdateTransform()

    if self.inst.Physics then
        if not self.nobounce then
            y = y + 1
            --print("setpos", x,y,z)
            self.inst.Physics:Teleport(x,y,z)
		end

		local vel = Vector3(0, 5, 0)
        if randomdir then
            local speed = 2 + math.random()
            local angle = math.random()*2*PI
            vel.x = speed*math.cos(angle)
			vel.y = speed*3
            vel.z = speed*math.sin(angle)
        end
        if self.nobounce then
			vel.y = 0
        end
        --print("vel", vel.x, vel.y, vel.z)
		self.inst.Physics:SetVel(vel.x, vel.y, vel.z)
    end

    if self.ondropfn then
        self.ondropfn(self.inst)
    end
    self.inst:PushEvent("ondropped")
    
    if self.inst.components.propagator then
        self.inst.components.propagator:Delay(5)
    end
end

-- If this function retrns true then it has destroyed itself and you shouldnt give it to the player
function InventoryItem:OnPickup(pickupguy)
    if self.isnew and self.inst.prefab and pickupguy == GetPlayer() then
        ProfileStatsAdd("collect_"..self.inst.prefab)
        self.isnew = false
    end

    if self.inst.components.burnable and self.inst.components.burnable:IsSmoldering() then
        self.inst.components.burnable:StopSmoldering()
        if pickupguy.components.health then
            pickupguy.components.health:DoFireDamage(TUNING.SMOTHER_DAMAGE, nil, true)
            pickupguy:PushEvent("burnt")
        end
    end

    self.inst.Transform:SetPosition(0,0,0)
    self.inst:PushEvent("onpickup", {owner = pickupguy})
    if self.onpickupfn and type(self.onpickupfn) == "function" then
        return self.onpickupfn(self.inst, pickupguy)
    end
end

function InventoryItem:IsHeld()
    return self.owner ~= nil
end

function InventoryItem:IsHeldBy(guy)
    return self.owner == guy
end

function InventoryItem:ChangeImageName(newname)
    self.imagename = newname
    self.inst:PushEvent("imagechange")
end

function InventoryItem:GetImage()
    if self.imagename then        
        return self.imagename..".tex"
    else       
        return self.inst.prefab..".tex"
    end
end

function InventoryItem:GetAtlas()
	return self.atlasname or "images/inventoryimages.xml"
end

function InventoryItem:RemoveFromOwner(wholestack)
    if self.owner then
        if self.owner.components.inventory then
            return self.owner.components.inventory:RemoveItem(self.inst, wholestack)
        elseif self.owner.components.container then
            return self.owner.components.container:RemoveItem(self.inst, wholestack)
        end
    end
end

function InventoryItem:OnRemoveEntity()
    if GetWorld() then
        GetWorld().components.inventorymoisture:ForgetItem(self.inst)
    end
    self:RemoveFromOwner(true)
end

function InventoryItem:CollectInventoryActions(doer, actions)
    --table.insert(actions, ACTIONS.DROP)
end

function InventoryItem:CollectSceneActions(doer, actions)
    if self.canbepickedup and doer.components.inventory and not (self.inst.components.burnable and self.inst.components.burnable:IsBurning()) then
        table.insert(actions, ACTIONS.PICKUP)
    end
end

function InventoryItem:CollectPointActions(doer, pos, actions, right)
    if self.owner and self.owner == doer and not right and self.candrop then
        table.insert(actions, ACTIONS.DROP)
    end
end

function InventoryItem:CompatableInventory(target)
    if self.compatableinventoryfn then
        return self.compatableinventoryfn(self.inst, target)
    end

    return true
end

function InventoryItem:CollectUseActions(doer, target, actions)
    if target.components.container and target.components.container.canbeopened and self:CompatableInventory(target) then
        if self:GetGrandOwner() == doer then
            table.insert(actions, ACTIONS.STORE)
        end
    end
end

function InventoryItem:GetGrandOwner()
	if self.owner then
		if self.owner.components.inventoryitem then
			return self.owner.components.inventoryitem:GetGrandOwner()
		else
			return self.owner
		end
	end
end

function InventoryItem:OnSave()
    local data = {}

    if self.time_to_moisture_change and self.moisture_change_start then
        data.time_to_moisture_change = self.time_to_moisture_change - (GetTime() - self.moisture_change_start)
        data.time_to_moisture_change = math.max(1, RoundDown(data.time_to_moisture_change))
    end

    data.dry = self.dry

    return data
end

function InventoryItem:OnLoad(data)
    if data.dry then
        self.dry = data.dry
        if GetWorld() then
            GetWorld().components.moisturemanager:MakeEntityDry(self.inst)
        end
         if data.time_to_moisture_change then
            self.custom_time = data.time_to_moisture_change
         end
    elseif not data.dry then
        if data.time_to_moisture_change then
            self.custom_time = data.time_to_moisture_change
        end
    end

end



return InventoryItem
