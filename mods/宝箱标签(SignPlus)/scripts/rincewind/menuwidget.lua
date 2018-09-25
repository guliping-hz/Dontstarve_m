print ("Loading MenuWidget")

require "util"
--require "rincewind/craputil"
local MenuSettings = require "rincewind/menusettings"

----------------------------------------------------------------------------------------------------------
-- Too lazy to make proper class, maybe later in some day :)
----------------------------------------------------------------------------------------------------------

local function IsValidNumber(n)
	return n and (type(n)=="number") and (n > 0)
end

function MenuWidgetDefaults(v)
	if not (v.data or (type(v.data)=="string")) then
		print ("MenuWidgetDefaults : invalid data component name")
		return nil
	end
	local p = GetPlayer()
	
	if not (p and p.components and p.components[v.data] and p.components[v.data].data) then
		print ("MenuWidgetDefaults : invalid data component")
		return nil
	end
	p.components[v.data].data["default"] = {}
	local defaultdata = p.components[v.data].data["default"]
	if not (v and (type(v)=="table")) then return end
	if IsValidNumber(v.snap) then defaultdata.snap = v.snap end
	if IsValidNumber(v.sx) then defaultdata.sx = v.sx end
	if IsValidNumber(v.sy) then defaultdata.sy = v.sy end
	if IsValidNumber(v.width) then defaultdata.width = v.width end
	if IsValidNumber(v.height) then defaultdata.height = v.height end
	if IsValidNumber(v.x) then defaultdata.x = v.x end
	if IsValidNumber(v.y) then defaultdata.y = v.y end
	if (v.showreset~=nil) and type(v.showreset=="boolean") then defaultdata.showreset = v.showreset end
--	PrintArray(defaultdata,"defaultdata")
end

