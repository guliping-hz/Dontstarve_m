local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
--arrow_loop_increase_most
--arrow_loop_increase_more
--arrow_loop_increase



local HealthArrow = Class(Widget, function(self, owner)
	Widget._ctor(self, "HealthArrow", owner)
	self.sanityarrow = self:AddChild(UIAnim())
	self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
	self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
	self.sanityarrow:GetAnimState():PlayAnimation("neutral")
	self.sanityarrow:SetClickable(false)
	self:StartUpdating()
	--Get the owner regeneration component
	self.owner = GetPlayer()
	self.previousHealth = 0
	self.currentHealth = 0
	--Keep record of number of changes
	self.noChange = 0
	--For animation change.
	self.anim = "neutral"

end)

function HealthArrow:OnUpdate(dt)
	self.currentHealth = self.owner.components.health.currenthealth
	--Nil check needed.
	--Change needs to be detected.
	if(self.currentHealth ~= self.previousHealth) then
		--Now get the rate to decide how big the arrow should be.
		local rate = (self.currentHealth - self.previousHealth)
		--Only do if health is not at full. The negative 0.01 prevent flickering.
		if rate > 0 and self.owner.components.health.currenthealth < self.owner.components.health.maxhealth - 0.01 then
			if rate > .06 then
				self.anim = "arrow_loop_increase_most"
			elseif rate > .025 then
				self.anim = "arrow_loop_increase_more"
			else
				self.anim = "arrow_loop_increase"
			end
		end
		self.noChange = 0
	else
		self.noChange = self.noChange + 1
	end
	--This previous value will be used for the next update.
	self.previousHealth = self.currentHealth
	
	--Only change when no change count reaches 4 or more.
	if(self.noChange > 3) then
		self.anim = "neutral"
	end
	
	--The purpose of this is to switch the animation state.
	if self.arrowdir ~= self.anim then
		self.arrowdir = self.anim
		self.sanityarrow:GetAnimState():PlayAnimation(self.anim, true)
	end
end

return HealthArrow