colorshadesdialog = dofile("./color-shades/color-shades.lua")
colorgroupsdialog = dofile("./color-groups/color-groups.lua")

function init(plugin)
    plugin:newCommand {
        id = "aseprite-companion",
        title = "[Aseprite Companion] ------------",
        group = "sprite_crop",
        onclick = function()
            -- Check is UI available
            if not app.isUIAvailable then
                return
            end
            app.alert{title="About Aseprite Companion",
                      text={"Aseprite Companion v1.0.0",
                            "An extension providing additional features for Aseprite",
                            "MIT License",
                            "Copyright (c) 2021 Jon Cote" }, buttons="Close"}
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
            if app.activeSprite == nil then return end
            local groupsdialog = colorgroupsdialog("Color Shades")
            groupsdialog:show { wait = false }
        end
    }
end

function exit(plugin) end