local Smotherer = Class(function(self, inst)
    self.inst = inst
end)

function Smotherer:CollectUseActions(doer, target, actions)
    if target.components.burnable and target.components.burnable:IsSmoldering() then
        table.insert(actions, ACTIONS.SMOTHER)
    elseif self.inst:HasTag("frozen") and target.components.burnable and target.components.burnable:IsBurning() then
    	table.insert(actions, ACTIONS.MANUALEXTINGUISH)
    end
end


return Smotherer