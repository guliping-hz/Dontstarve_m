local Upgradeable = Class(function(self,inst)

	self.inst = inst
	self.onstageadvancefn = nil
	self.onupgradefn = nil
	self.upgradetype = "DEFAULT"

	self.stage = 1
	self.numstages = 3
	self.upgradesperstage = 5
	self.numupgrades = 0
end)

function Upgradeable:SetStage(num)
	self.stage = num
end

function Upgradeable:AdvanceStage()
	self.stage = self.stage + 1
	self.numupgrades = 0

	if self.onstageadvancefn then
		return self.onstageadvancefn(self.inst)
	end
end

function Upgradeable:CanUpgrade()
	return self.stage < self.numstages
end

function Upgradeable:Upgrade(obj)
	if not self:CanUpgrade() then return false end
	self.numupgrades = self.numupgrades + obj.components.upgrader.upgradevalue

	if obj.components.stackable then
		obj.components.stackable:Get(1):Remove()
	else
		obj:Remove()
	end

	if self.onupgradefn then
		self.onupgradefn(self.inst)
	end

	if self:CanUpgrade() and self.numupgrades >= self.upgradesperstage then
		self:AdvanceStage()
	end
	return true
end

function Upgradeable:OnSave()
	local data = {}
	data.numupgrades = self.numupgrades
	data.stage = self.stage
	return data 
end

function Upgradeable:OnLoad(data)
	self.numupgrades = data.numupgrades
	self.stage = data.stage
end

return Upgradeable