require "util"
require "rincewind/craputil"
require "strings"
local Screen = require "widgets/screen"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Spinner = require "widgets/spinner"
local Widget = require "widgets/widget"
local TextEdit = require "widgets/textedit"

local textfont = UIFONT
local spinnerFont = { font = BUTTONFONT, size = 28 }
local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }
local VALID_CHARS = [[ abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,:;[]\@!#$%&()'*+-/=?^_{|}~"]]

--------------------------------------------------------------------------------------------------------------------------------------------------

local SignScreen = Class(Screen, function(self,p)
	Screen._ctor(self, "SignScreen")

	self.active = true
	SetPause(true,"pause")

	self.data = nil
	if p and p.components and p.components.signdata and p.components.signdata.data and (type(p.components.signdata.data)=="table") then
		self.data = p.components.signdata.data
		self.signdata = p.components.signdata
	end
	self.root = self:AddChild(Widget("ROOT"))
	self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root:SetHAnchor(ANCHOR_LEFT)
	self.root:SetPosition(400,0,0)
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
	local shield = self.root:AddChild( Image( "images/globalpanels.xml", "panel.tex" ) )
	shield:SetPosition( 0,0,0 )
	shield:SetSize( 500, 550 )		

	local label_width = 200
	local label_height = 50
	local label_offset = 100
	local space_between = 30
	local signtext_offset = 120
	local fontsize = 30
	local edit_width = 350
	local edit_bg_padding = 60

    	self.signtext_bg = self.root:AddChild( Image() )
	self.signtext_bg:SetTexture( "images/ui.xml", "textbox_long.tex" )
	self.signtext_bg:SetPosition( 0, signtext_offset, 0 )
	self.signtext_bg:ScaleToSize( edit_width + edit_bg_padding, label_height )

	self.signtext = self.root:AddChild( TextEdit( BODYTEXTFONT, fontsize, self.data.str or "") )
	self.signtext:SetPosition( 0, signtext_offset, 0 )
	self.signtext:SetRegionSize( edit_width, label_height )
	self.signtext:SetHAlign(ANCHOR_LEFT)
	self.signtext:SetFocusedImage( self.signtext_bg, UI_ATLAS, "textbox_long_over.tex", "textbox_long.tex" )
	self.signtext:SetTextLengthLimit(60)
	self.signtext:SetCharacterFilter(VALID_CHARS)

--	self.signtext:SetEditing(true)

	self.grid = self.root:AddChild(Grid())
	self.grid:InitSize(1, 10, 400, -70)
	self.grid:SetPosition(0, 50, 0)
	self.grid:SetScale(0.9, 0.6, 0.9)

	self.labelSpinner = Spinner(enableDisableOptions)
	self.labelSpinner.OnChanged = function( _, data ) self:ChangeLabel(data) end

	self.posSpinner = Spinner(self:GetPosList())
	self.posSpinner.OnChanged = function( _, data ) self:ChangePos(data) end

	self.colorSpinner = Spinner(self:GetColorList())
	self.colorSpinner.OnChanged = function( _, data ) self:ChangeColor(data) end

	self.fontSpinner = Spinner(self:GetFontList())
	self.fontSpinner.OnChanged = function( _, data ) self:ChangeFont(data) end

	self.fontsizeSpinner = Spinner(self:GetFSList())
	self.fontsizeSpinner.OnChanged = function( _, data ) self:ChangeFS(data) end

	self.mouseSpinner = Spinner(enableDisableOptions)
	self.mouseSpinner.OnChanged = function( _, data ) self:ChangeMouse(data) end

	local spinners = {}
	table.insert(spinners, {"Label", self.labelSpinner})
	table.insert(spinners, {"Position", self.posSpinner})
	table.insert(spinners, {"Color", self.colorSpinner})
	table.insert(spinners, {"Font", self.fontSpinner})
	table.insert(spinners, {"Font size", self.fontsizeSpinner})
	table.insert(spinners, {"Left mouse button", self.mouseSpinner})

	for k,v in ipairs(spinners) do self.grid:AddItem(self:CreateSpinnerGroup(v[1], v[2]), 1, k) end

	self:InitializeSpinners()

	self.menu = self.root:AddChild(Menu(nil, 200, true))
	self.menu:SetPosition(0, -210 ,0)
	self.menu:SetScale(0.6)
	self.menu:AddItem(STRINGS.UI.OPTIONS.CLOSE, function() self:Close(true) end)

	self.default_focus = self.signtext
end)

function SignScreen:GetPosList()
	if not self.poslist then self.poslist = {} else return self.poslist end
	for i = 0,3.4,0.2 do
		table.insert(self.poslist, {text = tostring(i),data = i })
	end
	return self.poslist
end

function SignScreen:GetColorList()
	if not self.colorlist then self.colorlist = {} else return self.colorlist end
	table.insert(self.colorlist, {text = "White", data = "FFFFFF"})
	table.insert(self.colorlist, {text = "Green", data = "06B000"})
	table.insert(self.colorlist, {text = "Red", data = "B00006"})
	table.insert(self.colorlist, {text = "Yellow", data = "B0AA00"})
	table.insert(self.colorlist, {text = "Pink", data = "AA00B0"})
	table.insert(self.colorlist, {text = "Blue", data = "005EB0"})
	return self.colorlist
end

function SignScreen:GetFontList()
	if not self.fontlist then self.fontlist = {} else return self.fontlist end
	table.insert(self.fontlist, {text = "Default", data = BODYTEXTFONT})
	table.insert(self.fontlist, {text = "Dialog", data = DIALOGFONT})
	table.insert(self.fontlist, {text = "UI", data = UIFONT})
	table.insert(self.fontlist, {text = "Button", data = BUTTONFONT})
	table.insert(self.fontlist, {text = "Talking", data = TALKINGFONT})
	return self.fontlist
end

function SignScreen:GetFSList()
	if not self.fslist then self.fslist = {} else return self.fslist end
	for i = 8,26,2 do
		table.insert(self.fslist, {text = tostring(i), data = i})
	end
	return self.fslist
end

function SignScreen:CreateSpinnerGroup( text, spinner )
	local label_width = 200
	spinner:SetTextColour(0,0,0,1)
	local group = Widget("SpinnerGroup")
	local label = group:AddChild( Text( textfont, 30, text ) )
	label:SetPosition( -label_width/2, 0, 0 )
	label:SetRegionSize( label_width, 50 )
	label:SetHAlign( ANCHOR_RIGHT )
	group:AddChild( spinner )
	spinner:SetPosition( 125, 0, 0 )
	group.focus_forward = spinner
	return group
end

function SignScreen:ChangePos(data)
	if self.data then 
		self.data.str = self.signtext:GetLineEditString()
		self.data.pos = data 
		self.signdata:UpdateLabel()
	end
end

function SignScreen:ChangeColor(data)
	if self.data then 
		self.data.str = self.signtext:GetLineEditString()
		self.signdata:SetColor(data)
		self.signdata:UpdateLabel()
	end
end

function SignScreen:ChangeFont(data)
	if self.data then 
		self.data.str = self.signtext:GetLineEditString()
		self.data.font = data 
		self.signdata:UpdateLabel()
	end
end

function SignScreen:ChangeLabel(data)
	if self.data then 
		self.data.str = self.signtext:GetLineEditString()
		self.data.showme = data 
		self.signdata:UpdateLabel()
	end
end

function SignScreen:ChangeMouse(data)
	if self.data then 
		self.data.str = self.signtext:GetLineEditString()
		if data then self.signdata:EnableRead() else self.signdata:DisableRead() end
	end
end

function SignScreen:ChangeFS(data)
	if self.data then 
		self.data.str = self.signtext:GetLineEditString()
		self.data.fontsize = data
		self.signdata:UpdateLabel()
	end
end

local function EnabledOptionsIndex( enabled )
	if enabled then	return 2 else return 1 end
end

function SignScreen:Close(f)
	if f and self.data then
		self.data.str = self.signtext:GetLineEditString()
		self.signdata:UpdateLabel()
	end
	self.active = false
	SetPause(false)
	if self.signdata then self.signdata.oncd = false end
	TheFrontEnd:PopScreen()
end	


function SignScreen:OnControl(control, down)
	if SignScreen._base.OnControl(self,control, down) then return true end

	if (control == CONTROL_PAUSE or control == CONTROL_CANCEL) and not down then	
		self:Close()
		return true
	end

end

function SignScreen:OnUpdate(dt)
	if self.active then
		SetPause(true)
	end
end

function SignScreen:InitializeSpinners()
	if not self.data then return end

	self.mouseSpinner:SetSelectedIndex(EnabledOptionsIndex(self.signdata:IsRead()))
	self.labelSpinner:SetSelectedIndex(EnabledOptionsIndex(self.data.showme))
	if self.signdata.nolmb then self.mouseSpinner:Disable() end

	local pos = self:GetPosList()
	for i = 1,#pos do
		if math.abs(pos[i].data - self.data.pos) < 0.05 then 
			self.posSpinner:SetSelectedIndex(i)
			break
		end
	end

	local col = self:GetColorList()
	local c = self.signdata:GetColor()
	for i = 1,#col do
		if col[i].data == c then 
			self.colorSpinner:SetSelectedIndex(i)
			break
		end
	end

	local font = self:GetFontList()
	for i = 1,#font do
		if font[i].data == self.data.font then 
			self.fontSpinner:SetSelectedIndex(i)
			break
		end
	end

	local fs = self:GetFSList()
	for i = 1,#fs do
		if math.abs(fs[i].data - self.data.fontsize) < 0.05 then 
			self.fontsizeSpinner:SetSelectedIndex(i)
			break
		end
	end
end

return SignScreen