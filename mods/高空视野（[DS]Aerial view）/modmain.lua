GLOBAL.TOGGLE_HUD = GetModConfigData("KEYBOARD_TOGGLE_HUD")
GLOBAL.TOGGLE_VIEW = GetModConfigData("KEYBOARD_TOGGLE_VIEW")

--[[
local require = GLOBAL.require
local FollowCamera=require "cameras/followcamera"
local cameradefault=FollowCamera.SetDefault
    function FollowCamera:SetDefault(...)
        cameradefault(self,...)
   --     if GetWorld() and not GetWorld():IsCave() then
        self.distancetarget = 30
        self.mindist = 15
        self.maxdist = 150
        self.mindistpitch = 30
        self.maxdistpitch = 60
     --   end
    end
--]]
--[[
local require = GLOBAL.require
local FollowCamera=require "cameras/followcamera"
local cameradefault=FollowCamera.SetDefault
    function FollowCamera:SetDefault(...)
        cameradefault(self,...)
   --     if GetWorld() and not GetWorld():IsCave() then
		self.zoomstep = 12
		self.mindist = 5
        self.maxdist = 180
        if GLOBAL.GetWorld() ~= nil and GLOBAL.GetWorld():IsCave()  then       
			self.mindistpitch = 25
			self.maxdistpitch = 90
			self.distancetarget = 25
		else
			self.mindistpitch = 40
			self.maxdistpitch = 60
			self.distancetarget = 30
		end
     --   end
    end
--]]
local function ChangeV(zoomstep,mindist,maxdist,mindistpitch,maxdistpitch,distancetarget,gains,default)

	local camera = GLOBAL.TheCamera
	local TheWorld = GLOBAL.GetWorld()
	zoomstep = zoomstep or camera.zoomstep
	mindist = mindist or camera.mindist
	maxdist = maxdist or camera.maxdist
	mindistpitch = mindistpitch or camera.mindistpitch
	maxdistpitch = maxdistpitch or camera.maxdistpitch
	distancetarget = distancetarget or camera.distancetarget
	
	camera.zoomstep = zoomstep
	camera.mindist = mindist
	camera.maxdist = maxdist
	camera.mindistpitch = mindistpitch
	camera.maxdistpitch = maxdistpitch
	--camera:SetDistance(math.ceil(mindist*2)-.1)
	camera.distancetarget = distancetarget
	
	if default then
		camera:SetDefault()
	end
end	

local Camera_Changed_VertView = 0
local function ChangeVertView()
		--参数zoomstep,mindist,maxdist,mindistpitch,maxdistpitch,distancetarget,gains,default
	--if not CHANGE_VIEW then return false end	
	if Camera_Changed_VertView == 2 then
		if GLOBAL.GetWorld() ~= nil and GLOBAL.GetWorld():IsCave() then	
			ChangeV(4, 15,35,	25,40,	25,nil,false)	 --cave 游戏默认
		else
			ChangeV(4, 15,50,	30,60,	30,nil,false)	 --forest 游戏默认
		end
		Camera_Changed_VertView = 0
		GLOBAL.GetPlayer() .components.talker:Say("Game Default")
	elseif Camera_Changed_VertView == 0 then	
		if GLOBAL.GetWorld() ~= nil and GLOBAL.GetWorld():IsCave() then
			ChangeV(12, 5,180, 25,90, 80,nil,false)
		else
			ChangeV(12, 5,180, 40,60, 80,nil,false) 	--forest
		end
		Camera_Changed_VertView	= 1
		GLOBAL.GetPlayer() .components.talker:Say("Aerial View")
	elseif Camera_Changed_VertView == 1 then
		if GLOBAL.GetWorld() ~= nil and GLOBAL.GetWorld():IsCave() then	
			ChangeV(nil, nil,nil, 90,nil, 80,nil,false)	 --cave maxdistpitch=90默认视角与原来一致  90最高为俯视 mindistpitch=90为全俯视图
		else
			ChangeV(nil, nil,nil, 90,nil, 80,nil,false)	 --forest mindistpitch=40默认视角与原来一致  mindistpitch=90为全俯视图
		end
		Camera_Changed_VertView = 2
		GLOBAL.GetPlayer().components.talker:Say("Vertical View")
	end
end	

local SoH_Status = true
local function ShowOrHideHUD()
	if SoH_Status == true  then --hide HUD
		GLOBAL.GetPlayer().HUD:Hide()
		SoH_Status = false
	else --show HUD
		GLOBAL.GetPlayer().HUD:Show()
		SoH_Status = true
	end
end

GLOBAL.TheInput:AddKeyUpHandler(GLOBAL.TOGGLE_HUD, ShowOrHideHUD)
GLOBAL.TheInput:AddKeyUpHandler(GLOBAL.TOGGLE_VIEW, ChangeVertView)