--mod名字
name = "whose your daddy"
--mod类型
description = "call your daddy,and you will not die/叫你爸爸,然后你就不会死了"
--mod作者
author = "glp"
--mod版本
version = "1.0.1"
--论坛帖子
forumthread = ""

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

--This let's the game know that this mod doesn't need to be listed in the server's mod listing
client_only_mod = false

--Let the mod system know that this mod is functional with Don't Starve Together
dst_compatible = true

all_clients_require_mod = true 

-- Can specify a custom icon for this mod!
--mod 图标xml
icon_atlas = "baba.xml"
--mod 图标纹理。注意：纹理图片必须是2的幂，否则游戏会崩溃
icon = "baba.tex"

-- Specify the priority
priority=3

local alpha = {"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"}
local KEY_F1 = 282
local keyslist = {}
for i = 1,#alpha do keyslist[i] = {description = alpha[i],data = i + KEY_F1 - 1} end

configuration_options =
{
    {
        name = "BaBa",
        options =
        {
            {description = "None", data = false},
            {description = "Call", data = true}
        },
        default = true,
    },
	{
		name = "BaBa_Key",
		label = "Call/No Call Daddy",
		hover = "You can Call/No Call Daddy.",
		options = keyslist,
		default = 288, 
	},
}
