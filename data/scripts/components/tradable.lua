local Tradable = Class(function(self, inst)
    self.inst = inst
    self.goldvalue = 0
end)

function Tradable:CollectUseActions(doer, target, actions)
    if target.components.trader and target.components.trader.enabled then
        table.insert(actions, ACTIONS.GIVE)
    end
end


return Tradable