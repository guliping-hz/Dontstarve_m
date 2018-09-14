local ItemSlot = require "widgets/itemslot"


local InvSlot = Class(ItemSlot, function(self, num, atlas, bgim, owner, container)
    ItemSlot._ctor(self, atlas, bgim, owner)
    self.owner = owner
    self.container = container
    self.num = num
end)

function PackedObjectSlot:GetSlotNum()
    if self.tile and self.tile.item then
        return self.tile.item.components.inventoryitem:GetSlotNum()
    end
end

function PackedObjectSlot:OnControl(control, down)
    if InvSlot._base.OnControl(self, control, down) then return true end
    if down then
        if control == CONTROL_ACCEPT then
            --generic click, with possible modifiers

            self:Click(TheInput:IsControlPressed(CONTROL_FORCE_STACK))

        elseif control == CONTROL_SECONDARY and self.tile and self.tile.item then
            --alt use (usually RMB)
           
           --Maybe say a string?
        
        else
            return false
        end
        return true
    end
end

function PackedObjectSlot:Click()
    local character = GetPlayer()
    local active_item = GetPlayer().components.inventory:GetActiveItem()
    local slot_number = self.num
    local container = self.container
    local inventory = character.components.inventory
    local container_item = container:GetItemInSlot(slot_number)

       
    if active_item then
        --Drop item.
    end        
        
    if container_item then
        
        --Start item placement.

        character.SoundEmitter:PlaySound("dontstarve/HUD/click_object")    
        
    else
        character.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")        
    end 
end

return PackedObjectSlot