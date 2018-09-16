local Widget = require "widgets/widget"
local Image = require "widgets/image"

local BloodOver =  Class(Widget, function(self, owner)

	self.owner = owner
	Widget._ctor(self, "BloodOver")
	
	self:SetClickable(false)

    self.bg = self:AddChild(Image("images/fx.xml", "blood_over.tex"))
    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

    
    self:Hide()
    self.base_level = 0
    self.level = 0
    self.delta = 0
    self.dead = false
    self.enabled = true
    self.indarkness = false

    self:StartUpdating()
end)


function BloodOver:TurnOn()
    if not self.indarkness then
        TheFrontEnd:GetSound():PlaySound("scary_mod/music/anticipate_15sec", "darkness_sound")
        self.indarkness = true
        self.level = 0
        GetPlayer().indarkness = true
    end
end

function BloodOver:TurnOff()
    if self.indarkness then
        TheFrontEnd:GetSound():KillSound("darkness_sound")
        self.indarkness = false
        GetPlayer().indarkness = false
        if self.level > TUNING.DARKNESS_STALKTIME then
            GetPlayer():PushEvent("change_breathing", {intensity=3, duration=3})
        end
    end
end

function BloodOver:OnUpdate(dt)
    
    if not self.dead and self.indarkness and self.enabled then
        self.level = self.level + dt
        print("self.level: "..tostring(self.level).." dt: "..tostring(dt))

        if self.level > 0 then
            --self:Show()
            --self.bg:SetTint(1,1,1,self.level)
            --self.owner:PushEvent("darknessmuschange", {darknesslvl = self.level})
            if self.level >= TUNING.DARKNESS_STALKTIME and 
                (self.level - dt) < TUNING.DARKNESS_STALKTIME then
                GetPlayer().SoundEmitter:PlaySound("scary_mod/stuff/screetch_moan")
            end

            if self.level >= TUNING.DARKNESS_STALKTIME2 and 
                (self.level - dt) < TUNING.DARKNESS_STALKTIME2 then
                GetPlayer().components.talker:Say("There's something out there!")
            end

            --This death detection shouldn't really be here, but it's the easiest way to tie it to the FX level
            if self.level >= TUNING.BLOOD_OVERLAY_VALUE_FOR_DEATH and not GetPlayer().sg:HasStateTag("doinglong") then
                self.level = 0
                self.delta = 0
                self.dead = true
                self.owner:PushEvent("darknessdeath")
                TheFrontEnd:GetSound():KillSound("darkness_sound")
                TheFrontEnd:GetSound():PlaySound("scary_mod/music/hit")
                --TheFrontEnd:GetSound():PlaySound("scary_mod/music/hit")
                --self:Hide()
            end
        else
            self:Hide()
        end
    end
end

function BloodOver:Flash()
    self:StartUpdating()    
    self.level = 1
    self.k = 1.33
end

function BloodOver:KillOverlay()
    self.level = 0
    self.delta = 0
    self.bg:SetTint(1,1,1,0)
    self.enabled = false
    self:Hide()
end

return BloodOver