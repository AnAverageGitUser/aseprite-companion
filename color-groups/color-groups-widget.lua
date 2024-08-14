return function(dialog, num_color_groups_per_page, color_groups)
    function get_shade_color_table(tbl)
        local shade_table = {}
        for i = 1, #tbl do
            table.insert(shade_table, index_to_color(tbl[i]))
        end
        return shade_table
    end

    function index_to_color(index)
        local palette = app.sprite.palettes[1]
        if index < #palette then
            return palette:getColor(index)
        else
            return palette:getColor(0)
        end
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