mathextended = dofile("../shared/math-extended.lua")
quickguide = dofile("../shared/quick-reference-guide.lua")
tableextended = dofile("../shared/table-extended.lua")

local hueshiftvalue = 10
local satshiftvalue = 10
local lightshiftvalue = 10
local initialbasecolor = Color(199,90,104)
local c = initialbasecolor

function colorshift(color, light, hueshift, satshift, lightshift)
    -- (light 0 = darker) (light 1 = lighter)
    local newcolor = Color(color)
    if newcolor.hue < 60 then
        if light == 0 then
            if newcolor.hue + (hueshift * -1) * 359 < 0 then
                newcolor.hue = (360 - (-newcolor.hue)) + (hueshift * 1)
            else
                newcolor.hue = newcolor.hue + (hueshift * -1) * 359
            end
        else
            newcolor.hue = mathextended:clamp(newcolor.hue + (hueshift * 1) * 359, 0, 60)
        end
    end

    if newcolor.hue > 60 and newcolor.hue < 240 then
        if light == 0 then
            newcolor.hue = newcolor.hue + (hueshift * 1) * 359
        else
            if newcolor.hue < 70 then
                newcolor.hue = mathextended:clamp(newcolor.hue + ((hueshift / 2) * -1) * 359, 60, 359)
            else
                newcolor.hue = mathextended:clamp(newcolor.hue + (hueshift * -1) * 359, 60, 359)
            end
        end
    end

    if newcolor.hue >= 240 then
        if light == 0 then
            if newcolor.hue < 250 then
                newcolor.hue = mathextended:clamp(newcolor.hue + ((hueshift / 2) * -1) * 359, 240, 359)
            else
                newcolor.hue = mathextended:clamp(newcolor.hue + (hueshift * -1) * 359, 240, 359)
            end
        else
            newcolor.hue = newcolor.hue + (hueshift * 1) * 359
        end
    end

    if satshift > 0 then
        newcolor.saturation = mathextended:lerp(newcolor.saturation, 1, satshift)
    elseif satshift < 0 then
        newcolor.saturation = mathextended:lerp(newcolor.saturation, 0, -satshift)
    end

    if lightshift > 0 then
        newcolor.lightness = mathextended:lerp(newcolor.lightness, 1, lightshift)
    elseif lightshift < 0 then
        newcolor.lightness = mathextended:lerp(newcolor.lightness, 0, -lightshift)
    end

    return newcolor
end

function showdialog()
    local dlg = colorshadesdialog("Color Shades")
    dlg:show { wait = false, bounds = dialogbounds }
end

return function(dialogtitle)
    local quickguidetable = {
        {"separator", "Base Color"},
        {"label", "Shows the current base color used for the shades."},
        {"newrow"},
        {"label", "[Assign FG Color] will assign the forground color to the base color."},
        {"separator", "Shades"},
        {"label", "Current base color is fifth."},
        {"newrow"},
        {"label", "Simply click any color to set it as the foreground color."},
        {"separator", "Values"},
        {"label", "Use the sliders to adjust the shades HSL values."},
        {"newrow"},
        {"label", "[Reset to Default] will return them to their default values."}
    }

    local dlg = Dialog(dialogtitle)
    local square = "□ "
    local checkedsquare = "▣ "

    local s1 = colorshift(c, 0, mathextended:norm(hueshiftvalue, 0, 360) * 4, -mathextended:norm(satshiftvalue, 0, 100) * 5, -mathextended:norm(lightshiftvalue, 0, 100) * 8)
    local s2 = colorshift(c, 0, mathextended:norm(hueshiftvalue, 0, 360) * 3, -mathextended:norm(satshiftvalue, 0, 100) * 4, -mathextended:norm(lightshiftvalue, 0, 100) * 6)
    local s3 = colorshift(c, 0, mathextended:norm(hueshiftvalue, 0, 360) * 2, -mathextended:norm(satshiftvalue, 0, 100) * 3, -mathextended:norm(lightshiftvalue, 0, 100) * 4)
    local s4 = colorshift(c, 0, mathextended:norm(hueshiftvalue, 0, 360), -mathextended:norm(satshiftvalue, 0, 100) * 2, -mathextended:norm(lightshiftvalue, 0, 100) * 2)
    local s5 = colorshift(c, 1, mathextended:norm(hueshiftvalue, 0, 360), -mathextended:norm(satshiftvalue, 0, 100), mathextended:norm(lightshiftvalue, 0, 100) * 2)
    local s6 = colorshift(c, 1, mathextended:norm(hueshiftvalue, 0, 360) * 2, -mathextended:norm(satshiftvalue, 0, 100) * 1.5, mathextended:norm(lightshiftvalue, 0, 100) * 5)
    local s7 = colorshift(c, 1, mathextended:norm(hueshiftvalue, 0, 360) * 3, mathextended:norm(satshiftvalue, 0, 100) * 2, mathextended:norm(lightshiftvalue, 0, 100) * 8)

    dlg
            :separator{ text = "Base Color"}
            :color{ label = "Current", color = c }
            :button{ text = "Assign FG Color",
                     onclick=function()
                         c = app.fgColor
                         dialogbounds = dlg.bounds
                         dlg:close()
                         showdialog()
                     end
    }
            :separator{ id = "shades", label = "Shades", text = "Shades    " .. square .. square .. square .. square .. checkedsquare .. square .. square .. square }
            :shades{id='sha', colors={ s1, s2, s3, s4, c, s5, s6, s7 },
                    onclick=function(ev)
                        app.fgColor=ev.color
                    end
    }
            :newrow()
            :separator{ id = "sliders", label = "Values", text = "Values" }
            :slider{ id = "hueslider", label = "Hue", min = 0, max = 359, value = hueshiftvalue,
                     onrelease = function()
                         local data = dlg.data
                         hueshiftvalue = data.hueslider
                         dialogbounds = dlg.bounds
                         dlg:close()
                         showdialog()
                     end
    }
            :newrow()
            :slider{ id = "satslider", label = "Saturation", min = 0, max = 100, value = satshiftvalue,
                     onrelease = function()
                         local data = dlg.data
                         satshiftvalue = data.satslider
                         dialogbounds = dlg.bounds
                         dlg:close()
                         showdialog()
                     end
    }
            :newrow()
            :slider{ id = "lightslider", label = "Lightness", min = 0, max = 100, value = lightshiftvalue,
                     onrelease = function()
                         local data = dlg.data
                         lightshiftvalue = data.lightslider
                         dialogbounds = dlg.bounds
                         dlg:close()
                         showdialog()
                     end
    }
            :button{ text = "Reset to Default",
                     onclick=function()
                         hueshiftvalue = 10
                         satshiftvalue = 10
                         lightshiftvalue = 10
                         dialogbounds = dlg.bounds
                         dlg:close()
                         showdialog()
                     end
    }
    quickguide(dlg, quickguidetable)
    return dlg
end