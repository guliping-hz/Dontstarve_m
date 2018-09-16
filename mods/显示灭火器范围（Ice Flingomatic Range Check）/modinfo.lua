name = "Ice Fling Range Check"
description = ""
author = "_Q_"
version = "1.3"

forumthread = ""


api_version = 6

dont_starve_compatible = false
reign_of_giants_compatible = true
shipwrecked_compatible = true

icon_atlas = "modicon.xml"
icon = "Ice Fling Range Check.tex"

configuration_options =
{
    {
        name = "Range Check Time",
        options =
        {
            {description = "Short", data = "short"},
			{description = "Default", data = "default"},
			{description = "Long", data = "long"},
			{description = "Longer", data = "longer"},
			{description = "Longest", data = "longest"},
			{description = "Always", data = "always"},
        },
        default = "default",
    }
	
}