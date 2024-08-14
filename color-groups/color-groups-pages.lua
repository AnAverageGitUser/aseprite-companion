local previous_options = ""

return function(dialog, num_color_groups_per_page, color_groups, active_page, fn_gen_dropdown_options, selected_group_index)
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
        id = "groupsseparator",
        text = "Groups - Page " .. active_page
    }

    -- update actual color groups
    local widget_index = 1
    for i = page_start_index, page_end_index do
        if i <= #color_groups then
            local color_group = color_groups[i]
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
                visible = true,
                label = "None",
                colors = {},
                enabled = false
            }
        end
        widget_index = widget_index + 1
    end

    -- update group selection dropdown
    local options = fn_gen_dropdown_options(color_groups)
        previous_options = options_as_json
        dialog:modify{
            id = "groupsdropdown",
            option = options[selected_group_index],
            options = options
        }

    return dialog
end