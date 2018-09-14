local function update(inst)
	inst:PushEvent("deciduousleaffx")
end

local WorldDeciduousTreeUpdater = Class(function(self, inst)

    self.inst = inst
    self.update = update

    self.updatetask = nil
    if GetSeasonManager() and GetSeasonManager():IsAutumn() then
    	self.updatetask = self.inst:DoPeriodicTask(3, function(inst) update(inst) end)
    end

    self.inst:ListenForEvent("seasonChange", function(inst, data)
    	local wdtu = inst.components.worlddeciduoustreeupdater
    	if data.season ~= SEASONS.AUTUMN then
    		if wdtu and wdtu.updatetask then
    			inst:DoTaskInTime(TUNING.MAX_LEAF_CHANGE_TIME, function(inst)
    				if wdtu and wdtu.updatetask then
		    			wdtu.updatetask:Cancel()
		    			wdtu.updatetask = nil
		    		end
	    		end)
    		end
    	elseif wdtu and not wdtu.updatetask then
    		inst:DoTaskInTime(TUNING.MIN_LEAF_CHANGE_TIME, function(inst)
				if wdtu and not wdtu.updatetask then
	    			wdtu.updatetask = inst:DoPeriodicTask(3, function(inst) update(inst) end)
	    		end
	    	end)	
    	end
    end)
end)

return WorldDeciduousTreeUpdater