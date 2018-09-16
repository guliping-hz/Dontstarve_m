local Wormhole_Counter = Class(function(self, inst)
    self.inst = inst
	self.wormhole_count = 1
end)

function Wormhole_Counter:Set()
	self.wormhole_count = self.wormhole_count + 1
end

function Wormhole_Counter:Get()
	return self.wormhole_count
end

function Wormhole_Counter:OnSave()
	local data = {}
	data.wormhole_count = self.wormhole_count
	return data
end

function Wormhole_Counter:OnLoad(data)
	if data then
		self.wormhole_count = data.wormhole_count
	else
		self.wormhole_count = 1
	end
end

return Wormhole_Counter