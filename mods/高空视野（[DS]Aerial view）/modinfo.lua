name = " [DS]Aerial view"
version = "1.2.3"
description = "[Ver."..version.."]\n高空视野，按快捷键隐藏面板（方便截图）.\n  F9隐藏操作界面\n  F10切换视角[高空视野、俯视图、游戏默认视角]\n \nIt's very useful for screenshot.\nEnhance your view.\n    1.Hide or Show HUD by pressing hotkey.\n    2.Change Camera by pressing hotkey."
author = "sam"

forumthread = ""

icon_atlas = "AerialView.xml"
icon = "AerialView.tex"

api_version = 6
api_version_dst = 10

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

local alpha = {"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"}
local KEY_A = 282
local keyslist = {}
for i = 1,#alpha do keyslist[i] = {description = alpha[i],data = i + KEY_A - 1} end

configuration_options =
{
	{
		name = "KEYBOARD_TOGGLE_HUD",
		label = "Show/Hide HUD",
		hover = "You can show or hide HUD.",
		options = keyslist,
		default = 290, 
	},
		{
		name = "KEYBOARD_TOGGLE_VIEW",
		label = "Change To Vertical View",
		hover = "Turn to vertical view Or reset to default.",
		options = keyslist,
		default = 291, 
	},
}	