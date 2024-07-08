return function(dialog, nb, colorgroups, pal)
    local actPal = pal

    function getshadecolortable(tbl)
        local shadetbl = {}
        for i = 2, #tbl do
            table.insert(shadetbl, indexToColor(tbl[i]))
        end
        return shadetbl
    end

    function indexToColor(index)
        local ncolors = #actPal
        local c = nil
        if index < ncolors then
            c = actPal:getColor(index)
        else
            c = actPal:getColor(0)
        end
        return c
    end

    for i = 1, nb do
        dialog:shades {
            id = "Shade" .. tostring(i),
            label = colorgroups[i][1],
            mode = "pick",
            colors = getshadecolortable(colorgroups[i]),
            onclick = function(ev)
                app.fgColor = ev.color
            end
        }
    end
    return dialog
end