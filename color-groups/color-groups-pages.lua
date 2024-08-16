return function(dialog, num_color_groups_per_page, color_group_search, active_page)
    function get_shade_color_table(tbl)
        local shade_table = {}
        for i = 1, #tbl do
            local color = tbl[i]
            table.insert(shade_table, Color{ r=color.r, g=color.g, b=color.b, a=color.a })
        end
        return shade_table
    end

    local page_start_index = num_color_groups_per_page * (active_page - 1) + 1
    local page_end_index = num_color_groups_per_page * active_page

    -- update separator label
    dialog:modify {
        id = "nav-pos",
        text = "" .. active_page
    }

    -- update actual color groups
    local widget_index = 1
    for i = page_start_index, page_end_index do
        if i <= color_group_search.num_results() then
            local color_group = color_group_search.get_color_group(i)
            dialog:modify{
                id = "Shade"..tostring(widget_index),
                label = color_group.name,
                colors = get_shade_color_table(color_group.colors),
                visible = true,
                enabled = true
            }
        else
            dialog:modify{
                id = "Shade"..tostring(widget_index),
                label = nil,
                colors = {},
                visible = false,
                enabled = false,
            }
        end
        widget_index = widget_index + 1
    end

    return dialog
end