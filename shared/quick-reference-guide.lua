table_extended = dofile("../shared/table-extended.lua")

return function(dialog, widgetstable)

    local guidevisible = false

    function displayguide(visible)
        local len = table_extended.length(widgetstable)
        for i = 1, len do
            if widgetstable[i][1] ~= "newrow" then
                dialog:modify{ id= "guide"..tostring(i), visible = visible, enabled = true }
            end
        end
        dialog:modify{ id = "resize", visible = visible, enabled = true }
    end

    dialog:separator{ text = "Quick Reference"}
    dialog:button{ id = "guidebutton", text = "▼",
        onclick=function()
            if guidevisible == false then
                displayguide(true)
                guidevisible = true
                dialog:modify{ id = "guidebutton", text = "▲"}
            else
                displayguide(false)
                guidevisible = false
                dialog:modify{ id = "guidebutton", text = "▼"}
            end
    end
    }
    dialog:label{id = "resize", text = "Resize ▶ ▶ ▶ "}
    for i = 1, table_extended.length(widgetstable) do
        if widgetstable[i][1] == "separator" then
            dialog:separator{ id = "guide"..tostring(i), text = widgetstable[i][2] }
        elseif widgetstable[i][1] == "label" then
            dialog:label{ id = "guide"..tostring(i), text = widgetstable[i][2] }
        elseif widgetstable[i][1] == "newrow" then
            dialog:newrow()
        end
    end

    displayguide(false)

    return dialog
end