--mod名字
name = "whose your daddy"
--mod类型
description = "call your daddy,and you will not die"
--mod作者
author = "glp"
--mod版本
version = "1.0.0"
--论坛帖子
forumthread = ""
--mod 图标xml
icon_atlas = "baba.xml"
--mod 图标纹理。注意：纹理图片必须是2的幂，否则游戏会崩溃
icon = "baba.tex"
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

-- this setting is dumb; this mod is likely compatible with all future versions
api_version = 6

local alpha = {"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"}
local KEY_A = 282
local keyslist = {}
for i = 1,#alpha do keyslist[i] = {description = alpha[i],data = i + KEY_A - 1} end

configuration_options =
{
    {
        name = "BaBa",
        options =
        {
            {description = "None", data = false},
            {description = "Call", data = true}
        },
        default = false,
    },
	{
		name = "BaBa_Key",
		label = "Call/No Call Daddy",
		hover = "You can Call/No Call Daddy.",
		options = keyslist,
		default = 288, 
	},
}
