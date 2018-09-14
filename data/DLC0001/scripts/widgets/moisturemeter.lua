local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local MoistureMeter = Class(Widget, function(self, owner)
	Widget._ctor(self, "MoistureMeter")
	self.owner = owner

    self:SetPosition(0,0,0)

    self.active = false

    self.numDrops = 0
    self.drops = {}

    self.moisture = 0
    self.active = false

    self.anim = self:AddChild(UIAnim())
	self.anim:GetAnimState():SetBank("wet")
	self.anim:GetAnimState():SetBuild("wet_meter_player")
	self.anim:SetClickable(true )


	self.arrow = self.anim:AddChild(UIAnim())
	self.arrow:GetAnimState():SetBank("sanity_arrow")
	self.arrow:GetAnimState():SetBuild("sanity_arrow")
	self.arrow:GetAnimState():PlayAnimation("neutral")
	self.arrow:SetClickable(false)

    self.underNumber = self:AddChild(Widget("undernumber"))

    self.num = self:AddChild(Text(BODYTEXTFONT, 33))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(5, 0, 0)
	self.num:SetClickable(false)
    
    self.num:Hide()

	self:StartUpdating()
end)

function MoistureMeter:UpdateMeter()
	self.anim:GetAnimState():SetPercent("anim", self.moisture/100)
end

function MoistureMeter:Activate()
	self.anim:GetAnimState():PlayAnimation("open")
	self.animTask = self.owner:DoPeriodicTask(.5, function() self:UpdateMeter() end)
	self.owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/HUD_wet_open")
end

function MoistureMeter:Deactivate()
	if self.animTask then
		self.animTask:Cancel()
		self.animTask = nil
	end
	self.anim:GetAnimState():PlayAnimation("close")
	self.owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/HUD_wet_close")
	
end

function MoistureMeter:OnGainFocus()
	MoistureMeter._base:OnGainFocus(self)
	self.num:Show()
end

function MoistureMeter:OnLoseFocus()
	MoistureMeter._base:OnLoseFocus(self)
	self.num:Hide()
end

function MoistureMeter:UpdateArrowAnim()
	local rate = self.owner.components.moisture:GetDelta()
	local small_down = .001
	local med_down = 1.5
	local large_down = 3
	local small_up = .001
	local med_up = .15
	local large_up = .3
	local anim = "neutral"
	if rate > 0 and self.owner.components.moisture:GetMoisture() < 100 then
		if rate > large_up then
			anim = "arrow_loop_increase_most"
		elseif rate > med_up then
			anim = "arrow_loop_increase_more"
		elseif rate > small_up then
			anim = "arrow_loop_increase"
		end
	elseif rate < 0 and self.owner.components.moisture:GetMoisture() > 0 then
		if rate < -large_down then
			anim = "arrow_loop_decrease_most"
		elseif rate < -med_down then
			anim = "arrow_loop_decrease_more"
		elseif rate < -small_down then
			anim = "arrow_loop_decrease"
		end
	end
	
	if anim and self.arrowdir ~= anim then
		self.arrowdir = anim
		self.arrow:GetAnimState():PlayAnimation(anim, true)
	end
end

function MoistureMeter:OnUpdate(dt)
	local newMoisture = self.owner.components.moisture:GetMoisture()
	local oldMoisture = self.moisture
	self.moisture = newMoisture
	if newMoisture ~= oldMoisture then
		if newMoisture > 0 and oldMoisture <= 0 then
			self:Activate()
			if newMoisture > 10 then
				self.anim:GetAnimState():SetPercent("anim", self.moisture/100)
			end
		elseif newMoisture <= 0 then
			self:Deactivate()
		end
	end

	self.num:SetString(tostring(math.ceil(self.owner.components.moisture:GetMoisture())))

	self:UpdateArrowAnim()
end

-- function MoistureMeter:OnUpdate(dt)
-- 	local newDrops, percent = self.owner.components.moisture:GetSegs()
-- 	local newDrops = math.ceil(newDrops + percent)
-- 	local oldDrops = self.numDrops
-- 	if newDrops ~= oldDrops then
-- 		if newDrops > 0 and oldDrops == 0 then
-- 			self:Activate()
-- 		elseif newDrops == 0 then
-- 			self:Deactivate()
-- 		end
-- 		self.numDrops = newDrops
-- 		self:UpdateDrops()
-- 	end

-- 	self.num:SetString(tostring(math.ceil(self.owner.components.moisture:GetMoisture())))

-- 	if #self.drops > 0 then
-- 		self.drops[#self.drops]:SetScale(percent, percent, percent) 
-- 	end

-- 	self:UpdateArrowAnim()

-- end

-- function MoistureMeter:UpdateDrops()
-- 	if not self.anim then
-- 		return 
-- 	end

-- 	for k,v in pairs(self.drops) do
-- 		self.anim:RemoveChild(v)
-- 	end
-- 	self.drops = {}

-- 	local xOffset = -37

-- 	for i = 1, self.numDrops do
-- 		local drop = self.anim:AddChild(UIAnim())
-- 		drop:SetClickable(false)
-- 		drop:GetAnimState():SetBank("wet_meter_drop")
-- 		drop:GetAnimState():SetBuild("wet_meter_drop")
-- 		drop:GetAnimState():PlayAnimation("1")
-- 		drop:SetPosition(xOffset, 1, 0)
-- 		xOffset = xOffset + 18.5
-- 		table.insert(self.drops, drop)
-- 	end
-- end

return MoistureMeter