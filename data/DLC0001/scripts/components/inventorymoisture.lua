local InventoryMoisture = Class(function(self, inst)
	self.inst = inst

	self.itemList = {}

	self.itemIndex = 1

	self.inst:StartUpdatingComponent(self)
end)

function InventoryMoisture:GetLastUpdate(item)
	if not item then return nil end
	if not item.components.moisturelistener then return nil end
	return item.components.moisturelistener.lastUpdate
end

function InventoryMoisture:GetDebugString()
	local str = ""

	str = str..string.format("Total Items: %2.2f, OldestUpdate: %2.2f, itemIndex: %2.2f", 
		#self.itemList,
		self:GetOldestUpdate(),
		self.itemIndex)
	return str
end

function InventoryMoisture:TrackItem(item)
	-- Make sure item can actually get wet
	if not (item and item.components.waterproofer) then
		table.insert(self.itemList, item)
		item.components.moisturelistener:UpdateMoisture(GetTime())
	elseif item and item.components.moisturelistener and item.components.waterproofer then
		-- Somehow we ended up with an item that has moisturelistener AND waterproofer: remove moisturelistener (waterproof items can't get wet)
		item:RemoveComponent("moisturelistener")
	end
end

function InventoryMoisture:ForgetItem(item)
	local toRemove = nil
	for k,v in pairs(self.itemList) do
		if v == item then
			toRemove = k
		end
	end
	if toRemove then
		table.remove(self.itemList, toRemove)
	end

	self.itemIndex = self.itemIndex - 1
	self.itemIndex = math.clamp(self.itemIndex, 1, #self.itemList)
end

function InventoryMoisture:GetOldestUpdate()
	local oldestUpdate = math.huge
	for k,v in pairs(self.itemList) do
		if v.components.moisturelistener and v.components.moisturelistener.lastUpdate < oldestUpdate then
			oldestUpdate = v.components.moisturelistener.lastUpdate
		end
	end
	return oldestUpdate
end

function InventoryMoisture:OnUpdate(dt)
	if #self.itemList <= 0 then return end

	local numToUpdate = #self.itemList * 0.01
	numToUpdate = math.ceil(numToUpdate)
	numToUpdate = math.clamp(numToUpdate, 1, 50)

	local endNum = numToUpdate + self.itemIndex
	endNum = (endNum > #self.itemList) and #self.itemList or endNum
	for i = self.itemIndex, endNum do
		local item = self.itemList[i]
		if item and item.components.moisturelistener then
			item.components.moisturelistener:UpdateMoisture(GetTime() - item.components.moisturelistener.lastUpdate)
		end
	end
	self.itemIndex = endNum + 1
	if self.itemIndex >= #self.itemList then
		self.itemIndex = 1
	end
end

return InventoryMoisture