return function(dialog, total_length, from, length)
    for i=1, total_length do
        dialog:modify{ id = "Shade"..tostring(i), visible = false, enabled = true }
    end
    for i=from, from + length - 1 do
        dialog:modify{ id = "Shade"..tostring(i), visible = true, enabled = true }
    end
    return dialog
end