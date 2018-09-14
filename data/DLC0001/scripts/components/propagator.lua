local Propagator = Class(function(self, inst)
    self.inst = inst
    self.flashpoint = 100
    self.currentheat = 0
    self.decayrate = 1
    
    self.propagaterange = 3
    self.heatoutput = 5
    
    self.damages = false
    self.damagerange = 3

    self.acceptsheat = false
    self.spreading = false
    self.delay = false

end)


function Propagator:SetOnFlashPoint(fn)
    self.onflashpoint = fn
end

function Propagator:Delay(time)
    self.delay = true
    self.inst:DoTaskInTime(time, function() self.delay = false end)
end

function Propagator:StopUpdating()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function Propagator:StartUpdating()
    if not self.task then
        local dt = .5
        self.task = self.inst:DoPeriodicTask(dt, function() self:OnUpdate(dt) end, dt + math.random()*.67)
    end
end

function Propagator:StartSpreading()
    self.spreading = true
    self:StartUpdating()
end

function Propagator:StopSpreading(reset, heatpct)
    self.spreading = false
    if reset then
        self.currentheat = heatpct and (heatpct * self.flashpoint) or 0
        self.acceptsheat = true
    end
end

function Propagator:AddHeat(amount)
    
    if self.delay or self.inst:HasTag("fireimmune") then
        return;
    end
    
    if self.currentheat <= 0 then
        self:StartUpdating()        
    end
    
    self.currentheat = self.currentheat + amount

    if self.currentheat > self.flashpoint then
        self.acceptsheat = false
        if self.onflashpoint then
            self.onflashpoint(self.inst)
        end
    end
end

function Propagator:Flash()
    if self.acceptsheat and not self.delay then
        self:AddHeat(self.flashpoint+1)
    end
end

function Propagator:OnUpdate(dt)
    
    if self.currentheat > 0 then
        self.currentheat = self.currentheat - dt*self.decayrate
    end

    if self.spreading then
        
        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        local prop_range = self.propagaterange
        if GetSeasonManager():IsSpring() then prop_range = prop_range * TUNING.SPRING_FIRE_RANGE_MOD end
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, prop_range)
        
        for k,v in pairs(ents) do
            if not v:IsInLimbo() then

			    if v ~= self.inst and v.components.propagator and v.components.propagator.acceptsheat then
                    v.components.propagator:AddHeat(self.heatoutput*dt)
			    end

                if v ~= self.inst and v.components.freezable then
                    v.components.freezable:AddColdness((-self.heatoutput/4)*dt)
                    if v.components.freezable:IsFrozen() and v.components.freezable.coldness <= 0 then
                        v.components.freezable:Unfreeze()
                    end
                end

                if v ~= self.inst and v:HasTag("frozen") and not (self.inst.components.heater and self.inst.components.heater.iscooler) then
                    v:PushEvent("firemelt")
                    if not v:HasTag("firemelt") then v:AddTag("firemelt") end
                end
    			
			    if self.damages and v.components.health and v.components.health.vulnerabletoheatdamage then
				    local dsq = distsq(pos, Vector3(v.Transform:GetWorldPosition()))
                    local dmg_range = self.damagerange*self.damagerange
                    if GetSeasonManager():IsSpring() then dmg_range = dmg_range * TUNING.SPRING_FIRE_RANGE_MOD end
				    if dsq < dmg_range then
					    --local percent_damage = math.min(.5, 1- (math.min(1, dsq / self.damagerange*self.damagerange)))
					    v.components.health:DoFireDamage(self.heatoutput*dt)
				    end
			    end
			end
        end
    end
        
    if not self.spreading and not (self.inst.components.heater and self.inst.components.heater.iscooler) then
        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, self.propagaterange, {"frozen", "firemelt"})
        if #ents > 0 then
            for k,v in pairs(ents) do
                v:PushEvent("stopfiremelt")
                v:RemoveTag("firemelt")
            end
        end
        if self.currentheat <= 0 then
            self:StopUpdating()
        end
    end
    
end

return Propagator
