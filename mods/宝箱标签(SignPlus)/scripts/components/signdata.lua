require "util"
require "rincewind/craputil"

local SignScreen 	= require "screens/signscreen"

print ("SignPlus : SignData component")

local SignData = Class(function(self, inst)
	self.inst = inst
	self.oncd = false
	self.data = {}
	self.data.str = ""
	self.data.showme = false
	self.data.fontsize = 18
	self.data.pos = 2
	self.data.font = BODYTEXTFONT
	self.data.r = 255
	self.data.g = 255
	self.data.b = 255
	self.data.lmb = false
	self.done = false

	self.nolmb = false
	self.rmb = ACTIONS.SIGNEDIT
	self.lmb = nil
end)

function SignData:CollectSceneActions(doer, actions, right)
	if self.rmb and right and (not self.oncd) then table.insert(actions, self.rmb) end
	if self.lmb and (not right) and (not self.oncd) then table.insert(actions, self.lmb) end
end

function SignData:EnableRead()
	if self.nolmb then 
		self:DisableRead()
	else 
		self.lmb = ACTIONS.SIGNREAD
		self.data.lmb = true
	end
end

function SignData:DisableRead()
	self.lmb = nil
	self.data.lmb = false
end

function SignData:ToggleRead()
	if self.lmb then self:DisableRead() else self:EnableRead() end
end

function SignData:IsRead()
	return self.lmb~=nil
end

function SignData:OnLeftClick(target)
	self.data.showme = not self.data.showme
	self:UpdateLabel()
end

local function GetRGBColor(color,index)
	if (not color) or (type(color)~="string") then
		print ("GetRGBColor : bad color = "..tostring(color))
		return 0
	end
	if (not index) or (type(index)~="number") or (index < 1) then index = 1 end
	if index > 3 then index = 3 end
	local pos = index * 2 - 1
	return GLOBAL.tonumber(string.sub(color,pos,pos+1),16)/255
end

function SignData:GetColor()
	local function Hex(num)
		local s = string.format("%X",num)
		if string.len(s) == 1 then s = "0"..s end
		return s
	end
	return Hex(self.data.r)..Hex(self.data.g)..Hex(self.data.b)
end

function SignData:SetColor(c)
	local function rgbcol(str,pos)
		return tonumber(string.sub(str,pos,pos+1),16)
	end
	if not (c and (type(c)=="string") and string.len(c)==6) then 
		print ("SignData SetColor : color ("..tostring(c)..") is invalid")
		return 
	end
	self.data.r = rgbcol(c,1)
	self.data.g = rgbcol(c,3)
	self.data.b = rgbcol(c,5)
end

function SignData:UpdateLabel()
	if self.inst.Label then
		local l = self.inst.Label
		l:SetFontSize(self.data.fontsize)
		l:SetFont(self.data.font)
		l:SetPos(0, self.data.pos, 0)
		l:SetText(self.data.str)
		l:SetColour(self.data.r/255,self.data.g/255,self.data.b/255)
		l:Enable(self.data.showme)
	end
end

function SignData:OnRightClick(target)
	self.oncd = true
	TheFrontEnd:PushScreen(SignScreen(self.inst))
end

function SignData:OnSave()    
	return {d = self.data}
end

function SignData:Merge(d)
	if not (d and (type(d)=="table")) then 
		print ("SignData Merge : input data is not exists or not valid")
		return 
	end
	for k, v in pairs(d) do
		if type(d[k])=="table" then self.data[k] = deepcopy(d[k]) else self.data[k] = d[k] end
	end
end

function SignData:OnLoad(data)
	if data then 
		if data.d and (type(data.d)=="table") then self:Merge(data.d) end
	end
	self.done = true
	if self.data.lmb then self:EnableRead() else self:DisableRead() end
	self:UpdateLabel()
end

function SignData:Status()
	print("SignData : done = "..tostring(self.done))
	PrintArray(self.data,"data")
end

return SignData
