local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
--arrow_loop_increase_most
--arrow_loop_increase_more
--arrow_loop_increase



local SanityArrow = Class(Widget, function(self, owner)
	Widget._ctor(self, "HealthArrow", owner)
	self.sanityarrow = self:AddChild(UIAnim())
	self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
	self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
	self.sanityarrow:GetAnimState():PlayAnimation("neutral")
	self.sanityarrow:SetClickable(false)
	self:StartUpdating()
	--Get the owner regeneration component
	self.owner = GetPlayer()
	self.currentSanity = 0
	self.previousSanity = 0
	--Keep record of changes
	self.noChange = 0
	--For animation change.
	self.anim = "neutral"

end)

function SanityArrow:OnUpdate(dt)
	self.currentSanity = self.owner.components.sanity.current
	--Change needs to be detected.
	if(self.currentSanity ~= self.previousSanity) then
		--Now get the rate to decide how big the arrow should be.
		local rate = (self.currentSanity - self.previousSanity)
		--Only do if health is not at full
		if rate > 0 and self.owner.components.sanity.current < self.owner.components.sanity.max - 0.01 then
			if rate > .054 then
				self.anim = "arrow_loop_increase_most"
			elseif rate > .0016 then
				self.anim = "arrow_loop_increase_more"
			else
				self.anim = "arrow_loop_increase"
			end
		elseif rate < 0 then
			if rate < -0.054 then
				self.anim = "arrow_loop_decrease_most"
			elseif rate < -.0016 then
				self.anim = "arrow_loop_decrease_more"
			else
				self.anim = "arrow_loop_decrease"
			end
		end
		self.noChange = 0
	else
		self.noChange = self.noChange + 1
	end
	--This previous value will be used for the next update.
	self.previousSanity = self.currentSanity
	
	--Only change when no change count reaches 3 or more.
	if(self.noChange > 4) then
		self.anim = "neutral"
	end
	
	--The purpose of this is to switch the animation state.
	if self.arrowdir ~= self.anim then
		self.arrowdir = self.anim
		self.sanityarrow:GetAnimState():PlayAnimation(self.anim, true)
	end
end

return SanityArrow