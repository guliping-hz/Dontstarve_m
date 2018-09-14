local function OnKilled(inst)
    if inst.components.burnable and inst.components.burnable:IsBurning() then
        inst.AnimState:SetMultColour(.2,.2,.2,1)
    end
end

local function DoneBurning(inst)
    local burnable = inst.components.burnable
    if burnable then
        inst:RemoveTag("wildfirestarter")
        inst:RemoveTag("burnable")
        if burnable.dragonflypriority then
            inst:RemoveTag(burnable.dragonprioritytag[burnable.dragonflypriority])
        end

        if burnable.onburnt then
            burnable.onburnt(inst)
        end

        if inst.components.explosive then
            --explosive explode
            inst.components.explosive:OnBurnt()
        end

        if burnable.extinguishimmediately then
            burnable:Extinguish()
        end
    end
end

local Burnable = Class(function(self, inst)
    self.inst = inst
    
    self.flammability = 1
    
    self.fxdata = {}
    self.fxlevel = 1
    self.fxchildren = {}
    self.burning = false
    self.burntime = nil
    self.extinguishimmediately = true
    
    self.onignite = nil
    self.onextinguish = nil
    self.onburnt = nil
    self.canlight = true

    self.lightningimmune = false
    
    self.smoldering = false
    self.inst:AddTag("wildfirestarter")
    self.inst:AddTag("burnable")
    self.inst:ListenForEvent("rainstart", function(it, data)
        inst:DoTaskInTime(2, function(inst)
            if self:IsSmoldering() then
                self:StopSmoldering()
            end
        end)
    end, GetWorld())

    self.dragonprioritytag =
    {
        "dragonflybait_lowprio",
        "dragonflybait_medprio",
        "dragonflybait_highprio",
    }
    
end)

--- Set the function that will be called when the object starts burning
function Burnable:SetOnIgniteFn(fn)
    self.onignite = fn
end

--- Set the function that will be called when the object has burned completely
function Burnable:SetOnBurntFn(fn)
    self.onburnt = fn
end

--- Set the function that will be called when the object stops burning
function Burnable:SetOnExtinguishFn(fn)
    self.onextinguish = fn
end

--- Set the prefab to use for the burning effect. Overrides the default
function Burnable:SetBurningFX(name)
    self.fxprefab = name
end

function Burnable:SetBurnTime(time)
    self.burntime = time
end

function Burnable:IsSmoldering()
    return self.smoldering
end

--- Add an effect to be spawned when burning
-- @param prefab The prefab to spawn as the effect
-- @param offset The offset from the burning entity/symbol that the effect should appear at
-- @param followsymbol Optional symbol for the effect to follow
function Burnable:AddBurnFX(prefab, offset, followsymbol)
    table.insert(self.fxdata, {prefab=prefab, x = offset.x, y = offset.y, z = offset.z, follow=followsymbol})
end

--- Set the level of any current or future burning effects
function Burnable:SetFXLevel(level, percent)
    self.fxlevel = level

	for k,v in pairs(self.fxchildren) do
	    if v.components.firefx then
	        v.components.firefx:SetLevel(level)
            v.components.firefx:SetPercentInLevel(percent or 1)
        end
	end
end

function Burnable:GetLargestLightRadius()
    local largestRadius = nil
    for k,v in pairs(self.fxchildren) do
        if v.Light and v.Light:IsEnabled() then
            local radius = v.Light:GetCalculatedRadius()
            if not largestRadius or radius > largestRadius then
                largestRadius = radius
            end
        end
    end
    return largestRadius
end

function Burnable:IsBurning()
    return self.burning
end

function Burnable:GetDebugString()
    return string.format("%s ", self.burning and "BURNING" or "NOT BURNING")
end

function Burnable:OnRemoveEntity()
    self:StopSmoldering()
	self:KillFX()
end

function Burnable:StartWildfire()
    if not self.burning and not self.smoldering and not self.inst:HasTag("fireimmune") then
        self.smoldering = true
        self.inst:AddTag("smolder")
        self.smoke = SpawnPrefab("smoke_plant")
        if self.smoke then
            if #self.fxdata == 1 and self.fxdata[1].follow then
                local follower = self.smoke.entity:AddFollower()
                follower:FollowSymbol( self.inst.GUID, self.fxdata[1].follow, self.fxdata[1].x,self.fxdata[1].y,self.fxdata[1].z)
            else
                self.inst:AddChild(self.smoke)
            end
            self.smoke.Transform:SetPosition(0,0,0)
        end
        print("Starting a wildfire with "..self.inst.prefab)
        self.smolder_task = self.inst:DoTaskInTime(math.random(TUNING.MIN_SMOLDER_TIME, TUNING.MAX_SMOLDER_TIME), function()
            if self.inst then self:Ignite() end
            self.smolder_task = nil
        end)
    end
