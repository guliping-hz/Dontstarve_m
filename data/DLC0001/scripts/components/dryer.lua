local function DoDry(inst)
    local dryer = inst.components.dryer
    if dryer then
	    dryer.task = nil
	    dryer.paused = nil
	    dryer.remainingtime = nil
    	
	    if dryer.ondonecooking then
		    dryer.ondonecooking(inst, dryer.product)
	    end

	    dryer.spoiltargettime = GetTime() + TUNING.PERISH_PRESERVED
	    dryer.spoiltask = inst:DoTaskInTime(TUNING.PERISH_PRESERVED, function(inst)
	    	if not inst:HasTag("burnt") then
		    	local spoiledfood = SpawnPrefab("spoiled_food")
		    	spoiledfood.Transform:SetPosition(inst.Transform:GetWorldPosition())
	            if spoiledfood.components.moisturelistener then
		            spoiledfood.components.moisturelistener.moisture = GetWorld().components.moisturemanager:GetWorldMoisture()
		            spoiledfood.components.moisturelistener:DoUpdate()
		        end
		        if inst.components.dryer then
		        	inst.components.dryer.product = nil
			        inst.components.dryer.spoiltask = nil
			        inst.components.dryer.spoiltargettime = nil
			        if inst.components.dryer.onharvest then
						inst.components.dryer.onharvest(inst)
					end
				end
			end
	    end)
    end
end

local Dryer = Class(function(self, inst)
    self.inst = inst
    self.targettime = nil
    self.ingredient = nil
    self.product = nil
    self.onstartcooking = nil
    self.oncontinuecooking = nil
    self.ondonecooking = nil
    self.oncontinuedone = nil
    self.onharvest = nil
    self.protectedfromrain = false

    self.inst:AddTag("dryer")
end)

function Dryer:SetStartDryingFn(fn)
    self.onstartcooking = fn
end

function Dryer:SetContinueDryingFn(fn)
    self.oncontinuecooking = fn
end

function Dryer:SetDoneDryingFn(fn)
    self.ondonecooking = fn
end

function Dryer:SetContinueDoneFn(fn)
    self.oncontinuedone = fn
end

function Dryer:SetOnHarvestFn(fn)
    self.onharvest = fn
end

function Dryer:GetTimeToDry()
	if self.paused and self.remainingtime then
		return self.remainingtime
	end
	if self.targettime then
		return self.targettime - GetTime()
	end
	return 0
end

function Dryer:IsDrying()
    return self:GetTimeToDry() > 0
end

function Dryer:IsDone()
    return self.product and self.targettime and self:GetTimeToDry() < 0
end

function Dryer:CanDry(dryable)
    return not self:IsDone() and not self:IsDrying()
           and dryable.components.dryable and dryable.components.dryable:GetProduct() and dryable.components.dryable:GetDryingTime()
end

function Dryer:StartDrying(dryable)
	if self:CanDry(dryable) then
	    self.ingredient = dryable.prefab
	    if self.onstartcooking then
		    self.onstartcooking(self.inst, dryable.prefab)
	    end
	    local cooktime = dryable.components.dryable:GetDryingTime()
	    self.product = dryable.components.dryable:GetProduct()
	    if GetSeasonManager() and GetSeasonManager():IsRaining() and self.protectedfromrain ~= true then
	    	self.targettime = GetTime() + cooktime
	    	self:Pause()
	    else
	    	self.targettime = GetTime() + cooktime
	    	self.task = self.inst:DoTaskInTime(cooktime, DoDry)
	    end 
	    dryable:Remove()
		return true
	end
end

function Dryer:StopDrying(reason)
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
	if self.spoiltask then
		self.spoiltask:Cancel()
		self.spoiltask = nil
	end
	if self.product and reason and reason == "fire" then
		local prod = SpawnPrefab(self.product)
		prod.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
	end
	self.product = nil
	self.targettime = nil
end

function Dryer:Pause()
	if self:GetTimeToDry() > 0 and not self.paused then
		self.paused = true
		self.remainingtime = self.targettime - GetTime()
		if self.task then self.task:Cancel() end
		self.task = nil
	end
end

function Dryer:Resume()
	if self.paused then
		self.paused = false
		self.task = self.inst:DoTaskInTime(self.remainingtime, DoDry)
		self.targettime = GetTime() + self.remainingtime
	end	
end

