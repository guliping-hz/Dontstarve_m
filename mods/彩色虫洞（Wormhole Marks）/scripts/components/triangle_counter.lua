local Triangle_Counter = Class(function(self, inst)
    self.inst = inst
	self.triangle_count = 1
end)

function Triangle_Counter:Set()
	self.triangle_count = self.triangle_count + 1
end

function Triangle_Counter:Get()
	return self.triangle_count
end

function Triangle_Counter:OnSave()
	local data = {}
	data.triangle_count = self.triangle_count
	return data
end

function Triangle_Counter:OnLoad(data)
	if data then
		self.triangle_count = data.triangle_count
	else
		self.triangle_count = 1
	end
end

return Triangle_Counter