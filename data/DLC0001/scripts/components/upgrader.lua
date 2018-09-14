local Upgrader = Class(function(self,inst)

	self.inst = inst

	self.canupgradefn = nil
	self.upgradetype = "DEFAULT"
	self.upgradevalue = 1

end)

function Upgrader:CanUpgrade(target, doer)
	if not self.upgradetype == target.components.upgradeable.upgradetype then
		return false
	end

	if self.canupgradefn then
		return self.canupgradefn(self.inst, target, doer)
	end
	return true
end

function Upgrader:CollectUseActions(doer, target, actions)
	if target.components.upgradeable and self:CanUpgrade(target, doer) then
		table.insert(actions, ACTIONS.UPGRADE)
	end
end

return Upgrader