colorshadesdialog = dofile("./color-shades/color-shades.lua")
colorgroupsdialog = dofile("./color-groups/color-groups.lua")
alert_extended = dofile("./shared/alert-extended.lua")

function init(plugin)
    plugin:newCommand {
        id = "aseprite-companion",
        title = "[Aseprite Companion]",
        group = "sprite_crop",
        onclick = function()
            -- Check is UI available
            if not app.isUIAvailable then
                return
            end
            app.alert{
                title="About Aseprite Companion",
                text={
                    "Aseprite Companion v2.0.0",
                    "An extension providing additional features for Aseprite",
                    "MIT License",
                    "Copyright (c) 2021 Jon Cote",
                    "Copyright (c) 2024 AnAverageGitUser",
                    "",
                    "The source code is available at https://github.com/AnAverageGitUser/aseprite-companion",
                },
                buttons="Close"
            }
        end
    }

    plugin:newCommand {
        id = "color-shades",
        title = "Color Shades",
        group = "sprite_crop",
        onclick = function()
            -- Check is UI available
            if not app.isUIAvailable then
                return
            end

            local shadesdialog = colorshadesdialog("Color Shades")
            shadesdialog:show { wait = false }
        end
    }

    plugin:newCommand {
        id = "color-groups",
        title = "Color Groups",
        group = "sprite_crop",
        onclick = function()
            -- Check is UI available
            if not app.isUIAvailable then
                return
            end
            if not app.sprite then
                alert_extended.alert_error{
                    "There is no Sprite being worked on.",
                    "Please open a Sprite."
                }
                return
            end
            local groupsdialog = colorgroupsdialog("Color Groups")
            groupsdialog:show { wait = false }
        end
    }
end

function exit(plugin)
    
end