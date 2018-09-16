local Screen = require "widgets/screen"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Progression = require "progressionconstants"
local Text = require "widgets/text"
local TextButton = require "widgets/textbutton"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local Menu = require "widgets/menu"

local DeathScreen = Class(Screen, function(self, days_survived, start_xp, escaped)

    Widget._ctor(self, "Progress")
    self.owner = GetPlayer()
	self.log = true

    TheInputProxy:SetCursorVisible(true)

	self.root = self:AddChild(Widget("ROOT"))
    self.root:SetVAnchor(ANCHOR_MIDDLE)
    self.root:SetHAnchor(ANCHOR_MIDDLE)
    self.root:SetPosition(0,0,0)
    self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.bg = self.root:AddChild(Image("images/hud/youdied.xml", "youdied.tex"))
	self.bg:SetPosition(0,50,0)

    local font = BODYTEXTFONT

    local menu_items = 
    {
        {text = STRINGS.UI.DEATHSCREEN.MAINMENU, cb = function() self:OnMenu() end}
    }

    table.insert(menu_items,  {text = STRINGS.UI.DEATHSCREEN.RETRY, cb = function() self:OnRetry() end})

    Menu.AddItem = function(self, text, cb, offset)
        local pos = Vector3(0,0,0)
        pos.y = pos.y + self.offset * #self.items
        
        if offset then
            pos = pos + offset  
        end
        
        local button = self:AddChild(TextButton())
        button:SetPosition(pos)
        button:SetText(text)

        button:SetTextColour(0.9,0.8,0.6,1)
        button:SetOnClick( cb )
        button:SetFont(BUTTONFONT)
        button:SetTextSize(40)    

        table.insert(self.items, button)

        self:DoFocusHookups()
        return button
    end

    self.menu = self.root:AddChild(Menu(menu_items, 50))
    self.menu:SetPosition(0, -300, 0)

    TheFrontEnd:Fade(true, 2)
    --self:ShowButtons(false)
    self:ShowButtons(true)
    

    -- self.rewardtext = self.root:AddChild(Text(font, 40))
    -- self.rewardtext:SetString(STRINGS.UI.DEATHSCREEN.NEXTREWARD)
    -- self.rewardtext:SetHAlign(ANCHOR_LEFT)
    -- self.rewardtext:SetPosition(60,-110,0)

    
    -- self:ShowResults(days_survived, start_xp)
    self.default_focus = self.menu
end)

local function DoReload()
    StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()})
end

function DeathScreen:OnRetry()

    -- Record the start of a new game
    local starts = Profile:GetValue("starts") or 0
    Profile:SetValue("starts", starts+1)
    Profile:Save()

    self.menu:Disable()
    TheFrontEnd:Fade(false, 2, DoReload)
end

function DeathScreen:OnContinue()
    self.menu:Disable()
    TheFrontEnd:Fade(false, 2, DoReload)
end

function DeathScreen:OnMenu(escaped)
	
    self.menu:Disable()
    TheFrontEnd:Fade(false, 2, function()
        if escaped then
            StartNextInstance()
        else
            SaveGameIndex:DeleteSlot(SaveGameIndex:GetCurrentSaveSlot(), function() 
                StartNextInstance()
            end)
        end
    end)
end

function DeathScreen:ShowButtons(show)
    if show then
        self.menu:Show()
        --self.menu:SetFocus()
    else
		--self.menu:Hide()
    end
end


function DeathScreen:SetStatus(xp, ignore_image)
    local level, percent = Progression.GetLevelForXP(xp)

    if not ignore_image then
        self.portrait:SetTint(0,0,0,1)
        local reward = Progression.GetRewardForLevel(level)
        if reward then
            self.portrait:Show()

			--print("images/saveslot_portraits/"..reward..".tex")
            self.portrait:SetTexture("images/saveslot_portraits.xml", reward..".tex")
        else
            self.portrait:Hide()
        end
    end
    
    
    self.leveltext:SetString(STRINGS.UI.DEATHSCREEN.LEVEL.." "..tostring(level+1))
    -- self.progbar:GetAnimState():SetPercent("anim", percent)
    
	self.xptext:SetString(string.format("XP: %d", xp))
    
    if xp >= Progression.GetXPCap() then
		self.rewardtext:SetString(STRINGS.UI.DEATHSCREEN.ATCAP)
	end
	
end

function DeathScreen:ShowResults(days_survived, start_xp)
    
    self:Show()
    local xpreward = Progression.GetXPForDays(days_survived)
    local xpcap = Progression.GetXPCap()
    if start_xp + xpreward > xpcap then
		xpreward = xpcap - start_xp
    end
    
    
    if self.thread then
        KillThread(self.thread)
    end
        self:SetStatus(start_xp)
        
        self.thread = self.inst:StartThread( function() 
        self:ShowButtons(false)
        local end_xp = start_xp + xpreward
	
        local start_level, start_percent = Progression.GetLevelForXP(start_xp)
        local end_level, end_percent = Progression.GetLevelForXP(end_xp)
        
        local fills = end_level - start_level + 1
        local dt = GetTickTime()
        
        local xplevel = start_level 
        local short = fills > 1
        local total_fill_time = short and 2 or 5
        
        local fill_rate = 1/total_fill_time
        --print (start_level, start_percent, "TO", end_level, end_percent, "->", fills)
        
        for k = 1, fills do
            
            local xp_for_level, level_xp_size = Progression.GetXPForLevel(xplevel)
            if xp_for_level then
                local end_p = k == fills and end_percent or 1
                local p = k == 1 and start_percent or 0
                if end_p > p then
                    
                    --print (k, xplevel, xp_for_level, level_xp_size, p, end_p, total_fill_time)
                    
                    if short then
                        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/XP_bar_fill_fast", "fillsound")
                    else
                        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/XP_bar_fill_slow", "fillsound")
                    end
                    
                    repeat
                        p = p + dt*fill_rate
                        local xp = xp_for_level + math.min(end_p,p)*level_xp_size
                        self:SetStatus(xp, p >= 1)
                        
                        self.progbar:GetAnimState():SetPercent("anim", p)
                        Yield()
                    until p >= end_p
                    self.owner.SoundEmitter:KillSound("fillsound")
                    if end_p >= 1 then
                        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/XP_bar_fill_unlock")
                        self.progbar:GetAnimState():SetPercent("anim", 1)
                        self.portrait:SetTint(1,1,1,1)
                        self.portrait:ScaleTo(2, 1.5, .25)
                        Sleep(1)
                    end
                end
            end
            xplevel = xplevel + 1
        end
        
        
        self:ShowButtons(true)
        self.thread = nil
    end )
    
    return xpreward
end

return DeathScreen
