local Shaver = Class(function(self, inst)
    self.inst = inst
    
end)

function Shaver:CollectInventoryActions(doer, actions)
    if doer.components.beard then
        table.insert(actions, ACTIONS.SHAVE)
    end
end

function Shaver:CollectUseActions(doer, target, actions)
    if target.components.beard then
        table.insert(actions, ACTIONS.SHAVE)
    end
end

return Shaver
