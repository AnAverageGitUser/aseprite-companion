table_extended = dofile("../shared/table-extended.lua")
file_extended = dofile("../shared/file-extended.lua")
alert_extended = dofile("../shared/alert-extended.lua")
color_groups_pages = dofile("./pages.lua")
selection = dofile("./entry-selection.lua")
search = dofile("./search.lua")

local plugin_prefs
local last_page
local current_label_dropdown_data = {}
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
    version = "2.0.0",
    last_save_file = "",
    last_search_and = "",
    last_search_or = "",
    num_color_groups_per_page = 10,
    selection_visible = true,
    labels_visible = true,
    color_groups = create_color_groups(num_color_groups),
}

function get_color_group_labels_for_dropdown(index)
    local color_group = search.get_color_group(index)

    while #current_label_dropdown_data ~= 0 do
        table.remove(current_label_dropdown_data, #current_label_dropdown_data)
    end

    if #color_group.labels == 0 then
        table.insert(current_label_dropdown_data, "[ NO LABEL ]")
    end

    local tbl = {}
    for j = 1, #color_group.labels do
        local val = color_group.labels[j]
        if val ~= nil then
            table.insert(tbl, val)
        end
    end

    return tbl
end


local quick_guide_text = {
    "--- Mode ---",
    "Select the group to edit.",
    "[Add Colors] Adds selected color/s from palette to the selected group.",
    "[Clear Colors] Clears all colors from selected group.",
    "[Rename] Change the selected group name to the {Group Name} entry.",
    "[Save] Saves with {File Name} entry.",
    "[Load] Loads the {File Name} entry.",
    "[Open Folder] Open your color groups folder. Useful to get an existing file name to load.",
    "--- Groups ---",
    "Simply click any color to set it as the foreground color.",
    "[Refresh] Refresh all the groups colors. Useful if palette was modified.",
    "[Prev] [Next] Cycle color groups pages.",
}

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
    plugin_prefs.num_color_groups_per_page = prefs.num_color_groups_per_page
    plugin_prefs.selection_visible = prefs.selection_visible
    plugin_prefs.labels_visible = prefs.labels_visible
    plugin_prefs.color_groups = json.encode(prefs.color_groups)
end
function save_color_groups(name)
    local path = groups_folder_path .. name .. ".json"
    if name == "" then
        alert_extended.alert_error{
            "File Name entry is empty.",
            "Please specify a name."
        }
        return
    end

    if file_extended.file_exists(path) then
        local result = app.alert{
            title = "Aseprite Companion: Overwrite file?",
            text = {
                "A file with the same name already exists.",
                "The file in question:",
                "" .. path,
                "",
                "Do you want to overwrite this file?"
            },
            buttons = { "Yes: Overwrite File", "No" }
        }
        if result ~= 1 then
            return
        end
    end

    os.execute("mkdir " .. groups_folder_path)
    table_extended.save(prefs.color_groups, path)
    alert_extended.alert_info{
        "Saved file successfully to:",
        "" .. path
    }
end
function load_color_groups(name, dialog)
    local path = groups_folder_path .. name .. ".json"
    if file_extended.file_exists(path) then
        if not is_default_table_in_memory() then
            local result = app.alert{
                title = "Aseprite Companion: Load file?",
                text = {
                    "The currently loaded color groups will be discarded and replaced by the loaded file.",
                    "Maybe you want to save the current color groups first.",
                    "",
                    "Do you want to load the file and replace the current color groups?"
                },
                buttons = { "Yes: Load File", "No" }
            }
            if result ~= 1 then
                return
            end
        end

        active_page = 1
        prefs.color_groups = table_extended.load(path)
        search.set_color_groups(prefs.color_groups)
        search.clear_search()
        selection.set_range(1, prefs.num_color_groups_per_page)
        update_bottom_label_view(dialog)
        update_groups_view(dialog)
    else
        alert_extended.alert_error{
            "Trying to load non existent file:",
            "" .. path,
            "",
            "Please specify an existing file name. You may use [Open Folder] to find the file name."
        }
    end
end
function prepare_preferences(plugin_p)
    if plugin_p.preferences.color_group_dialog == nil
        or plugin_p.preferences.color_group_dialog.version == nil
        or plugin_p.preferences.color_group_dialog.version ~= prefs.version
    then
        plugin_p.preferences.color_group_dialog = {}
        plugin_prefs = plugin_p.preferences.color_group_dialog
        save_prefs()
    else
        plugin_prefs = plugin_p.preferences.color_group_dialog
    end

    prefs.version = plugin_prefs.version
    prefs.last_save_file = plugin_prefs.last_save_file
    prefs.last_search_and = plugin_prefs.last_search_and
    prefs.last_search_or = plugin_prefs.last_search_or
    prefs.num_color_groups_per_page = plugin_prefs.num_color_groups_per_page
    prefs.selection_visible = plugin_prefs.selection_visible
    prefs.labels_visible = plugin_prefs.labels_visible
    prefs.color_groups = json.decode(plugin_prefs.color_groups)

    last_page = math.tointeger((num_color_groups + prefs.num_color_groups_per_page - 1) / prefs.num_color_groups_per_page)
    selection.set_range(1, prefs.num_color_groups_per_page)
    search.set_color_groups(prefs.color_groups)
    search.clear_search()
end

function update_groups_view(dialog)
    last_page = math.tointeger((search.num_results() + prefs.num_color_groups_per_page - 1) / prefs.num_color_groups_per_page)

    update_navigation(dialog)

    local selection_enabled = not search.empty()
    dialog:modify { id = "sel-prev", enabled = selection_enabled }
    dialog:modify { id = "sel-next", enabled = selection_enabled }

    color_groups_pages(dialog, prefs.num_color_groups_per_page, search, active_page)
end

function update_guide_visibility(dialog, visible)
    for i = 1, #quick_guide_text do
        dialog:modify{ id="guide"..tostring(i), visible=visible }
    end
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
    dialog:modify{ id="search_start", visible=visible }
    dialog:modify{ id="search_clear", visible=visible }
    dialog:modify{ id="search_term", visible=visible }
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

function update_selection_page(active_page_num)
    selection.set_range(
        prefs.num_color_groups_per_page * (active_page_num - 1) + 1,
        math.min(prefs.num_color_groups_per_page * active_page_num, search.num_results())
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
                if ev.button == MouseButton.LEFT then
                    app.fgColor = ev.color
                elseif ev.button == MouseButton.RIGHT then
                    app.bgColor = ev.color
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

return function(plugin, dialog_title, fn_on_close)
    function tab_guide(dialog)
        dialog:tab{ id="tab_guide", text="Guide" }
        for i = 1, #quick_guide_text do
            dialog
                :newrow()
                :label{ id="guide"..tostring(i), text = quick_guide_text[i], visible=false }
        end
    end
    function tab_view(dialog)
        dialog
            :tab{ id="tab_view", text="View" }
            :button{
                id = "view_groups_less",
                label = "Groups per Page",
                text = "<",
                visible = false,
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
                visible = false,
                enabled = false,
            }
            :button{
                id = "view_groups_more",
                text = ">",
                visible = false,
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
                visible = false,
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
                visible = false,
                onclick = function()
                    prefs.labels_visible = not prefs.labels_visible
                    save_prefs()
                    update_bottom_label_view(dialog)
                end
            }
            :newrow()
    end
    function tab_save_load(dialog)
        dialog
            :tab{ id="tab_save_load", text="Save/Load" }
            :entry {
                id = 'save_load_filename',
                label = "File Name",
                text = prefs.last_save_file
            }
            :button {
                id = "save_load_save",
                text = "Save",
                selected = false,
                focus = false,
                onclick = function()
                    local file = dialog.data.save_load_filename
                    prefs.last_save_file = file
                    save_prefs()

                    save_color_groups(file)
                end
            }
            :button {
                id = "save_load_load",
                text = "Load",
                selected = false,
                focus = false,
                onclick = function()
                    local file = dialog.data.save_load_filename
                    prefs.last_save_file = file
                    save_prefs()

                    load_color_groups(file, dialog)

                    dialog:modify{
                        id = "label_labels_dropdown",
                        options = get_color_group_labels_for_dropdown(selection.index())
                    }
                end
            }
            :button {
                id = "save_load_open_folder",
                text = "Open Folder",
                selected = false,
                focus = false,
                onclick = function()
                    os.execute("start " .. groups_folder_path)
                end
            }
            :newrow()
            :button {
                id = "save_load_reset_all_groups",
                text = "Reset All Loaded Color Groups",
                selected = false,
                focus = false,
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
                    active_page = 1
                    prefs.color_groups = create_color_groups(num_color_groups)
                    search.set_color_groups(prefs.color_groups)
                    search.clear_search()
                    selection.set_range(1, prefs.num_color_groups_per_page)
                    update_bottom_label_view(dialog)
                    update_groups_view(dialog)
                end
            }
    end
    function tab_edit_mode(dialog)
        dialog
                :tab{ id="tab_edit_mode", text="Edit Groups" }
                :entry {
            id = "edit_mode_group_name",
            label = "Group Name",
            onclick = function()
            end
        }
        :button {
            id = "edit_mode_rename",
            text = "Rename Group",
            selected = false,
            focus = false,
            onclick = function()
                if search.empty() then
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
            onclick = function()
                if not app.sprite or search.empty() then
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
            end
        }
        :button {
            id = "edit_mode_clear_colors",
            text = "Clear Colors",
            onclick = function()
                if search.empty() then
                    return
                end
                local group_idx = selection.index()
                local color_group = search.get_color_group(group_idx)
                color_group.colors = {}
                save_prefs()
                update_groups_view(dialog)
            end
        }
    end
    function tab_labels(dialog)
        dialog
            :tab{ id="tab_label", text="Label" }
            :combobox {
                id = "label_labels",
                label = "Existing Labels",
                visible = false,
                options = search.get_color_group(1).labels,
            }
            :entry {
                id = 'label_input',
                label = "Add Label",
                visible = false,
            }
            :button {
                id = "label_add",
                text = "Add",
                visible = false,
                onclick = function()
                    if search.empty() then
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
                visible = false,
                options = prefs.color_groups[1].labels
            }
            :button {
                id = "label_remove",
                text = "Remove",
                visible = false,
                onclick = function()
                    if search.empty() then
                        return
                    end
                    local label = dialog.data.label_labels_dropdown
                    if label == nil or label == "" then
                        return
                    end
                    local group_idx = selection.index()
                    local color_group = search.get_color_group(group_idx)
                    for i=1, #color_group.labels do
                        if color_group.labels[i] == label then
                            table.remove(color_group.labels, i)
                            save_prefs()
                            break -- assume labels are not duplicate
                        end
                    end
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
    end
    function tab_search(dialog)
        dialog
            :tab{ id="tab_search", text="Search" }
            :combobox {
                id = "search_labels",
                label = "Existing Labels",
                visible = false,
                options = {},
                onchange = function()
                end
            }
            :entry {
                id = 'search_and',
                label = "All of (AND):",
                text = prefs.last_search_and,
                visible = false
            }
            :label {
                id = "search_and_text",
                text = "AND",
                visible = false
            }
            :entry {
                id = "search_or",
                label = "Any of (OR):",
                text = prefs.last_search_or,
                visible = false,
                onclick = function()
                end
            }
            :label {
                id = "search_term",
                label = "Term",
                text = "(a1 ∧ a2 ∧ ... ∧ aN) ∧ (o1 ∨ o2 ∨ ... ∨ oM)",
                visible = false
            }
            :button {
                id = "search_start",
                text = "Search",
                visible = false,
                onclick = function()
                    local search_and = dialog.data.search_and
                    local search_or = dialog.data.search_or
                    search.search(search_and, search_or)
                    prefs.last_search_and = search.get_labels_and()
                    prefs.last_search_or = search.get_labels_or()
                    dialog:modify{ id = "search_and", text = prefs.last_search_and }
                    dialog:modify{ id = "search_or", text = prefs.last_search_or }

                    selection.set_range(1, math.min(prefs.num_color_groups_per_page, math.max(search.num_results(), 1)))
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_bottom_label_view(dialog)
                    update_groups_view(dialog)
                    update_navigation(dialog)
                end
            }
            :button {
                id = "search_clear",
                text = "Clear Search",
                visible = false,
                onclick = function()
                    search.clear_search()
                    selection.set_range(1, prefs.num_color_groups_per_page)
                    update_selection_visibility(dialog, prefs.selection_visible)
                    update_bottom_label_view(dialog)
                    update_groups_view(dialog)
                    update_navigation(dialog)
                end
            }
    end
    function tab_tools(dialog)
        dialog
            :tab{ id="tab_tools", text="Tools" }
            :button{ visible = false }
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

    prepare_preferences(plugin)

    local dialog = Dialog {
        title = dialog_title,
        onclose = fn_on_close,
    }
    tab_guide(dialog)
    tab_view(dialog)
    tab_save_load(dialog)
    tab_edit_mode(dialog)
    tab_labels(dialog)
    tab_search(dialog)
    tab_tools(dialog)

    dialog:endtabs{
        id="tab_end",
        selected="tab_edit_mode",
        align=Align.CENTER|Align.TOP,
        onchange=function(ev)
            update_guide_visibility(dialog, ev.tab == "tab_guide")
            update_view_visibility(dialog, ev.tab == "tab_view")
            update_edit_mode_visibility(dialog, ev.tab == "tab_edit_mode")
            update_save_load_visibility(dialog, ev.tab == "tab_save_load")
            update_label_visibility(dialog, ev.tab == "tab_label")
            update_search_visibility(dialog, ev.tab == "tab_search")

            if ev.tab == "tab_label" then
                dialog:modify{ id = "label_labels", options = search.get_all_labels() }
                if not search.empty() then
                    dialog:modify{ id = "label_labels_dropdown", options = get_color_group_labels_for_dropdown(selection.index()) }
                end
            end

            if ev.tab == "tab_search" then
                dialog:modify{ id = "search_labels", options = search.get_all_labels() }
            end
        end
    }

    tab_color_groups(dialog)

    update_page_widgets_visibility(dialog)
    update_groups_view(dialog)
    update_selection_visibility(dialog, prefs.selection_visible)
    update_bottom_label_view(dialog)

    return dialog
end