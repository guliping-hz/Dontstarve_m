local Regeneration = Class(function(self, inst)
    self.inst = inst
	-- components
	self.health = self.inst.components.health
	self.hunger = self.inst.components.hunger
	self.sanity = self.inst.components.sanity
	-- update
	self.inst:StartUpdatingComponent(self)
	-- variable
	
	--These variable are flags for flat rate
	self.HealthFlatRate = false
	self.SanityFlatRate = false
	
	--These flag check if regeneration isn't wanted.
	self.isRegenHealth = true
	self.isRegenSanity = true
	--Initialise these variable to prevent issues with get methods.
	self.healthRegenRate = 0.0
	self.sanityRegenRate = 0.0
	
end)



--Return Health regeneration rate

function Regeneration:GetHealthRegenRate()
--At flat rate, the healthRegenRate is not calculated so return the base regen rate.
	if self.HealthFlatRate then
		return HEALTH_BASE_REGEN
	else
		-- This calculate the percentage rate that needs to be added to the minimum regeneration rate
		-- Since 100 % Hunger percent is not in the config file, there should be no division by 0.
		local hungerPercent = self.hunger:GetPercent()
		local healthPercentAdd = (1 - HEALTH_MIN_REGEN_PERCENT) * ((hungerPercent - HUNGER_PERCENT_NEEDED)/ (1 - HUNGER_PERCENT_NEEDED) )
		--Regeneration based on proportion.
		local healthRegenPercent = healthPercentAdd + HEALTH_MIN_REGEN_PERCENT
		self.healthRegenRate = healthRegenPercent * HEALTH_BASE_REGEN
		return self.healthRegenRate
	end
		--return HEALTH_BASE_REGEN
end

--Return Sanity regeneration rate
function Regeneration:GetSanityRegenRate()
	
	if self.SanityFlatRate then
		return SANITY_BASE_REGEN
	else
		local healthPercent = self.health:GetPercent()
		local sanityPercentAdd = (1 - SANITY_MIN_REGEN_PERCENT) * ((healthPercent - HEALTH_PERCENT_NEEDED) / (1 - HEALTH_PERCENT_NEEDED))
		local sanityRegenPercent = sanityPercentAdd + SANITY_MIN_REGEN_PERCENT
		self.sanityRegenRate = sanityRegenPercent * SANITY_BASE_REGEN
		return self.sanityRegenRate
	end
end


function Regeneration:OnUpdate(dt)
	--Health Regeneration.
	if(self.health.currenthealth > 0 and self.isRegenHealth) then
-- Added plus 1 to avoid issues.
		if (self.hunger.current > (self.hunger.max * HUNGER_PERCENT_NEEDED)) then
			--If Flat rate just regenerate at base regeneration level. More efficient due to less calculation involved.
			self.health:DoDelta(self:GetHealthRegenRate() * dt, true)
		end
	end
	
	--Sanity Regeneration
	
	--Similar to the above health regen, check if SanityFlatRate flag is true, if so regen at base sanity rate.
	
	if self.isRegenSanity then
		if(self.health.currenthealth > (self.health.maxhealth * HEALTH_PERCENT_NEEDED)) then
		--Similar to Health regeneration code.
			self.sanity:DoDelta(self:GetSanityRegenRate() * dt, true)
		end
	end
	
end


function Regeneration:SetHealthRegenData(percent, base, minimum)
	HUNGER_PERCENT_NEEDED = percent
	HEALTH_BASE_REGEN = base
	HEALTH_MIN_REGEN_PERCENT = minimum
--Check if HealthFlatRate flag should be true
	if( HEALTH_MIN_REGEN_PERCENT == 1) then
		self.HealthFlatRate = true
	else
		self.HealthFlatRate = false
	end
	
	--Check if regeneration is wanted
	if(HEALTH_BASE_REGEN == 0) then
		self.isRegenHealth = false
	else
		self.isRegenHealth = true
	end

	--Special case buff for WolfGang, reduce his hunger percentage need. cap sensitive name.

	
end

function Regeneration:SetSanityRegenData(percent, base, minimum)
	HEALTH_PERCENT_NEEDED = percent
	SANITY_BASE_REGEN = base
	SANITY_MIN_REGEN_PERCENT = minimum
--Check if Sanity Flat Rate should be true
	if( SANITY_MIN_REGEN_PERCENT == 1) then
		self.SanityFlatRate = true
	else
		self.SanityFlatRate = false
	end

--Check if Sanity regeneration is true

	if(SANITY_BASE_REGEN == 0) then
		self.isRegenSanity = false
	else
		self.isRegenSanity = true
	end
	
	
end


function Regeneration:Wolfgang()
	HUNGER_PERCENT_NEEDED = HUNGER_PERCENT_NEEDED * 0.66
	HEALTH_BASE_REGEN = HEALTH_BASE_REGEN * 1.33
end

--The percentage of hunger needed to Regenerate
HUNGER_PERCENT_NEEDED = 0.5
--How fast health regeneration on full hunger
HEALTH_BASE_REGEN = 0.30
--The minimum regeneration rate of health once the hunger requirement is met.
HEALTH_MIN_REGEN_PERCENT = 0.2

-- The percentage of Health needed for sanity regeneration.
HEALTH_PERCENT_NEEDED = 0.6
-- How fast sanity regenerate
SANITY_BASE_REGEN = 0.15
-- The minimum regeneration rate of sanity once health requirement is met
SANITY_MIN_REGEN_PERCENT = 0.2

return Regeneration