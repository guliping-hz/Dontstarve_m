name = "Dont Erase My Saveslot"
description = "When you die and see the death screen,click \"Retry\" to get back to the last time you save the game,click \"Main menu\" to get to the main menu without erasing your saveslot."
author = "Artintel"
version = "1.4.1"
forumthread = ""
api_version = 6
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true

configuration_options = {
    {
        name = "Die in Adventure",
        options = {
            { description = "Load",            data = "load" },
            { description = "Back to Survival",    data = "back" }
        },
        default = "load",
    },
    {
        name = "Save Manually",
        options = {
            { description = "No",            data = "no" },
            { description = "F5",    data = "f5" }
        },
        default = "f5",
    }
}