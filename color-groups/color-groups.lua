table_extended = dofile("../shared/table-extended.lua")
file_extended = dofile("../shared/file-extended.lua")
alert_extended = dofile("../shared/alert-extended.lua")
rgb_to_hsv = dofile("../shared/rgb_to_hsv.lua")
color_groups_pages = dofile("./pages.lua")
selection = dofile("./entry-selection.lua")
search = dofile("./search.lua")

local plugin_prefs
local last_page
local selected_tool = "tools_pencil"
local tool_replace_input_real_index
local tool_replace_target_real_index
local groups_folder_path = app.fs.userConfigPath .. "groups\\"
local fast_forward_pages = 5
local active_page = 1
local num_color_groups = 300
local max_page_size = 20
function create_color_groups(num_table_entries)
    local color_groups = {}
    for i = 1, num_table_entries do
        color_groups[i] = {}
        color_groups[i].name = "Group " .. tostring(i)
        color_groups[i].colors = {}
        color_groups[i].labels = {}
    end
    return color_groups
end
local prefs = {
    version = "2.1.1",
    last_opened_tab = "tab_edit_mode",
    last_save_file = "",
    last_search_and = "",
    last_search_or = "",
    last_search_num_colors = nil,
    num_color_groups_per_page = 10,
    selection_visible = true,
    labels_visible = true,
    color_groups = create_color_groups(num_color_groups),
}

function get_color_group_labels_for_dropdown(index)
    local color_group = search.get_color_group(index)

    local tbl = {}

    for j = 1, #color_group.labels do
        local val = color_group.labels[j]
        if val ~= nil then
            table.insert(tbl, val)
        end
    end

    if #tbl == 0 then
        table.insert(tbl, "[ NO LABEL ]")
    end

    return tbl
end

function is_default_table_in_memory()
    if #search.get_all_labels() ~= 0 then
        return false
    end
    for i = 1, #prefs.color_groups do
        if #prefs.color_groups[i].colors ~= 0 then
            return false
        end
        if prefs.color_groups[i].name ~= "Group " .. tostring(i) then
            return false
        end
    end
    return true
end
function save_prefs()
    plugin_prefs.version = prefs.version
    plugin_prefs.last_save_file = prefs.last_save_file
    plugin_prefs.last_search_and = prefs.last_search_and
    plugin_prefs.last_search_or = prefs.last_search_or
    plugin_prefs.last_search_num_colors = prefs.last_search_num_colors
    plugin_prefs.num_color_groups_per_page = prefs.num_color_groups_per_page
    plugin_prefs.selection_visible = prefs.selection_visible
    plugin_prefs.labels_visible = prefs.labels_visible
    plugin_prefs.color_groups = json.encode(prefs.color_groups)
end
function init_globals(plugin_p)
    if plugin_p.preferences.color_group_dialog == nil then
        plugin_p.preferences.color_group_dialog = {}
        plugin_prefs = plugin_p.preferences.color_group_dialog
        save_prefs()
    elseif plugin_p.preferences.color_group_dialog.version ~= prefs.version then
        if plugin_p.preferences.color_group_dialog.version == "2.0.0" or
            plugin_p.preferences.color_group_dialog.version == "2.1.0"
        then
            -- if the prefs version is compatible, overwrite the old version
            plugin_p.preferences.color_group_dialog = prefs.version
        else
            -- if the prefs version is incompatible, we have to reset the settings
            plugin_p.preferences.color_group_dialog = {}
            plugin_prefs = plugin_p.preferences.color_group_dialog
            save_prefs()
        end
    else
        plugin_prefs = plugin_p.preferences.color_group_dialog
    end

    prefs.version = plugin_prefs.version
    prefs.last_save_file = plugin_prefs.last_save_file
    prefs.last_search_and = plugin_prefs.last_search_and
    prefs.last_search_or = plugin_prefs.last_search_or
    prefs.last_search_num_colors = plugin_prefs.last_search_num_colors
    prefs.num_color_groups_per_page = plugin_prefs.num_color_groups_per_page
    prefs.selection_visible = plugin_prefs.selection_visible
    prefs.labels_visible = plugin_prefs.labels_visible
    prefs.color_groups = json.decode(plugin_prefs.color_groups)

    last_page = math.tointeger((num_color_groups + prefs.num_color_groups_per_page - 1) / prefs.num_color_groups_per_page)
    reset_selection(prefs.color_groups, active_page)
end

function update_groups_view(dialog)
    last_page = math.tointeger((search.num_results() + prefs.num_color_groups_per_page - 1) / prefs.num_color_groups_per_page)

    update_navigation(dialog)

    local selection_enabled = not search.empty()
    dialog:modify { id = "sel-prev", enabled = selection_enabled }
    dialog:modify { id = "sel-next", enabled = selection_enabled }

    color_groups_pages(dialog, prefs.num_color_groups_per_page, search, active_page)
end

function update_view_visibility(dialog, visible)
    dialog:modify{ id="view_groups_less", visible=visible }
    dialog:modify{ id="view_groups", visible=visible }
    dialog:modify{ id="view_groups_more", visible=visible }
    dialog:modify{ id="view_toggle_selector", visible=visible }
    dialog:modify{ id="view_toggle_labels", visible=visible }
