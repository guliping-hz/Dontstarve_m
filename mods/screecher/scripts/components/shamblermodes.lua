
local ShamblerModes = Class(function(self, inst)
	self.inst = inst
	self.modes = {}

	inst:ListenForEvent("flashed", function(inst, data)
		if self.modes[self.mode].flashed then
			self.modes[self.mode].flashed(inst, data)
		end
	end)
	inst:ListenForEvent("unlit", function(inst, data)
		if self.modes[self.mode].unlit then
			self.modes[self.mode].unlit(inst, data)
		end
	end)
	inst:ListenForEvent("lit", function(inst, data)
		if self.modes[self.mode].lit then
			self.modes[self.mode].lit(inst, data)
		end
	end)
	inst:ListenForEvent("newlyagitated", function(inst, data)
		if self.modes[self.mode].newlyagitated then
			self.modes[self.mode].newlyagitated(inst, data)
		end
	end)
	inst:ListenForEvent("agitated", function(inst, data)
		if self.modes[self.mode].agitated then
			self.modes[self.mode].agitated(inst, data)
		end
	end)
	inst:ListenForEvent("calm", function(inst, data)
		if self.modes[self.mode].calmed then
			self.modes[self.mode].calmed(inst, data)
		end
	end)
	
	-- Flicker is weirder than the rest coz it happens on another entity
	local flashlightent = GetPlayer().FlashlightEnt()
	inst:ListenForEvent("flicker", function(flaslight, data)
		if self.modes[self.mode].flicker then
			self.modes[self.mode].flicker(self.inst, data)
		end
	end, flashlightent)

	self.mode = "none"

	self.inst:StartUpdatingComponent(self)
end)

function ShamblerModes:SetModeData(modes)
	self.modes = modes
end

function ShamblerModes:SetKind(kind)
	local k = {
		observer=self.Set_Observer,
		teaser=self.Set_Teaser,
		killer=self.Set_Killer,
	}
	k[kind](self)
end

function ShamblerModes:Set_Observer()

	print("setting observer mode")

	self.inst.sg:GoToState("idle_eating")
	self.inst.components.agitation:SetThreshold(TUNING.SHAMBLER_OBSERVER_AGGRO)
	self.inst.components.playerprox:SetDist(TUNING.SHAMBLER_OBSERVER_POOF_RANGE, TUNING.SHAMBLER_OBSERVER_POOF_RANGE+0.5)

	self.mode = "observer"
end

function ShamblerModes:Set_Teaser()

	print("setting teaser mode")
	
	self.inst.sg:GoToState("idle")

	self.inst.components.agitation:SetThreshold(TUNING.SHAMBLER_TEASER_AGGRO)
	self.inst.components.locomotor.runspeed = TUNING.SHAMBLER_RUN_SPEED

	--self.inst.AnimState:SetLightOverride(1)
	--self.inst.AnimState:SetMultColour(1,1,1,0.3)
	
	self.mode = "teaser"
end

function ShamblerModes:Set_Killer()

	print("setting killer mode")

	self.inst.sg:GoToState("idle_killer")

	self.inst.components.agitation:SetThreshold(TUNING.SHAMBLER_KILLER_AGGRO)
	self.inst.components.playerprox:SetDist(TUNING.SHAMBLER_KILL_RANGE, TUNING.SHAMBLER_KILL_RANGE+0.5)
	
	self.mode = "killer"
end

function ShamblerModes:OnNear()
	if self.modes[self.mode].onnear then
		self.modes[self.mode].onnear(self.inst)
	end
end

function ShamblerModes:GetDebugString()
	return string.format("Mode: %s", self.mode)
end

function ShamblerModes:OnUpdate(dt)
	if self.modes[self.mode].onupdate then
		self.modes[self.mode].onupdate(self.inst, dt)
	end
end

return ShamblerModes