function Dryer:OnSave()
    
    if self:IsDrying() then
		local data = {}
		data.cooking = true
		data.ingredient = self.ingredient
		data.product = self.product
		data.paused = self.paused
		data.time = self:GetTimeToDry()
		return data
    elseif self:IsDone() then
		local data = {}
		data.product = self.product
		data.done = true
		if self.spoiltargettime and self.spoiltargettime > GetTime() then
			data.spoiltime = self.spoiltargettime - GetTime()
		end
		return data		
    end
end

function Dryer:OnLoad(data)
    --self.produce = data.produce
    if data.cooking then
		self.product = data.product
		self.ingredient = data.ingredient
		if self.oncontinuecooking then
			self.oncontinuecooking(self.inst, self.ingredient)
			self.paused = data.paused
			if self.paused then
				self.remainingtime = data.time
			else
				self.targettime = GetTime() + data.time
				self.task = self.inst:DoTaskInTime(data.time, DoDry)
			end
		end
    elseif data.done then
		self.targettime = GetTime() - 1
		self.product = data.product
		self.spoiltargettime = data.spoiltime and GetTime() + data.spoiltime or nil
		if self.spoiltargettime then
			self.spoiltask = self.inst:DoTaskInTime(self.spoiltargettime, function(inst)
				inst.components.dryer.product = nil
		    	local spoiledfood = SpawnPrefab("spoiled_food")
		    	spoiledfood.Transform:SetPosition(inst.Transform:GetWorldPosition())
	            if spoiledfood.components.moisturelistener then
		            spoiledfood.components.moisturelistener.moisture = GetWorld().components.moisturemanager:GetWorldMoisture()
		            spoiledfood.components.moisturelistener:DoUpdate()
		        end
		        inst.components.dryer.spoiltask = nil
		        inst.components.dryer.spoiltargettime = nil
		        if inst.components.dryer.onharvest then
					inst.components.dryer.onharvest(inst)
				end
			end)
		end
		if self.oncontinuedone then
			self.oncontinuedone(self.inst, self.product)
		end
    end
end

function Dryer:GetDebugString()
    local str = nil
    
	if self:IsDrying() then 
		str = "COOKING" 
	elseif self:IsDone() then
		str = "FULL"
	else
		str = "EMPTY"
	end
    if self.targettime and not self.paused then
        str = str.." ("..tostring(self.targettime - GetTime())..")"
    end
    if self.paused then
    	str = str.." PAUSED"
    end
    
    if self.product then
		str = str.. " ".. self.product
    end
    
	return str
end

function Dryer:CollectSceneActions(doer, actions)
	if not self.inst:HasTag("burnt") then
    	if self:IsDone() then
        	table.insert(actions, ACTIONS.HARVEST)
    	end
    end
end

function Dryer:Harvest( harvester )
	if self:IsDone() then
		if self.onharvest then
			self.onharvest(self.inst)
		end
		if self.product then
			if harvester and harvester.components.inventory then
				local loot = SpawnPrefab(self.product)
				if loot then
					if loot and loot.components.perishable then
						loot.components.perishable:SetPercent(1)
						if self.targettime then loot.components.perishable:LongUpdate(GetTime() - self.targettime) end
						loot.components.perishable:StartPerishing()
						if self.spoiltask then
							self.spoiltask:Cancel()
							self.spoiltask = nil
							self.spoiltargettime = nil
						end
					end

                    local targetMoisture = 0

					if self.inst.components.moisturelistener then
						targetMoisture = self.inst.components.moisturelistener:GetMoisture()
					elseif self.inst.components.moisture then
						targetMoisture = self.inst.components.moisture:GetMoisture()
					else
						targetMoisture = GetWorld().components.moisturemanager:GetWorldMoisture()
					end
					
					loot.targetMoisture = targetMoisture
					loot:DoTaskInTime(2*FRAMES, function()
						if loot.components.moisturelistener then 
							loot.components.moisturelistener.moisture = loot.targetMoisture
							loot.targetMoisture = nil
							loot.components.moisturelistener:DoUpdate()
						end
					end)
					harvester.components.inventory:GiveItem(loot, nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
				end
			end
			self.product = nil
		end
		
		return true
	end
end


function Dryer:LongUpdate(dt)
	if self:IsDrying() then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end

		if not self.paused then
			local time_to_wait = self.targettime - GetTime() - dt
			if time_to_wait <= 0 then
				self.targettime = GetTime()
				DoDry(self.inst)
			else
				self.targettime = GetTime() + time_to_wait
				self.task = self.inst:DoTaskInTime(time_to_wait, DoDry)
			end
		end
	end
end


return Dryer
