colorshadesdialog = dofile("./color-shades/color-shades.lua")
colorgroupsdialog = dofile("./color-groups/color-groups.lua")
alert_extended = dofile("./shared/alert-extended.lua")

local color_groups_dialog_instance
local fn_foreground_color_changed

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
            if not app.isUIAvailable then
                return
            end

            if color_groups_dialog_instance == nil then
                color_groups_dialog_instance, fn_foreground_color_changed = colorgroupsdialog(
                    plugin,
                    "Aseprite Companion: Color Groups",
                    function()
                        color_groups_dialog_instance = nil
                    end
                )
                color_groups_dialog_instance:show { wait = false }
            else
                color_groups_dialog_instance:close()
                color_groups_dialog_instance = nil
                fn_foreground_color_changed = nil
            end
        end
    }
    app.events:on('fgcolorchange', function()
        if fn_foreground_color_changed ~= nil then
            fn_foreground_color_changed()
        end
    end)

    plugin:newCommand {
        id = "color_shades",
        title = "Color Shades",
        group = "aseprite_companion_group",
        onclick = function()
            -- Check is UI available
            if not app.isUIAvailable then
                return
            end

            local shadesdialog = colorshadesdialog("Aseprite Companion: Color Shades")
            shadesdialog:show { wait = false }
        end
    }

    plugin:newCommand {
        id = "aseprite-companion",
        title = "About",
        group = "aseprite_companion_group",
        onclick = function()
            -- Check is UI available
            if not app.isUIAvailable then
                return
            end
            app.alert{
                title="About Aseprite Companion",
                text={
                    "Aseprite Companion v2.1.1",
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