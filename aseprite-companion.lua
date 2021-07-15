colorshadesdialog = dofile("./color-shades/color-shades.lua")

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
            app.alert{title="About Aseprite Companion", text={"Aseprite Companion v1.0.0", "An extension providing additional features for Aseprite", "MIT License", "Copyright (c) 2021 Jon Cote" }, buttons="Close"}
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

            local dialog = colorshadesdialog("Color Shades")
            dialog:show { wait = false }
        end
    }
end

function exit(plugin) end