end
function update_edit_mode_visibility(dialog, visible)
    dialog:modify{ id="edit_mode_add_colors", visible=visible }
    dialog:modify{ id="edit_mode_clear_colors", visible=visible }
    dialog:modify{ id="edit_mode_add_colors_from_selection", visible=visible }
    dialog:modify{ id="edit_mode_rename", visible=visible }
end
function update_save_load_visibility(dialog, visible)
    dialog:modify{ id="save_load_filename", visible=visible }
    dialog:modify{ id="save_load_save", visible=visible }
    dialog:modify{ id="save_load_load", visible=visible }
    dialog:modify{ id="save_load_open_folder", visible=visible }
    dialog:modify{ id="save_load_reset_all_groups", visible=visible }
end
function update_label_visibility(dialog, visible)
    dialog:modify{ id="label_labels", visible=visible }
    dialog:modify{ id="label_input", visible=visible }
    dialog:modify{ id="label_add", visible=visible }
    dialog:modify{ id="label_labels_dropdown", visible=visible }
    dialog:modify{ id="label_remove", visible=visible }
end
function update_search_visibility(dialog, visible)
    dialog:modify{ id="search_labels", visible=visible }
    dialog:modify{ id="search_and", visible=visible }
    dialog:modify{ id="search_and_text", visible=visible }
    dialog:modify{ id="search_or", visible=visible }
    dialog:modify{ id="search_term", visible=visible }
    dialog:modify{ id="search_num_color_filter", visible=visible }
    dialog:modify{ id="search_start", visible=visible }
    dialog:modify{ id="search_clear", visible=visible }
end
function update_tools_visibility(dialog, visible)
    dialog:modify{ id="tools_pencil", visible=visible }
    dialog:modify{ id="tools_shading_add", visible=visible }
    dialog:modify{ id="tools_shading_replace", visible=visible }
    dialog:modify{ id="tools_replace_select", visible=visible }
    dialog:modify{ id="tools_replace", visible=visible }
    dialog:modify{ id="tools_check_pixels", visible=visible }
    dialog:modify{ id="tools_color_picker", visible=visible }
end

function update_selection_visibility(dialog, visible)
    for i = 1, max_page_size do
        dialog
                :modify { id = "ShadeSeparatorTop" .. tostring(i), visible = false }
                :modify { id = "ShadeSeparatorBottom" .. tostring(i), visible = false }
    end

    local active_index = selection.offset() + 1
    dialog
        :modify { id = "ShadeSeparatorTop" .. tostring(active_index), visible = visible }
        :modify { id = "ShadeSeparatorBottom" .. tostring(active_index), visible = visible }
end

function reset_selection(cg, active_page_num)
    search.set_color_groups(cg)
    search.clear_search()
    active_page = 1
    update_selection_page(active_page_num)
end
function update_selection_page(active_page_num)
    selection.set_range(
        prefs.num_color_groups_per_page * (active_page_num - 1) + 1,
        math.min(prefs.num_color_groups_per_page * active_page_num, math.max(search.num_results(), 1))
    )
end

function update_bottom_label_view(dialog)
    for i=1, max_page_size do
        dialog:modify{ id = "ShadeSeparatorLabels" .. tostring(i), visible = false }
    end
    if search.empty() then
        return
    end

    for i=1, math.min(prefs.num_color_groups_per_page, search.num_results() - selection.range_min + 1) do
        local labels = ""
        local idx = selection.range_min - 1 + i
        local color_group = search.get_color_group(idx)
        for j = 1, #color_group.labels do
            if color_group.labels[j] ~= nil then
                labels = labels .. color_group.labels[j] .. " "
            end
        end

        dialog:modify{
            id = "ShadeSeparatorLabels" .. tostring(i),
            visible = prefs.labels_visible,
            text = labels,
        }
    end
end
function update_page_widgets_visibility(dialog)
    for i=1, max_page_size do
        local visible = i <= prefs.num_color_groups_per_page
        dialog:modify{ id = "Shade" .. tostring(i), visible = visible }
    end
end
function convert_32bit_color_array_to_table_colors(array_32bit)
    local tbl = {}
    for i=1, #array_32bit do
        local r = app.pixelColor.rgbaR(array_32bit[i])
        local g = app.pixelColor.rgbaG(array_32bit[i])
        local b = app.pixelColor.rgbaB(array_32bit[i])
        local a = app.pixelColor.rgbaA(array_32bit[i])
        table.insert(tbl, {r=r, g=g, b=b, a=a})
    end
    return tbl
end
function insert_color_if_not_contained(array_32bit, color_32bit)
    if app.pixelColor.rgbaA(color_32bit) == 0 then
        return -- skip fully transparent pixels for the palette
    end
    for i=1, #array_32bit do
        if array_32bit[i] == color_32bit then
            return -- no duplicates
        end
    end
    table.insert(array_32bit, color_32bit)
