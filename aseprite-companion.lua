colorshadesdialog = dofile("./color-shades/color-shades.lua")
colorgroupsdialog = dofile("./color-groups/color-groups.lua")
alert_extended = dofile("./shared/alert-extended.lua")

function init(plugin)
    plugin:newMenuSeparator{
        group="sprite_crop"
    }

    plugin:newMenuGroup{
        id="aseprite_companion_group",
        title="[Aseprite Companion]",
        group="sprite_crop"
    }

    plugin:newCommand {
        id = "color_groups",
        title = "Color Groups",
        group = "aseprite_companion_group",
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

    plugin:newCommand {
        id = "color_shades",
        title = "Color Shades",
        group = "aseprite_companion_group",
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
        id = "aseprite-companion",
        title = "About Aseprite Companion",
        group = "aseprite_companion_group",
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
end

function exit(plugin)
    
end