end

function Burnable:MakeNotWildfireStarter()
    self.inst:RemoveTag("wildfirestarter")
    self.no_wildfire = true
end

function Burnable:MakeDragonflyBait(priority)
    if self.dragonflypriority then
        self.inst:RemoveTag(self.dragonprioritytag[self.dragonflypriority])
    end
    self.dragonflypriority = priority or 1
    self.inst:AddTag(self.dragonprioritytag[self.dragonflypriority])
end

function Burnable:Ignite(immediate)
    if not self.burning and not self.inst:HasTag("fireimmune") then
        if self.smoldering then
            self.smoldering = false
            self.inst:RemoveTag("smolder")
            if self.inst.components.inspectable then self.inst.components.inspectable.smoldering = false end
            if self.smoke then 
                self.smoke.SoundEmitter:KillSound("smolder")
                self.smoke:Remove() 
            end
        end
        self.inst:AddTag("fire")
        self.burning = true
        self.inst:RemoveTag("wildfirestarter")
        if self.dragonflypriority then
            self.inst:RemoveTag(self.dragonprioritytag[self.dragonflypriority])
        end

        self.inst:ListenForEvent("death", OnKilled)
        
        self:SpawnFX(immediate)
        self.inst:PushEvent("onignite")
        if self.onignite then
            self.onignite(self.inst)
        end

        if self.inst.components.explosive then
            --explosive on ignite
            self.inst.components.explosive:OnIgnite()
        end
        
        if self.inst.components.fueled then
            self.inst.components.fueled:StartConsuming()
        end
        if self.inst.components.propagator then
            self.inst.components.propagator:StartSpreading()
        end
        
        if self.burntime then
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
            self.task = self.inst:DoTaskInTime(self.burntime, DoneBurning)
        end
        
    end
end

function Burnable:LongUpdate(dt)
	
	--kind of a coarse assumption...
	if self.burning then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end
		DoneBurning(self.inst)
	end
	
end

function Burnable:SmotherSmolder(smotherer)
    if smotherer and smotherer.components.finiteuses then
        smotherer.components.finiteuses:Use()
    elseif smotherer and smotherer.components.stackable then
        smotherer.components.stackable:Get(1):Remove()
    elseif smotherer and smotherer.components.health and smotherer.components.combat then
        smotherer.components.health:DoFireDamage(TUNING.SMOTHER_DAMAGE, nil, true)
        smotherer:PushEvent("burnt")
    end
    self:StopSmoldering()
end

function Burnable:StopSmoldering()
    if self.smoldering then
        if self.smoke then 
            self.smoke.SoundEmitter:KillSound("smolder")
            self.smoke:Remove() 
        end
        self.smoldering = false
        self.inst:RemoveTag("smolder")
        if self.smolder_task then
            self.smolder_task:Cancel()
            self.smolder_task = nil
        end
    end
end

function Burnable:RestoreInventoryItemData()
    if self.inst.inventoryitemdata and not self.inst.inventoryitem then
        self.inst:AddComponent("inventoryitem")
        if self.inst.inventoryitemdata["foleysound"] then self.inst.components.inventoryitem.foleysound = self.inst.inventoryitemdata["foleysound"] end
        if self.inst.inventoryitemdata["onputininventoryfn"] then self.inst.components.inventoryitem.onputininventoryfn = self.inst.inventoryitemdata["onputininventoryfn"] end
        if self.inst.inventoryitemdata["cangoincontainer"] then self.inst.components.inventoryitem.cangoincontainer = self.inst.inventoryitemdata["cangoincontainer"] end
        if self.inst.inventoryitemdata["nobounce"] then self.inst.components.inventoryitem.nobounce = self.inst.inventoryitemdata["nobounce"] end
        if self.inst.inventoryitemdata["canbepickedup"] then self.inst.components.inventoryitem.canbepickedup = self.inst.inventoryitemdata["canbepickedup"] end
        if self.inst.inventoryitemdata["imagename"] then 
            self.inst.components.inventoryitem.imagename = self.inst.inventoryitemdata["imagename"] 
            self.inst:PushEvent("imagechange")
        end
        if self.inst.inventoryitemdata["atlasname"] then self.inst.components.inventoryitem.atlasname = self.inst.inventoryitemdata["atlasname"] end
        if self.inst.inventoryitemdata["ondropfn"] then self.inst.components.inventoryitem.ondropfn = self.inst.inventoryitemdata["ondropfn"] end
        if self.inst.inventoryitemdata["onpickupfn"] then self.inst.components.inventoryitem.onpickupfn = self.inst.inventoryitemdata["onpickupfn"] end
        if self.inst.inventoryitemdata["trappable"] then self.inst.components.inventoryitem.trappable = self.inst.inventoryitemdata["trappable"] end
        if self.inst.inventoryitemdata["isnew"] then self.inst.components.inventoryitem.isnew = self.inst.inventoryitemdata["isnew"] end
        if self.inst.inventoryitemdata["keepondeath"] then self.inst.components.inventoryitem.keepondeath = self.inst.inventoryitemdata["keepondeath"] end
        if self.inst.inventoryitemdata["onactiveitemfn"] then self.inst.components.inventoryitem.onactiveitemfn = self.inst.inventoryitemdata["onactiveitemfn"] end
        if self.inst.inventoryitemdata["candrop"] then self.inst.components.inventoryitem.candrop = self.inst.inventoryitemdata["candrop"] end
    end    
