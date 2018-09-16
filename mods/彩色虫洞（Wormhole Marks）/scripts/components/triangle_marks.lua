local Triangle_Marks = Class(function(self, inst)
    self.inst = inst
	self.marked = false
	self.triangle_number = nil
end)

function Triangle_Marks:MarkEntrance()
	self:GetNumber()
	if self.triangle_number <= 8 then 
		self.marked = true
		self.inst.MiniMapEntity:SetIcon("triangle_"..self.triangle_number..".tex")
	end
end

function Triangle_Marks:MarkExit()
	self:GetNumber()
	if self.triangle_number <= 8 then 
		self.marked = true
		self.inst.MiniMapEntity:SetIcon("triangle_"..self.triangle_number..".tex")
		GetWorld().components.triangle_counter:Set()
	end
end

function Triangle_Marks:GetNumber()
	self.triangle_number = GetWorld().components.triangle_counter:Get()
end

function Triangle_Marks:CheckMark()
	return self.marked
end

function Triangle_Marks:OnSave()
	local data = {}
	data.marked = self.marked
	data.triangle_number = self.triangle_number
	return data
end

function Triangle_Marks:OnLoad(data)
	if data then
		self.marked = data.marked
		self.triangle_number = data.triangle_number
		if self.marked and self.triangle_number then
		self.inst.entity:AddMiniMapEntity()
		self.inst.MiniMapEntity:SetIcon("triangle_"..self.triangle_number..".tex")
		end
	else
		self.marked = false
		self.triangle_number = 0
	end
end

return Triangle_Marks