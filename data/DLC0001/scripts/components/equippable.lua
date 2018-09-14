local Equippable = Class(function(self, inst)
    self.inst = inst
    self.isequipped = false
    self.equipslot = EQUIPSLOTS.HANDS
    self.onequipfn = nil
    self.onunequipfn = nil
    self.onpocketfn = nil
    self.equipstack = false
    self.dapperness = 0
    self.dapperfn = nil
    self.insulated = false
    self.equippedmoisture = 0
    self.maxequippedmoisture = 0
end)

function Equippable:IsInsulated() -- from electricity, not temperature
    return self.insulated
end

function Equippable:SetOnEquip(fn)
    self.onequipfn = fn
end

function Equippable:SetOnPocket(fn)
    self.onpocketfn = fn
end

function Equippable:SetOnUnequip(fn)
    self.onunequipfn = fn
end

function Equippable:IsEquipped()
    return self.isequipped
end

function Equippable:Equip(owner, slot)
    self.isequipped = true
    
    if self.inst.components.burnable then
        self.inst.components.burnable:StopSmoldering()
    end
    
    if self.onequipfn then
        self.onequipfn(self.inst, owner)
    end
    self.inst:PushEvent("equipped", {owner=owner, slot=slot})

end

function Equippable:ToPocket(owner)
    if self.onpocketfn then
        self.onpocketfn(self.inst, owner)
    end
end

function Equippable:Unequip(owner, slot)
    self.isequipped = false
    
    if self.onunequipfn then
        self.onunequipfn(self.inst, owner)
    end
    
    self.inst:PushEvent("unequipped", {owner=owner, slot=slot})
end

function Equippable:GetWalkSpeedMult()
	return self.walkspeedmult or 1.0
end

function Equippable:CollectInventoryActions(doer, actions)
    if not self.isequipped then
        table.insert(actions, ACTIONS.EQUIP)
    else
        table.insert(actions, ACTIONS.UNEQUIP)
    end
end

function Equippable:GetDapperness(owner)
    local dapperness = self.dapperness
    
    if self.dapperfn then
        dapperness = self.dapperfn(self.inst, owner)
    end

    local mm = GetWorld().components.moisturemanager
    
    if mm and mm:IsEntityWet(self.inst) then
        dapperness = dapperness + TUNING.WET_ITEM_DAPPERNESS
    end

    return dapperness
end

function Equippable:GetEquippedMoisture()
    return {moisture = self.equippedmoisture, max = self.maxequippedmoisture}
end

return Equippable