end
function add_color_group_row(dialog, index)
    function get_shade_color_table(tbl)
        local shade_table = {}
        for i = 1, #tbl do
            local color = tbl[i]
            table.insert(shade_table, Color{ r=color.r, g=color.g, b=color.b, a=color.a })
        end
        return shade_table
    end

    local visible_index = index <= prefs.num_color_groups_per_page
    local visible_label = visible_index and prefs.labels_visible
    local visible_selector = visible_index and prefs.selection_visible and index - 1 == selection.offset()
    local color_group = search.get_color_group(index)
    local shade_index = index
    dialog
        :label { id = "ShadeSeparatorTop" .. tostring(index), label = " ▼▼▼ ", text = " ▼▼▼ Selected ▼▼▼", visible = visible_selector }
        :label { id = "ShadeSeparatorLabels" .. tostring(index), label = "Labels", visible = visible_label }
        :shades {
            id = "Shade" .. tostring(index),
            label = color_group.name,
            visible = visible_index,
            mode = "pick",
            colors = get_shade_color_table(color_group.colors),
            onclick = function(ev)
                if selected_tool == "tools_pencil" then
                    app.tool = "pencil"
                    app.command.SetInkType { type = Ink.SIMPLE }

                    if ev.button == MouseButton.LEFT then
                        app.fgColor = ev.color
                    elseif ev.button == MouseButton.RIGHT then
                        app.bgColor = ev.color
                    end
                elseif selected_tool == "tools_shading_add" then
                    if not app.sprite then
                        alert_extended.alert_error("This only works if a sprite is active.")
                        return
                    end
                    local pre_add = #app.sprite.palettes[1]

                    local current_color_group = search.get_color_group(shade_index - 1 + selection.range_min)
                    app.sprite.palettes[1]:resize(#app.sprite.palettes[1] + #current_color_group.colors)
                    for i = 1, #current_color_group.colors do
                        local color = current_color_group.colors[i]
                        app.sprite.palettes[1]:setColor(pre_add - 1 + i, Color{ r=color.r, g=color.g, b=color.b, a=color.a })
                    end
                    local post_add = #app.sprite.palettes[1]

                    local new_color_range_selection = {}
                    for i=pre_add, post_add - 1 do
                        table.insert(new_color_range_selection, i)
                    end
                    app.range.colors = new_color_range_selection

                    app.tool = "pencil"
                    -- we want the shading ink but we have to switch back and forth for the color range to update
                    app.command.SetInkType { type = Ink.SIMPLE }
                    app.command.SetInkType { type = Ink.SHADING }
                elseif selected_tool == "tools_shading_replace" then
                    if not app.sprite then
                        alert_extended.alert_error("This only works if a sprite is active.")
                        return
                    end
                    local current_color_group = search.get_color_group(shade_index - 1 + selection.range_min)
                    app.sprite.palettes[1]:resize(#current_color_group.colors)
                    for i = 1, #current_color_group.colors do
                        local color = current_color_group.colors[i]
                        app.sprite.palettes[1]:setColor(i - 1, Color{ r=color.r, g=color.g, b=color.b, a=color.a })
                    end

                    local new_color_range_selection = {}
                    for i=0, #current_color_group.colors - 1 do
                        table.insert(new_color_range_selection, i)
                    end
                    app.range.colors = new_color_range_selection

                    app.range.colors = new_color_range_selection
                    app.tool = "pencil"
                    -- we want the shading ink but we have to switch back and forth for the color range to update
                    app.command.SetInkType { type = Ink.SIMPLE }
                    app.command.SetInkType { type = Ink.SHADING }
                elseif selected_tool == "tools_replace_select" then
                    local real_index = search.get_real_color_group_index(shade_index - 1 + selection.range_min)
                    if ev.button == MouseButton.LEFT then
                        tool_replace_input_real_index = real_index
                    elseif ev.button == MouseButton.RIGHT then
                        tool_replace_target_real_index = real_index
                    end
                elseif selected_tool == "tools_check_pixels" then
                    local worked_on_images = {}
                    local check_colors = search.get_real_color_group(shade_index - 1 + selection.range_min).colors
                    local colors_not_inside = { }

                    if not app.sprite then
                        alert_extended.alert_error("This only works if a sprite is active.")
                        return
                    end
                    if not app.range or app.range.type == RangeType.EMPTY then
                        alert_extended.alert_error({
                            "Nothing is selected.",
                            "First select layers, frames or cels.",
                        })
                        return
                    end
                    for_selection_do(function(cel)
                        if cel == nil then
                            return
                        end
                        local image = cel.image
                        if image == nil then
                            return
                        end
                        if search.contains(worked_on_images, image.id) then
                            -- if cells are linked, they share the same image, we do not want check them again
                            return
                        end
                        table.insert(worked_on_images, image.id)

                        for px_iter in image:pixels() do
                            local px_32bit = px_iter()
                            local r = app.pixelColor.rgbaR(px_32bit)
                            local g = app.pixelColor.rgbaG(px_32bit)
                            local b = app.pixelColor.rgbaB(px_32bit)
                            local a = app.pixelColor.rgbaA(px_32bit)
                            -- check if the color is in the selected group
                            for i = 1, #check_colors do
                                local check_color = check_colors[i]
                                if check_color.r == r and check_color.g == g and check_color.b == b and check_color.a == a then
                                    goto skip_color
                                end
                            end
                            -- check if the color is in the set of colors we already took note of
                            for i = 1, #colors_not_inside do
                                local check_color = colors_not_inside[i]
                                if check_color.r == r and check_color.g == g and check_color.b == b and check_color.a == a then
                                    goto skip_color
                                end
                            end
                            table.insert(colors_not_inside, { r=r, g=g, b=b, a=a })
                            ::skip_color::
                        end
                    end)
                    local colors_not_inside_txt = ""
                    for i = 1, #colors_not_inside do
                        local check_color = colors_not_inside[i]
                        colors_not_inside_txt = colors_not_inside_txt .. "RGBA("..check_color.r..","..check_color.g..","..check_color.b..","..check_color.a..");"
                    end

                    local info_dlg = Dialog { title = "Aseprite Companion: Stray Color Results" }
                            :label{ text = "A total of " .. #colors_not_inside .. " unique colors that were not within the selected color group were found." }
                    if #colors_not_inside ~= 0 then
                        info_dlg:newrow()
                                :label{ text = "They have the following values:" }
                                :entry{ label = "Copy Me:", text = colors_not_inside_txt }
                    end
                    info_dlg:show{ wait = true }
                elseif selected_tool == "tools_color_picker" then
                    -- do nothing, everything should be done by the callback already
                else
                    alert_extended.alert_error("Internal error: The active tool is unknown.")
                end
            end
        }
        :label { id = "ShadeSeparatorBottom" .. tostring(index), label = " ▲▲▲ ", text = " ▲▲▲ Selected ▲▲▲", visible = visible_selector }
end
function update_navigation(dialog)
    local enable_prev, enable_next
    if last_page == 1 then
        enable_prev = false
        enable_next = false
    elseif active_page <= 1 then
        enable_prev = false
        enable_next = true
    elseif active_page >= last_page then
        enable_prev = true
        enable_next = false
    else
        enable_prev = true
        enable_next = true
    end

    dialog:modify{ id = "nav-first", enabled = enable_prev }
    dialog:modify{ id = "nav-prev-fast", enabled = enable_prev }
    dialog:modify{ id = "nav-prev", enabled = enable_prev }

    dialog:modify{ id = "nav-next", enabled = enable_next }
    dialog:modify{ id = "nav-next-fast", enabled = enable_next }
    dialog:modify{ id = "nav-last", enabled = enable_next }
end
function for_selection_do(fn_exec_on_cel)
    if app.range.type == RangeType.LAYERS then
        local layers = app.range.layers
        for i = 1,#layers do
            local layer = app.range.layers[i]
            if layer.isGroup then
                for j = 1,#layer.layers do
                    local inner_layer = layer.layers[j]
                    for k = 1,#inner_layer.cels do
                        local cel = inner_layer.cels[k]
                        fn_exec_on_cel(cel)
                    end
                end
            else
                for k = 1,#layer.cels do
                    local cel = layer.cels[k]
                    fn_exec_on_cel(cel)
                end
            end
        end
    elseif app.range.type == RangeType.FRAMES then
        local layers = app.sprite.layers
        for i = 1, #layers do
            local layer = layers[i]
            if layer.isGroup then
                for inner_i = 1,#layer.layers do
                    local inner_layer = layer.layers[inner_i]
                    for j = 1, #app.range.frames do
                        local frame = app.range.frames[j]
                        local cel = inner_layer:cel(frame)
                        fn_exec_on_cel(cel)
                    end
                end
            else
                for j = 1, #app.range.frames do
                    local frame = app.range.frames[j]
                    local cel = layer:cel(frame)
                    fn_exec_on_cel(cel)
                end
            end
        end
    elseif app.range.type == RangeType.CELS then
        local cels = app.range.cels
        for i = 1, #cels do
            local cel = cels[i]
            fn_exec_on_cel(cel)
        end
    end
end

return function(plugin, dialog_title, fn_on_close)
    function tab_view(dialog)
        local tab_id = "tab_view"
        dialog
            :tab{ id=tab_id, text="View" }
            :button{
                id = "view_groups_less",
                label = "Groups per Page",
                text = "<",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    if prefs.num_color_groups_per_page <= 1 then
                        return
                    end
                    prefs.num_color_groups_per_page = prefs.num_color_groups_per_page - 1
                    save_prefs()
                    dialog:modify{ id = "view_groups", text = "" .. prefs.num_color_groups_per_page }
                    active_page = 1
                    update_page_widgets_visibility(dialog)
                    update_selection_page(active_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_bottom_label_view(dialog)
                    update_groups_view(dialog)
                end
            }
            :button{
                id = "view_groups",
                text = "" .. prefs.num_color_groups_per_page,
                visible = prefs.last_opened_tab == tab_id,
                enabled = false,
            }
            :button{
                id = "view_groups_more",
                text = ">",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    if prefs.num_color_groups_per_page >= max_page_size then
                        return
                    end
                    prefs.num_color_groups_per_page = prefs.num_color_groups_per_page + 1
                    save_prefs()
                    dialog:modify{ id = "view_groups", text = "" .. prefs.num_color_groups_per_page }
                    active_page = 1
                    update_page_widgets_visibility(dialog)
                    update_selection_page(active_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_bottom_label_view(dialog)
                    update_groups_view(dialog)
                end
            }
            :button{
                id = "view_toggle_selector",
                label = "Selector",
                text = "Show / Hide",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    prefs.selection_visible = not prefs.selection_visible
                    save_prefs()

                    dialog:modify{ id = "sel-prev", visible = prefs.selection_visible }
                    dialog:modify{ id = "sel-next", visible = prefs.selection_visible }

                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_groups_view(dialog)
                end
            }
            :button{
                id = "view_toggle_labels",
                label = "Labels",
                text = "Show / Hide",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    prefs.labels_visible = not prefs.labels_visible
                    save_prefs()
                    update_bottom_label_view(dialog)
                end
            }
            :newrow()
    end
    function tab_save_load(dialog)
        local tab_id = "tab_save_load"
        dialog
            :tab{ id=tab_id, text="Save/Load" }
            :entry {
                id = 'save_load_filename',
                label = "File Name",
                text = prefs.last_save_file
            }
            :button {
                id = "save_load_save",
                text = "Save",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    local name = dialog.data.save_load_filename
                    prefs.last_save_file = name
                    save_prefs()

                    local file_path = groups_folder_path .. name .. ".json"
                    table_extended.save_color_groups(prefs.color_groups, groups_folder_path, file_path, name)
                end
            }
            :button {
                id = "save_load_load",
                text = "Load",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    local name = dialog.data.save_load_filename
                    prefs.last_save_file = name
                    save_prefs()

                    local file_path = groups_folder_path .. name .. ".json"
                    local loaded_groups_or_nil = table_extended.load_color_groups(file_path, is_default_table_in_memory)
                    if loaded_groups_or_nil ~= nil then
                        prefs.color_groups = loaded_groups_or_nil
                        reset_selection(prefs.color_groups, active_page)
                        update_bottom_label_view(dialog)
                        update_groups_view(dialog)
                        save_prefs()
                        dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                        dialog:modify{ id = "search_num_color_filter", options = search.get_all_color_group_lengths() }
                    end
                end
            }
            :button {
                id = "save_load_open_folder",
                text = "Open Folder",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    os.execute("start " .. groups_folder_path)
                end
            }
            :newrow()
            :button {
                id = "save_load_reset_all_groups",
                text = "Reset All Loaded Color Groups",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    local result = app.alert{
                        title = "Aseprite Companion: Reset All Loaded Color Groups?",
                        text = {
                            "Are you sure that you want to clear all color groups that are loaded in this dialog?",
                            "This will not affect any files on disk.",
                            "If you are unsure you should save your color groups first.",
                        },
                        buttons = { "Yes: Reset Groups", "No" }
                    }
                    if result ~= 1 then
                        return
                    end
                    prefs.color_groups = create_color_groups(num_color_groups)
                    reset_selection(prefs.color_groups, active_page)
                    update_bottom_label_view(dialog)
                    update_groups_view(dialog)
                end
            }
            :newrow()
    end
    function tab_edit_mode(dialog)
        local tab_id = "tab_edit_mode"
        dialog
                :tab{ id=tab_id, text="Edit Groups" }
                :entry {
            id = "edit_mode_group_name",
            label = "Group Name",
            onclick = function()
            end
        }
        :button {
            id = "edit_mode_rename",
            text = "Rename Group",
            visible = prefs.last_opened_tab == tab_id,
            onclick = function()
                if search.empty() then
                    alert_extended.alert_error("No color group is selected.")
                    return
                end
                local edit_mode_group_name = dialog.data.edit_mode_group_name
                if edit_mode_group_name ~= "" then
                    local group_idx = selection.index()
                    local color_group = search.get_color_group(group_idx)
                    color_group.name = edit_mode_group_name
                    save_prefs()
                end
                update_groups_view(dialog)
            end
        }
        :newrow()
        :button {
            id = "edit_mode_add_colors",
            text = "Add Colors",
            visible = prefs.last_opened_tab == tab_id,
            onclick = function()
                if not app.sprite then
                    alert_extended.alert_error("This only works if a sprite is active.")
                    return
                end
                if search.empty() then
                    alert_extended.alert_error("No color group is selected.")
                    return
                end

                local group_idx = selection.index()
                local color_group = search.get_color_group(group_idx)
                local selectedColors = app.range.colors
                local palette = app.sprite.palettes[1]
                for j = 1, #selectedColors do
                    local color = palette:getColor(selectedColors[j])
                    table.insert(color_group.colors, {
                        r = color.red,
                        g = color.green,
                        b = color.blue,
                        a = color.alpha,
                    })
                end
                save_prefs()
                update_groups_view(dialog)
                dialog:modify{ id = "search_num_color_filter", options = search.get_all_color_group_lengths() }
            end
        }
        :button {
            id = "edit_mode_clear_colors",
            text = "Clear Colors",
            visible = prefs.last_opened_tab == tab_id,
            onclick = function()
                if search.empty() then
                    alert_extended.alert_error("No color group is selected.")
                    return
                end
                local group_idx = selection.index()
                local color_group = search.get_color_group(group_idx)
                color_group.colors = {}
                save_prefs()
                update_groups_view(dialog)
                dialog:modify{ id = "search_num_color_filter", options = search.get_all_color_group_lengths() }
            end
        }
        :newrow()
        :button {
            id = "edit_mode_add_colors_from_selection",
            text = "Add Palette of Selected Layers/Cels/Frames",
            visible = prefs.last_opened_tab == tab_id,
            onclick = function()
                if not app.sprite then
                    alert_extended.alert_error("This only works if a sprite is active.")
                    return
                end
                if not app.range or app.range.type == RangeType.EMPTY then
                    alert_extended.alert_error({
                        "Nothing is selected.",
                        "First select layers, frames or cels.",
                    })
                    return
                end
                if search.empty() then
                    alert_extended.alert_error("No color group is selected.")
                    return
                end
                local color_group_32bit = {}
                for_selection_do(function (cel)
                    if cel == nil then
                        return
                    end
                    local image = cel.image
                    if image == nil then
                        return
                    end

                    for px_iter in image:pixels() do
                        local px_32bit = px_iter()
                        insert_color_if_not_contained(color_group_32bit, px_32bit)
                    end
                end)
                local sort_these_colors = convert_32bit_color_array_to_table_colors(color_group_32bit)
                local fn_color_ordinal = function(r, g, b)
                    local h, s, v = rgb_to_hsv(r, g, b)
                    -- magic formula that I tweaked by hand: keep hues together,
                    -- put bright colors in their ramps to the right and dark colors to the left
                    return h * 10 + (1 - s) + v
                end
                local fn_cmp = function(rgba1, rgba2)
                    local ordinal1 = fn_color_ordinal(rgba1.r / 255, rgba1.g / 255, rgba1.b / 255)
                    local ordinal2 = fn_color_ordinal(rgba2.r / 255, rgba2.g / 255, rgba2.b / 255)
                    return ordinal1 < ordinal2
                end
                table.sort(sort_these_colors, fn_cmp)
                search.get_color_group(selection.index()).colors = sort_these_colors

                save_prefs()
                update_groups_view(dialog)
                dialog:modify{ id = "search_num_color_filter", options = search.get_all_color_group_lengths() }
            end
        }
        :newrow()
    end
    function tab_labels(dialog)
        local tab_id = "tab_label"
        dialog
            :tab{ id=tab_id, text="Label" }
            :combobox {
                id = "label_labels",
                label = "Existing Labels",
                visible = prefs.last_opened_tab == tab_id,
                options = search.get_color_group(1).labels,
            }
            :entry {
                id = 'label_input',
                label = "Add Label",
                visible = prefs.last_opened_tab == tab_id,
            }
            :button {
                id = "label_add",
                text = "Add",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    if search.empty() then
                        alert_extended.alert_error("No color group is selected.")
                        return
                    end
                    local label = dialog.data.label_input
                    if label == "" then
                        return
                    end
                    label = label:gsub("%s", "_") -- do not allow whitespace characters as labels
                    local group_idx = selection.index()
                    local color_group = search.get_color_group(group_idx)
                    for i=1, #color_group.labels do
                        if color_group.labels[i] == label then
                            goto skip_insertion -- no duplicates
                        end
                    end
                    table.insert(color_group.labels, label)
                    save_prefs()
                    ::skip_insertion::
                    dialog:modify{
                        id = "label_labels_dropdown",
                        option = label,
                        options = get_color_group_labels_for_dropdown(selection.index())
                    }
                    dialog:modify{
                        id = "label_labels",
                        option = label,
                        options = search.get_all_labels()
                    }
                    update_bottom_label_view(dialog)
                end
            }
            :combobox {
                id = "label_labels_dropdown",
                label = "Remove Label",
                visible = prefs.last_opened_tab == tab_id,
                options = prefs.color_groups[1].labels
            }
            :button {
                id = "label_remove",
                text = "Remove",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    if search.empty() then
                        alert_extended.alert_error("No color group is selected.")
                        return
                    end
                    local label = dialog.data.label_labels_dropdown
                    if label == nil or label == "" then
                        return
                    end
                    local group_idx = selection.index()
                    local color_group = search.get_color_group(group_idx)
                    local new_table = {}
                    for i=1, #color_group.labels do
                        if color_group.labels[i] ~= label then
                            table.insert(new_table, color_group.labels[i])
                        end
                    end
                    -- if table.remove would be used, "null" values would wander into the json object, thanks lua!
                    color_group.labels = new_table
                    save_prefs()

                    dialog:modify{
                        id = "label_labels_dropdown",
                        options = get_color_group_labels_for_dropdown(selection.index())
                    }
                    dialog:modify{
                        id = "label_labels",
                        options = search.get_all_labels(),
                    }
                    update_bottom_label_view(dialog)
                end
            }
            :newrow()
    end
    function tab_search(dialog)
        local tab_id = "tab_search"
        dialog
            :tab{ id=tab_id, text="Search" }
            :combobox {
                id = "search_labels",
                label = "Existing Labels",
                visible = prefs.last_opened_tab == tab_id,
                options = search.get_all_labels(),
                onchange = function()
                end
            }
            :entry {
                id = 'search_and',
                label = "All of (AND):",
                text = prefs.last_search_and,
                visible = prefs.last_opened_tab == tab_id
            }
            :label {
                id = "search_and_text",
                text = "AND",
                visible = prefs.last_opened_tab == tab_id
            }
            :entry {
                id = "search_or",
                label = "Any of (OR):",
                text = prefs.last_search_or,
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                end
            }
            :label {
                id = "search_term",
                label = "Term",
                text = "num_colors_matches ∧ (a1 ∧ a2 ∧ ... ∧ aN) ∧ (o1 ∨ o2 ∨ ... ∨ oM)",
                visible = prefs.last_opened_tab == tab_id
            }
            :combobox{
                id = "search_num_color_filter",
                label = "Number of Colors",
                visible = prefs.last_opened_tab == tab_id,
                options = search.get_all_color_group_lengths(),
            }
            :button {
                id = "search_start",
                text = "Search",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    local search_and = dialog.data.search_and
                    local search_or = dialog.data.search_or
                    local num_colors = dialog.data.search_num_color_filter
                    search.search(search_and, search_or, num_colors)
                    prefs.last_search_and = search.get_labels_and()
                    prefs.last_search_or = search.get_labels_or()
                    prefs.last_search_num_colors = search.get_labels_or()
                    dialog:modify{ id = "search_and", text = prefs.last_search_and }
                    dialog:modify{ id = "search_or", text = prefs.last_search_or }
                    dialog:modify{ id = "search_num_color_filter", text = prefs.last_search_num_colors }

                    active_page = 1
                    update_selection_page(active_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_bottom_label_view(dialog)
                    update_groups_view(dialog)
                    update_navigation(dialog)
                end
            }
            :button {
                id = "search_clear",
                text = "Clear Search",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    search.clear_search()
                    active_page = 1
                    update_selection_page(active_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_bottom_label_view(dialog)
                    update_groups_view(dialog)
                    update_navigation(dialog)
                end
            }
            :newrow()
    end
    function tab_tools(dialog)
        local tab_id = "tab_tools"
        dialog
            :tab{ id=tab_id, text="Tools" }
            :button{
                id = "tools_pencil",
                label = "Single Color Pencil",
                text = "Select Primary/Secondary Color",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    selected_tool = "tools_pencil"
                    app.tool = "pencil"
                    app.command.SetInkType { type = Ink.SIMPLE }
                end
            }
            :button{
                id = "tools_shading_add",
                label = "Color Group Shading",
                text = "Add to Palette",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    selected_tool = "tools_shading_add"
                    app.tool = "pencil"
                    app.command.SetInkType { type = Ink.SHADING }
                end
            }
            :button{
                id = "tools_shading_replace",
                text = "Replace Palette",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    selected_tool = "tools_shading_replace"
                end
            }
            :newrow()
            :button{
                id = "tools_replace_select",
                label = "Color Group Replace",
                text = "Select <input>/<target> Groups",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    selected_tool = "tools_replace_select"
                end
            }
            :button{
                id = "tools_replace",
                text = "Replace Colors in Selection",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    if not app.sprite then
                        alert_extended.alert_error("Replacing colors is only possible if a sprite is active.")
                        return
                    end
                    if not app.range or app.range.type == RangeType.EMPTY then
                        alert_extended.alert_error({
                            "Nothing is selected.",
                            "First select layers, frames or cels.",
                        })
                        return
                    end
                    if app.sprite.colorMode == ColorMode.RGB then
                        -- continue, this is the mode we want
                    elseif app.sprite.colorMode == ColorMode.GRAY then
                        alert_extended.alert_error("Replacing colors is only implemented for RGBA images. The active sprite is of type 'ColorMode.GRAY'.")
                        return
                    elseif app.sprite.colorMode == ColorMode.INDEXED then
                        alert_extended.alert_error("Replacing colors is only implemented for RGBA images. The active sprite is of type 'ColorMode.INDEXED'.")
                        return
                    elseif app.sprite.colorMode == ColorMode.TILEMAP then
                        alert_extended.alert_error("Replacing colors is only implemented for RGBA images. The active sprite is of type 'ColorMode.TILEMAP'.")
                        return
                    else
                        alert_extended.alert_error("Replacing colors is only implemented for RGBA images. The active sprite is of type unknown.")
                        return
                    end
                    if tool_replace_input_real_index == nil then
                        alert_extended.alert_error("The <input> group must be selected first.")
                        return
                    end
                    if tool_replace_target_real_index == nil then
                        alert_extended.alert_error("The <target> group must be selected first.")
                        return
                    end
                    local group_input = search.get_real_color_group(tool_replace_input_real_index)
                    local group_target = search.get_real_color_group(tool_replace_target_real_index)
                    if #group_input.colors ~= #group_target.colors then
                        alert_extended.alert_error({
                            "The amount of colors in the <input> group must be equal to the amount of colors in the <target> group.",
                            "",
                            "<input> group '" .. group_input.name .. "' has " .. tostring(#group_input.colors) .. " colors.",
                            "<target> group '" .. group_target.name .. "' has " .. tostring(#group_target.colors) .. " colors.",
                        })
                        return
                    end

                    local worked_on_images = {}
                    app.transaction("Aseprite Companion: Replace Colors", function()
                        local target_colors = group_target.colors
                        for_selection_do(function (cel)
                            if cel == nil then
                                return
                            end
                            local image = cel.image
                            if image == nil then
                                return
                            end
                            if search.contains(worked_on_images, image.id) then
                                -- if cells are linked, they share the same image,
                                -- we do not want to swap colors on the same image more than once
                                return
                            end
                            table.insert(worked_on_images, image.id)

                            for px_iter in image:pixels() do
                                local px_32bit = px_iter()
                                local r = app.pixelColor.rgbaR(px_32bit)
                                local g = app.pixelColor.rgbaG(px_32bit)
                                local b = app.pixelColor.rgbaB(px_32bit)
                                local a = app.pixelColor.rgbaA(px_32bit)
                                for i = 1, #group_input.colors do
                                    local from_color = group_input.colors[i]
                                    if from_color.r == r and from_color.g == g and from_color.b == b and from_color.a == a then
                                        local to_color = app.pixelColor.rgba(target_colors[i].r, target_colors[i].g, target_colors[i].b, target_colors[i].a)
                                        px_iter(to_color)
                                    end
                                end
                            end
                        end)
                        app.command.Refresh()
                    end)
                end
            }
            :newrow()
            :button{
                id = "tools_check_pixels",
                label = "Check Selection",
                text = "Check for Stray Colors",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    selected_tool = "tools_check_pixels"
                end
            }
            :newrow()
            :button{
                id = "tools_color_picker",
                label = "Color Picker",
                text = "Add Color on Changed Foreground Color",
                visible = prefs.last_opened_tab == tab_id,
                onclick = function()
                    selected_tool = "tools_color_picker"
                    app.tool = "eyedropper"
                end
            }
            :newrow()
    end
    function tab_color_groups(dialog)
        dialog
            :button {
                id = "sel-prev",
                text = "▲",
                label = "Selection",
                visible = prefs.selection_visible,
                onclick = function()
                    if search.empty() then
                        update_selection_visibility(dialog, false)
                        return
                    end
                    selection.previous()
                    update_selection_visibility(dialog, true)

                    dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                end
            }
            :button {
                id = "sel-next",
                text = "▼",
                visible = prefs.selection_visible,
                onclick = function()
                    if search.empty() then
                        update_selection_visibility(dialog, false)
                        return
                    end
                    selection.next()
                    update_selection_visibility(dialog, true)

                    dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                end
            }

        for i = 1, max_page_size do
            add_color_group_row(dialog, i)
        end

        dialog
            :button {
                id = "nav-first",
                text = "|<",
                label = "Pages",
                enabled = false,
                onclick = function()
                    active_page = 1
                    update_selection_page(active_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_groups_view(dialog)
                    update_navigation(dialog)
                    update_bottom_label_view(dialog)
                    dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                end
            }
            :button {
                id = "nav-prev-fast",
                text = "<<",
                enabled = false,
                onclick = function()
                    active_page = active_page - fast_forward_pages
                    if active_page < 1 then
                        active_page = 1
                    end
                    update_selection_page(active_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_groups_view(dialog)
                    update_navigation(dialog)
                    update_bottom_label_view(dialog)
                    dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                end
            }
            :button {
                id = "nav-prev",
                text = "<",
                enabled = false,
                onclick = function()
                    if active_page > 1 then
                        active_page = active_page - 1
                    end
                    update_selection_page(active_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_groups_view(dialog)
                    update_navigation(dialog)
                    update_bottom_label_view(dialog)
                    dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                end
            }
            :button {
                id = "nav-pos",
                text = "" .. active_page,
                selected = false,
                enabled = false
            }
            :button {
                id = "nav-next",
                text = ">",
                onclick = function()
                    if active_page < last_page then
                        active_page = active_page + 1
                    end
                    update_selection_page(active_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_groups_view(dialog)
                    update_navigation(dialog)
                    update_bottom_label_view(dialog)
                    dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                end
            }
            :button {
                id = "nav-next-fast",
                text = ">>",
                onclick = function()
                    active_page = active_page + fast_forward_pages
                    if active_page > last_page then
                        active_page = last_page
                    end
                    update_selection_page(active_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_groups_view(dialog)
                    update_navigation(dialog)
                    update_bottom_label_view(dialog)
                    dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                end
            }
            :button {
                id = "nav-last",
                text = ">|",
                onclick = function()
                    active_page = last_page
                    update_selection_page(active_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_groups_view(dialog)
                    update_navigation(dialog)
                    update_bottom_label_view(dialog)
                    dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                end
            }
    end

    init_globals(plugin)

    local dialog = Dialog {
        title = dialog_title,
        onclose = fn_on_close,
    }
    tab_view(dialog)
    tab_save_load(dialog)
    tab_edit_mode(dialog)
    tab_labels(dialog)
    tab_search(dialog)
    tab_tools(dialog)

    dialog:endtabs{
        id="tab_end",
        selected=prefs.last_opened_tab,
        align=Align.CENTER|Align.TOP,
        onchange=function(ev)
            prefs.last_opened_tab = ev.tab

            update_view_visibility(dialog, ev.tab == "tab_view")
            update_edit_mode_visibility(dialog, ev.tab == "tab_edit_mode")
            update_save_load_visibility(dialog, ev.tab == "tab_save_load")
            update_label_visibility(dialog, ev.tab == "tab_label")
            update_search_visibility(dialog, ev.tab == "tab_search")
            update_tools_visibility(dialog, ev.tab == "tab_tools")

            if ev.tab == "tab_label" then
                dialog:modify{ id = "label_labels", options = search.get_all_labels() }
                if not search.empty() then
                    dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                end
            end

            if ev.tab == "tab_search" then
                dialog:modify{ id = "search_labels", options = search.get_all_labels() }
                dialog:modify{ id = "search_num_color_filter", options = search.get_all_color_group_lengths() }
            end
        end
    }

    tab_color_groups(dialog)

    update_page_widgets_visibility(dialog)
    update_groups_view(dialog)
    update_selection_visibility(dialog, prefs.selection_visible)
    update_bottom_label_view(dialog)

    return dialog, function()
        if selected_tool ~= "tools_color_picker" then
            return
        end
        if search.empty() then
            return
        end
        local color_group_color = search.get_color_group(selection.index()).colors
        table.insert(color_group_color, {r=app.fgColor.red, g=app.fgColor.green, b=app.fgColor.blue, a=app.fgColor.alpha})
        save_prefs()
        update_groups_view(dialog)
        dialog:modify{ id = "search_num_color_filter", options = search.get_all_color_group_lengths() }
    end
end