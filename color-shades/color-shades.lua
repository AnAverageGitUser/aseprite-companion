mathextended = dofile("../shared/math-extended.lua")
tableextended = dofile("../shared/table-extended.lua")

local hueshiftvalue = 10
local satshiftvalue = 10
local lightshiftvalue = 10
local initialbasecolor = Color(199,90,104)
local c = initialbasecolor

local colorshadesguidevisibility = false

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

function showshadesdialog()
    local colorshadesdlg = colorshadesdialog("Color Shades")
    colorshadesdlg:show { wait = false, bounds = dialogbounds }
end

return function(dialogtitle)
    local quickguidetable = {
        {"separator", "Base Color"},
        {"label", "-- Shows the current base color used for the shades."},
        {"newrow"},
        {"label", "-- [Assign FG Color] Assigns the foreground color to the base color."},
        {"separator", "Shades"},
        {"label", "-- The current base color is fifth."},
        {"newrow"},
        {"label", "-- [Add Shades to Palette] Add the shades to the current palette."},
        {"newrow"},
        {"label", "-- Simply click any color to set it as the foreground color."},
        {"separator", "Values"},
        {"label", "-- Use the sliders to adjust the shades HSL values."},
        {"newrow"},
        {"label", "-- [Reset to Default] Return sliders to their default values."}
    }

    local colorshadesdlg = Dialog(dialogtitle)
    local square = "□ "
    local checkedsquare = "▣ "

    local s1 = colorshift(c, 0, mathextended:norm(hueshiftvalue, 0, 360) * 4, -mathextended:norm(satshiftvalue, 0, 100) * 5, -mathextended:norm(lightshiftvalue, 0, 100) * 8)
    local s2 = colorshift(c, 0, mathextended:norm(hueshiftvalue, 0, 360) * 3, -mathextended:norm(satshiftvalue, 0, 100) * 4, -mathextended:norm(lightshiftvalue, 0, 100) * 6)
    local s3 = colorshift(c, 0, mathextended:norm(hueshiftvalue, 0, 360) * 2, -mathextended:norm(satshiftvalue, 0, 100) * 3, -mathextended:norm(lightshiftvalue, 0, 100) * 4)
    local s4 = colorshift(c, 0, mathextended:norm(hueshiftvalue, 0, 360), -mathextended:norm(satshiftvalue, 0, 100) * 2, -mathextended:norm(lightshiftvalue, 0, 100) * 2)
    local s5 = colorshift(c, 1, mathextended:norm(hueshiftvalue, 0, 360), -mathextended:norm(satshiftvalue, 0, 100), mathextended:norm(lightshiftvalue, 0, 100) * 2)
    local s6 = colorshift(c, 1, mathextended:norm(hueshiftvalue, 0, 360) * 2, -mathextended:norm(satshiftvalue, 0, 100) * 1.5, mathextended:norm(lightshiftvalue, 0, 100) * 5)
    local s7 = colorshift(c, 1, mathextended:norm(hueshiftvalue, 0, 360) * 3, mathextended:norm(satshiftvalue, 0, 100) * 2, mathextended:norm(lightshiftvalue, 0, 100) * 8)

    function displaycolorshadesguide(dialog ,widgetstable ,visible)
        local len = tableextended.length(widgetstable)
        for i = 1, len do
            if widgetstable[i][1] ~= "newrow" then
                dialog:modify{ id= "guide"..tostring(i), visible = visible, enabled = true }
            end
        end
        dialog:modify{ id = "resize", visible = visible, enabled = true }
    end

    colorshadesdlg:separator{ text = "Quick Reference"}
    colorshadesdlg:button{ id = "guidebutton", text = "▼",
                           onclick=function()
                               if guidevisible == false then
                                   displaycolorshadesguide(colorshadesdlg,quickguidetable,true)
                                   guidevisible = true
                                   colorshadesdlg:modify{ id = "guidebutton", text = "▲"}
                               else
                                   displaycolorshadesguide(colorshadesdlg,quickguidetable,false)
                                   guidevisible = false
                                   colorshadesdlg:modify{ id = "guidebutton", text = "▼"}
                               end
                           end
    }
    colorshadesdlg:label{id = "resize", text = "Resize ▶ ▶ ▶ "}
    for i = 1, tableextended.length(quickguidetable) do
        if quickguidetable[i][1] == "separator" then
            colorshadesdlg:separator{ id = "guide"..tostring(i), text = quickguidetable[i][2] }
        elseif quickguidetable[i][1] == "label" then
            colorshadesdlg:label{ id = "guide"..tostring(i), text = quickguidetable[i][2] }
        elseif quickguidetable[i][1] == "newrow" then
            colorshadesdlg:newrow()
        end
    end

    displaycolorshadesguide(colorshadesdlg,quickguidetable,false)
    
    colorshadesdlg
            :separator{ text = "Base Color" }
            :color{ label = "Current", color = c }
            :button{ text = "Assign FG Color",
                     onclick=function()
                         c = app.fgColor
                         dialogbounds = colorshadesdlg.bounds
                         colorshadesdlg:close()
                         showshadesdialog()
                     end
    }
            :separator{ id = "shades", label = "Shades", text = "Shades"}
            :shades{id='sha', colors={ s1, s2, s3, s4, c, s5, s6, s7 },
                    onclick=function(ev)
                        app.fgColor=ev.color
                    end
    }
            :newrow()
            :button{ text = "Add Shades to Palette",
                     onclick=function()
                         local currentshade = Color(255,255,255)
                         for i = 1, 9 do
                             if i == 1 then currentshade = s1
                             elseif i == 2 then currentshade = s2
                             elseif i == 3 then currentshade = s3
                             elseif i == 4 then currentshade = s4
                             elseif i == 5 then currentshade = c
                             elseif i == 6 then currentshade = s5
                             elseif i == 7 then currentshade = s6
                             elseif i == 8 then currentshade = s7
                             end
                             app.command.AddColor {
                             color = currentshade
                             }
                             end
                             dialogbounds = colorshadesdlg.bounds
                             colorshadesdlg:close()
                             showshadesdialog()
                             end
    }
            :newrow()
            :separator{ id = "sliders", label = "Values", text = "Values" }
            :slider{ id = "hueslider", label = "Hue", min = 0, max = 359, value = hueshiftvalue,
                     onrelease = function()
                         local data = colorshadesdlg.data
                         hueshiftvalue = data.hueslider
                         dialogbounds = colorshadesdlg.bounds
                         colorshadesdlg:close()
                         showshadesdialog()
                     end
    }
            :newrow()
            :slider{ id = "satslider", label = "Saturation", min = 0, max = 100, value = satshiftvalue,
                     onrelease = function()
                         local data = colorshadesdlg.data
                         satshiftvalue = data.satslider
                         dialogbounds = colorshadesdlg.bounds
                         colorshadesdlg:close()
                         showshadesdialog()
                     end
    }
            :newrow()
            :slider{ id = "lightslider", label = "Lightness", min = 0, max = 100, value = lightshiftvalue,
                     onrelease = function()
                         local data = colorshadesdlg.data
                         lightshiftvalue = data.lightslider
                         dialogbounds = colorshadesdlg.bounds
                         colorshadesdlg:close()
                         showshadesdialog()
                     end
    }
            :button{ text = "Reset to Default",
                     onclick=function()
                         hueshiftvalue = 10
                         satshiftvalue = 10
                         lightshiftvalue = 10
                         dialogbounds = colorshadesdlg.bounds
                         colorshadesdlg:close()
                         showshadesdialog()
                     end
    }
    return colorshadesdlg
end