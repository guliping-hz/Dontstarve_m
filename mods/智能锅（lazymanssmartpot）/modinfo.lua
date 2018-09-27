name = "lazy man's smart-pot"

author = "HeiAZBZ"
version = "1.0.0"
-- "Version: "..version..
description = [[
Dozens of preset recipes! 
Record every time you cook!
]]


forumthread = "???"

dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
dst_compatible = true
-- this setting is dumb; this mod is likely compatible with all future versions
api_version = 6
api_version_dst = 10

priority                = 0
server_filter_tags        = { "smart", "cook", 'heiazbz' }

icon_atlas = "modicon.xml"
icon = "modicon.tex"

client_only_mod        = false --true  
all_clients_require_mod = true
configuration_options = {
    {    name = "LANGUAGE",
    label = "Language ",
    hover = "中文",
    options =    {
        { description = "Chinese(中文)", data = true },
        { description = "English(df)", data = false },
    },
    default = false,
    },
    --
    {    name = "====",
    label = "------------",
    hover = "",
    options =    {
        { description = "------------", data = false },
    },
    default = false,
    },

}