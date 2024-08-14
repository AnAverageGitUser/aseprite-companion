return function(dialog, num_color_groups_per_page, color_groups)
    function get_shade_color_table(tbl)
        local shade_table = {}
        for i = 1, #tbl do
            local color = tbl[i]
            table.insert(shade_table, Color{ r=color.r, g=color.g, b=color.b, a=color.a })
        end
        return shade_table
    end

    for i = 1, num_color_groups_per_page do
        dialog:shades {
            id = "Shade" .. tostring(i),
            label = color_groups[i].name,
            mode = "pick",
            colors = get_shade_color_table(color_groups[i].colors),
            onclick = function(ev)
                if ev.button == MouseButton.LEFT then
                    app.fgColor = ev.color
                elseif ev.button == MouseButton.RIGHT then
                    app.bgColor = ev.color
                end
            end
        }
    end
    return dialog
end