function MenuWidget(vv)
	if (not vv) or (type(vv)~="table") then
		print ("MenuWidget : invalid parameters")
		return nil
	end

	local p = GetPlayer()
	local v = deepcopy(vv) -- we dont want to change input variable inside

	if not (v.name and (type(v.name) == "string") and (string.len(v.name) > 0)) then
		print ("MenuWidget : invalid name ("..tostring(v.name)..")")
		return nil
	end

	if not (v.data or (type(v.data)=="string")) then
		print ("MenuWidget : invalid data component name")
		return nil
	end
	
	if (not p.components) or (not p.components[v.data]) then
		print ("MenuWidget : menudata not exists")
		return nil
	end

	if not (v.imgdir and (type(v.imgdir)=="string")) then v.imgdir = "" end
	if not (v.img and (type(v.img)=="string")) then v.img = "default" end
	if string.len(v.imgdir) > 0 then v.imgdir = v.imgdir .. "/" end

	local menuname = "menu"..v.name
	p.HUD.controls[menuname] = p.HUD.controls:AddChild(Image("images/"..v.imgdir..v.img..".xml", v.img..".tex"))
	local controls = p.HUD.controls
	local inst = p.HUD.controls[menuname]
	inst.dataname = v.data
	inst.imgdir = v.imgdir
	inst.oldOnMouseButton = inst.OnMouseButton
	inst.button = {}

	if (not p.components[v.data].data[v.name]) or (type(p.components[v.data].data[v.name])~="table") then
		p.components[v.data].data[v.name] = {}
	end

	if (not p.components[v.data].data["global"]) or (type(p.components[v.data].data["global"])~="table") then
		p.components[v.data].data["global"] = {}
	end

	local fndata = {}

	local menudata = p.components[v.data].data[v.name]
	local globaldata = p.components[v.data].data["global"]
	local defaultdata = p.components[v.data].data["default"]

	menudata.name = v.name

	if menudata.visible == nil then 
		if v.show then menudata.visible = true else menudata.visible = false end 
	end

	inst.tint		= {}
	inst.tint.normal	= "B59A6B"
	inst.tint.focus		= "F5ED10"
	inst.tint.disable 	= "9F2D26"
	inst.tint.active 	= "FFB300"

	if v.tint and (type(v.tint)=="table") then -- too lazy to make for ..in ..pair
		local function testcolor(c) if v.tint[c] and type(v.tint[c])=="string" and string.len(v.tint[c])==6 then inst.tint[c] = v.tint[c] end end
		testcolor("normal") testcolor("focus") testcolor("disable") testcolor("active")
	end

	function inst:GetGlobalXY()
		if (not globaldata.y) or (type(globaldata.y)~="number") then 
			globaldata.y = defaultdata.y
		else
			globaldata.y = globaldata.y + (globaldata.height * globaldata.sy + globaldata.snap)
		end
		if (not globaldata.x) or (type(globaldata.x)~="number") then globaldata.x = defaultdata.x end
	end

	function inst:ResetToDefault()
		globaldata.snap = defaultdata.snap
		globaldata.sx = defaultdata.sx
		globaldata.sy = defaultdata.sy
		menudata.width = defaultdata.width
		menudata.height = defaultdata.height
		self:GetGlobalXY()

		menudata.dx = globaldata.x
		menudata.dy = globaldata.y
		menudata.x = menudata.dx
		menudata.y = menudata.dy
	end

	function inst:InitOpt()
		if (not globaldata.snap) or (type(globaldata.snap)~="number")  then globaldata.snap = defaultdata.snap end
		if (not globaldata.sx) or (type(globaldata.sx)~="number") then globaldata.sx = defaultdata.sx end
		if (not globaldata.sy) or (type(globaldata.sy)~="number") then globaldata.sy = defaultdata.sy end
		if (not globaldata.height) or (type(globaldata.height)~="number") then globaldata.height = defaultdata.height end
		if (not menudata.width) or (type(menudata.width)~="number") then menudata.width = defaultdata.width end
		if (not menudata.height) or (type(menudata.height)~="number") then menudata.height = defaultdata.height end
		self:GetGlobalXY()
		if (menudata.visible==nil) or (type(menudata.visible)~="boolean") then menudata.visible = true end
		menudata.dx = globaldata.x
		menudata.dy = globaldata.y
		if (not menudata.x) or (type(menudata.x)~="number") then menudata.x = menudata.dx end
		if (not menudata.y) or (type(menudata.y)~="number") then menudata.y = menudata.dy end
		menudata.d = menudata.width
		menudata.wx = menudata.d
		if not (v.x and (type(v.x)=="number")) then v.x = globaldata.x end
		if not (v.y and (type(v.y)=="number")) then v.y = globaldata.y end
	end

	function inst:XY(xx,yy)
		menudata.dx = xx
		menudata.dy = yy
		if (not menudata.x) or (type(menudata.x)~="number") then menudata.x = xx end
		if (not menudata.y) or (type(menudata.y)~="number") then menudata.y = yy end
	end

	function inst:PlaceIt()
		self:SetScale(globaldata.sx,globaldata.sy,globaldata.sx)
		self:SetPosition(menudata.x,menudata.y,0)
	end

	function inst:ScaleAll()
		for k, v in pairs(controls) do 
			if controls[k] and (type(controls[k])=="table") and controls[k].imgdir and controls[k].PlaceIt and controls[k].SetScale 
				and controls[k].dataname and (controls[k].dataname==inst.dataname) then
					controls[k]:SetScale(globaldata.sx,globaldata.sy,globaldata.sx)
			end
		end
	end

	function inst:ResetAll()
		globaldata.y = nil
		globaldata.x = nil
		for k, v in pairsByKeys(controls) do 
			if controls[k] and (type(controls[k])=="table") and controls[k].imgdir and controls[k].PlaceIt and controls[k].ResetToDefault 
				and controls[k].dataname and (controls[k].dataname==inst.dataname) then 
				controls[k]:ResetToDefault()
				controls[k]:PlaceIt()
			end
		end
	end

	function inst:CustomFollowMouse()
		if self.followhandler then
			self.followhandler:Remove()
			self.followhandler = nil
			if menudata then
				local l = self:GetLocalPosition()
				menudata.x = l.x 
				menudata.y = l.y
			end
		else
        		self.followhandler = TheInput:AddMoveHandler(function(x,y) self:DeltaPosition(x,y) end)
		end
	end

	function inst:DeltaPosition(x, y)
		local delta = self:GetLocalPosition() - self:GetWorldPosition()
		x = math.ceil((x + delta.x)/globaldata.snap)*globaldata.snap
		y = math.ceil((y + delta.y)/globaldata.snap)*globaldata.snap
		self:SetPosition(x,y,0)
	end

	function inst:ShowOptions()
		TheFrontEnd:PushScreen(MenuSettings(inst,globaldata,defaultdata.showreset))
	end

	function inst:Toggle()
		menudata.visible = not menudata.visible
		self:ShowAll()
	end

	function inst:ForCode(code,fn,once)
		if not (fn and type(fn)=="function") then
			print ("ForCode : parameter fn must be a function")
			return
		end
		for k, v in pairs(self.button) do 
			local i = self.button[k]
			if not (i and i.bname) then 
				print ("ForCode : i["..tostring(k).."] is empty, aborting")
				return
			end
			local d = menudata[i.bname]
			if not d then
				print ("ForCode : d["..tostring(k).."] is empty, aborting")
				return
			end
			if tostring(d.code) == tostring(code) then 
				if once then return fn(i,d) else fn(i,d) end
			end
		end
	end

	function inst:ForEach(fn)
		if not (fn and type(fn)=="function") then
			print ("ForEach : parameter must be a function")
			return
		end
		for k, v in pairs(self.button) do 
			local i = self.button[k]
			if not (i and i.bname) then 
				print ("ForCode : i["..tostring(k).."] is empty, aborting")
				return
			end
			local d = menudata[i.bname]
			if not d then
				print ("ForCode : d["..tostring(k).."] is empty, aborting")
				return
			end
			fn(i,d)
		end
	end

	function inst:SetCode(code)
		local resetradio = self:ForCode(code,function (i,d) if d.radio then return d.code else return nil end end,true)
		local function setcode(i,d)
				if d.code == code then
					if d.radio or d.check then
						if d.radio and (not d.active) then d.active = true end
						if d.check then d.active = not d.active end
						i:SetActive(d.active)
					end
					if d.enabled and (d.code~=nil) and fndata and fndata[d.code] and (type(fndata[d.code])=="function") then 
						fndata[d.code](d.code,d.active) 
					end
				else
					if resetradio and d.radio then 
						d.active = false
						i:SetActive(d.active)
					end
				end
		end
		self:ForEach(setcode)
	end

	function inst:CallActiveButtons(isinit)	-- if radio or check button active, function is called (useful for onload)
		local function callactive(i,d)
			local f = true
			if isinit then f = d.initfn end
			if f and (d.radio or d.check) and d.active and d.enabled and (d.code~=nil) and fndata and 
				fndata[d.code] and (type(fndata[d.code])=="function") then 
					fndata[d.code](d.code,d.active) 
			end
		end
		self:ForEach(callactive)
	end

	function inst:InitActiveButtons()
		self:CallActiveButtons(true)
	end

	function inst:ResetButtons(f)  -- f = call function before deactivate
		local function resetbuttons(i,d)
			if f and d.active and d.enabled and d.check and (d.code~=nil) and fndata and 
				fndata[d.code] and (type(fndata[d.code])=="function") then 
					fndata[d.code](d.code,d.active) 
			end
			d.active = false
			i:SetActive(false)
		end
		self:ForEach(resetbuttons)
	end

	function inst:EnableCode(code,f)
		if not code then return end
		if f then f = true else f = false end
		self:ForCode(code,function (i,d) d.enabled=f i:SetActive(d.active) end)
	end

	function inst:InitCode(code,f)
		if not code then return end
		if f then f = true else f = false end
		self:ForCode(code,function (i,d) d.active=f d.initfn=false i:SetActive(d.active) end)
	end

	function inst:ShowAll()
		self:ForEach(function (i,d) if menudata.visible then i:Show() else i:Hide() end end)
	end

	function inst:OnMouseButton(button, down, x, y)
		local f = false
		if inst.oldOnMouseButton and (type(inst.oldOnMouseButton)=="function") then f = inst:oldOnMouseButton(button, down, x, y) end
		if down and (button == MOUSEBUTTON_MIDDLE) then self:CustomFollowMouse() end
		if down and (button == MOUSEBUTTON_RIGHT) then self:ShowOptions() end
		if (not f ) and down and (button == MOUSEBUTTON_LEFT) then self:Toggle() end
	end

	function inst:InitButton(mode)
		if (not inst.button) or (not inst.button[mode]) then return end
		self.button[mode]:SetPosition(menudata.wx,0,0)
		self.button[mode]:SetScale(0.9,0.9,0.9)
		menudata.wx = menudata.wx + menudata.d
	end

	function inst:MakeButton(code,img,fn,isradio,ischeckbox,initval)
		self.button[code] = self:AddChild(Image("images/"..inst.imgdir..img..".xml", img..".tex"))
		local button = self.button[code]
		local bname = "button"..tostring(code)
		button.bname = bname
		if (not menudata[bname]) or (type(menudata[bname])~="table") then menudata[bname] = {} end
		local buttondata = menudata[bname]
		buttondata.code = code
		fndata[code] = fn
		if type (fndata[code]) ~= "function" then fndata[code] = nil end

		if (not buttondata.radio) or (type(buttondata.radio)~="boolean") then
			buttondata.radio = (type(isradio)=="boolean") and (isradio == true)
		end
		if (not buttondata.check) or (type(buttondata.check)~="boolean") then
			buttondata.check = (type(ischeckbox)=="boolean") and (ischeckbox == true)
		end

		if (not buttondata.active) or (type(buttondata.active)~="boolean") then
			buttondata.active = false
		end

		if (not buttondata.enabled) or (type(buttondata.enabled)~="boolean") then
			buttondata.enabled = true
		end

		if buttondata.radio and buttondata.check then buttondata.check = false end
		buttondata.initfn = true

		function button:OnMouseButton(button, down, x, y)
			if down and (button == MOUSEBUTTON_LEFT) then 
				if buttondata.enabled then self:SetCode() end
				return true 
			end
		end
		
		function button:OnGainFocus()
			if self.enabled and buttondata.enabled then
				self:TintColor("focus")
				local s = 1
				self:SetScale(s,s,s)
			end
		end

		function button:OnLoseFocus()
			if self.enabled then
				self:SetActive(buttondata.active)
			end
		end

		function button:SetCode()
			self.parent:SetCode(buttondata.code)
		end

		function button:TintColor(name)
			local color = inst.tint[name]
			if not (color and (type(color)=="string")) then color = "FFFFFF" end
			local function subcolor(p) return tonumber(string.sub(color,p,p+1),16)/255 end
			self:SetTint(subcolor(1),subcolor(3),subcolor(5),1)
		end

		function button:SetActive(f)
			if buttondata.enabled then
				if f then 
					self:TintColor("active")
				else
					self:TintColor("normal")
				end
			else
				self:TintColor("disable")
			end
			local s = 0.9
			if buttondata.active then s = 0.95 end
			self:SetScale(s,s,s)
		end
		
		self:InitButton(code)
		if buttondata.radio or buttondata.check then button:SetActive(buttondata.active) else button:SetActive(false) end
		if not menudata.visible then button:Hide() end
		if initval~=nil then self:InitCode(code,initval) end
	end

	function inst:AddButton(code,img,fn,initval)		-- usual button, only action on press
		self:MakeButton(code,img,fn,false,false,initval)
	end

	function inst:AddRadioButton(code,img,fn,initval)		-- only one radio button can be active
		self:MakeButton(code,img,fn,true,false,initval)
	end

	function inst:AddCheckButton(code,img,fn,initval)		-- can be active or inactive
		self:MakeButton(code,img,fn,false,true,initval)
	end

	inst:InitOpt()
	if v.x and v.y then inst:XY(v.x,v.y) end
	inst:PlaceIt()

	return inst
end

