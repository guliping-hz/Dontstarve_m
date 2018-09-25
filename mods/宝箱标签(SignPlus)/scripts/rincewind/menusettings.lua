require "util"
require "rincewind/craputil"
require "strings"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Menu = require "widgets/menu"
local Grid = require "widgets/grid"
local Text = require "widgets/text"
local Spinner = require "widgets/spinner"
local Widget = require "widgets/widget"
local TextEdit = require "widgets/textedit"

local textfont = UIFONT
local spinnerFont = { font = BUTTONFONT, size = 28 }
local enableDisableOptions = { { text = STRINGS.UI.OPTIONS.DISABLED, data = false }, { text = STRINGS.UI.OPTIONS.ENABLED, data = true } }

--------------------------------------------------------------------------------------------------------------------------------------------------

local MenuSettings = Class(Screen, function(self,i,globaldata,enableresetbuttons)
	Screen._ctor(self, "MenuSettings")

	self.active = true
	SetPause(true,"pause")

	self.i = i
	self.g = globaldata

	self.root = self:AddChild(Widget("ROOT"))
	self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root:SetHAnchor(ANCHOR_RIGHT)
	self.root:SetPosition(-300,0,0)
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
	local shield = self.root:AddChild( Image( "images/globalpanels.xml", "panel.tex" ) )
	shield:SetPosition( 0,0,0 )
	shield:SetSize( 400, 350 )		

	self.grid = self.root:AddChild(Grid())
	self.grid:InitSize(1, 10, 400, -70)
	self.grid:SetPosition(-40, 80, 0)
	self.grid:SetScale(0.9, 0.6, 0.9)

	self.xSpinner = Spinner(self:GetScaleList())
	self.xSpinner.OnChanged = function( _, data ) self:ChangeX(data) end

	self.ySpinner = Spinner(self:GetScaleList())
	self.ySpinner.OnChanged = function( _, data ) self:ChangeY(data) end

	local spinners = {}
	table.insert(spinners, {"X Scale", self.xSpinner})
	table.insert(spinners, {"Y Scale", self.ySpinner})

	for k,v in ipairs(spinners) do self.grid:AddItem(self:CreateSpinnerGroup(v[1], v[2]), 1, k) end

	self:InitializeSpinners()

	if enableresetbuttons then
		self.menu = self.root:AddChild(Menu(nil, 200, true))
		self.menu:SetPosition(-30, -50 ,0)
		self.menu:SetScale(0.6)
		self.menu:SetTextSize(30)
		self.menu:AddItem("Reset buttons", function() self:ResetButtons(false) end)
		self.menu:AddItem("Uncheck buttons", function() self:ResetButtons(true) end)
	end

	self.menu2 = self.root:AddChild(Menu(nil, 200, true))
	self.menu2:SetPosition(-30, -100 ,0)
	self.menu2:SetScale(0.6)
	self.menu2:AddItem("Reset position", function() self:ResetPosition() end)
	self.menu2:AddItem("Close", function() self:Close() end)

	self.default_focus = self.signtext
end)

function MenuSettings:GetScaleList()
	local scale = {}
	for i = 0.4,1,0.05 do
		table.insert(scale, {text = tostring(i),data = i })
	end
	return scale
end

function MenuSettings:CreateSpinnerGroup( text, spinner )
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

function MenuSettings:ChangeX(data)
	if self.i and self.g then
		self.g.sx = data
		self.i:ScaleAll()
	end
end

function MenuSettings:ChangeY(data)
	if self.i and self.g then
		self.g.sy = data
		self.i:ScaleAll()
	end
end

function MenuSettings:ResetPosition()
	if self.i then
		self.i:ResetAll()
	end
	self:Close()
end

function MenuSettings:ResetButtons(data)
	if self.i then
		self.i:ResetButtons(data)
	end
end

local function EnabledOptionsIndex( enabled )
	if enabled then	return 2 else return 1 end
end

function MenuSettings:Close()
	self.active = false
	SetPause(false)
	TheFrontEnd:PopScreen()
end	


function MenuSettings:OnControl(control, down)
	if MenuSettings._base.OnControl(self,control, down) then return true end

	if (control == CONTROL_PAUSE or control == CONTROL_CANCEL) and not down then	
		self:Close()
		return true
	end

end

function MenuSettings:OnUpdate(dt)
	if self.active then
		SetPause(true)
	end
end

function MenuSettings:InitializeSpinners()
	if not (self.i and self.g)  then return end

	local scale = self:GetScaleList()
	for i = 1,#scale do
		if math.abs(scale[i].data - self.g.sx) < 0.009 then 
			self.xSpinner:SetSelectedIndex(i)
			break
		end
	end

	for i = 1,#scale do
		if math.abs(scale[i].data - self.g.sy) < 0.009 then 
			self.ySpinner:SetSelectedIndex(i)
			break
		end
	end
end

return MenuSettings