return function(dialog, from, to, visible)
    for i=from, to do
        dialog:modify{ id = "Shade"..tostring(i), visible = visible, enabled = true }
        end
    return dialog
end