end

function Burnable:Extinguish(resetpropagator, pct, smotherer)
    if self.smoldering then
        if self.smoke then 
            self.smoke.SoundEmitter:KillSound("smolder")
            self.smoke:Remove() 
        end
        self.smoldering = false
        self.inst:RemoveTag("smolder")
        if self.smolder_task then
            self.smolder_task:Cancel()
            self.smolder_task = nil
        end
    end
    if smotherer and smotherer.components.finiteuses then
        smotherer.components.finiteuses:Use()
    elseif smotherer and smotherer.components.stackable then
        smotherer.components.stackable:Get(1):Remove()
    end
    if not self.no_wildfire then
        self.inst:AddTag("wildfirestarter")
    end
    if self.dragonflypriority then
        self.inst:AddTag(self.dragonprioritytag[self.dragonflypriority])
    end
    if self.burning then
    
        if self.task then
            self.task:Cancel()
            self.task = nil
        end
        
        if self.inst.components.propagator then
            if resetpropagator then
                self.inst.components.propagator:StopSpreading(true, pct)
            else
                self.inst.components.propagator:StopSpreading()
            end
        end

        self:RestoreInventoryItemData()
        
        self.inst:RemoveTag("fire")
        self.burning = false
        self:KillFX()
        if self.inst.components.fueled then
            self.inst.components.fueled:StopConsuming()
        end
        if self.onextinguish then
            self.onextinguish(self.inst)
        end
        self.inst:PushEvent("onextinguish")
    end
end


function Burnable:SpawnFX(immediate)
    self:KillFX()
    
    if not self.fxdata then
        self.fxdata = { x = 0, y = 0, z = 0, level=self:GetDefaultFXLevel() }
    end
    
    if self.fxdata then
	    for k,v in pairs(self.fxdata) do
			local fx = SpawnPrefab(v.prefab)
			if fx then
                fx.Transform:SetScale(self.inst.Transform:GetScale())
				if v.follow then
					local follower = fx.entity:AddFollower()
					follower:FollowSymbol( self.inst.GUID, v.follow, v.x,v.y,v.z)
				else
				    self.inst:AddChild(fx)
				    fx.Transform:SetPosition(v.x, v.y, v.z)
				end
				table.insert(self.fxchildren, fx)
				if fx.components.firefx then
					fx.components.firefx:SetLevel(self.fxlevel, immediate)
				end
				
			end
		end
    end
end

function Burnable:KillFX()
	for k,v in pairs(self.fxchildren) do
		if v.components.firefx and v.components.firefx:Extinguish() then
            v:ListenForEvent("animover", function(inst) inst:Remove() end)  --remove once the pst animation has finished
        else
            v:Remove()
		end
		self.fxchildren[k] = nil
	end
end

function Burnable:OnRemoveFromEntity()
    self:StopSmoldering()
    self:Extinguish()
    self.inst:RemoveTag("wildfirestarter")
    self.inst:RemoveTag("burnable")
    if self.dragonflypriority then
        self.inst:RemoveTag(self.dragonprioritytag[self.dragonflypriority])
    end
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function Burnable:CollectSceneActions(doer, actions)
    if doer.components.health and self:IsSmoldering() then    
        table.insert(actions, ACTIONS.SMOTHER)        
    end
end

return Burnable