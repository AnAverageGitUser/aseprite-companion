table_extended = dofile("../shared/table-extended.lua")
file_extended = dofile("../shared/file-extended.lua")
color_groups_pages = dofile("./color-groups-pages.lua")
alert_extended = dofile("../shared/alert-extended.lua")
selection = dofile("../color-groups/color-groups-entry-selection.lua")

local groups_folder_path = app.fs.userConfigPath .. "groups\\"

local fast_forward_pages = 5
local active_page = 1

local num_color_groups_per_page = 10
local num_color_groups = 300
local last_page = math.tointeger((num_color_groups + num_color_groups_per_page - 1) / num_color_groups_per_page)
selection.set_range(1, num_color_groups_per_page)

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
    color_groups = nil,
}

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
            buttons = { "Yes", "No" }
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
function load_color_groups(name)
    local path = groups_folder_path .. name .. ".json"
    if file_extended.file_exists(path) then
        prefs.color_groups = table_extended.load(path)
    else
        alert_extended.alert_error{
            "Trying to load non existent file:",
            "" .. path,
            "",
            "Please specify an existing file name. You may use [Open Folder] to find the file name."
        }
    end
end
function prepare_preferences(plugin)
    if plugin.preferences.color_group_dialog == nil then
        plugin.preferences.color_group_dialog = prefs
    elseif plugin.preferences.color_group_dialog.version ~= prefs.version then
        plugin.preferences.color_group_dialog = prefs
    else
        prefs = plugin.preferences.color_group_dialog
    end

    if prefs.color_groups == nil then
        prefs.color_groups = create_color_groups(num_color_groups)
    end
end

function update_groups_view(dialog)
    color_groups_pages(dialog, num_color_groups_per_page, prefs.color_groups, active_page)
end

function get_all_labels()
    local tbl = {}
    for i=1, #prefs.color_groups do
        local color_group = prefs.color_groups[i]
        for j=1, #color_group.labels do
            local label = color_group.labels[j]
            for k=1, #tbl do
                if tbl[k] == label then
                    goto skip_this_label
                end
            end
            table.insert(tbl, label)
            ::skip_this_label::
        end
    end
    return tbl
end

function update_guide_visibility(dialog, visible)
    for i = 1, #quick_guide_text do
        dialog:modify{ id="guide"..tostring(i), visible=visible }
    end
end
function update_edit_mode_visibility(dialog, visible)
    dialog:modify{ id="edit_mode_clear_colors", visible=visible }
    dialog:modify{ id="edit_mode_add_colors", visible=visible }
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
end
function update_selection_visibility(dialog, visible)
    hide_selection(dialog)
    if visible then
        local active_index = selection.offset() + 1
        dialog
            :modify { id = "ShadeSeparatorTop" .. tostring(active_index), visible = true }
            :modify { id = "ShadeSeparatorBottom" .. tostring(active_index), visible = true }
    end
end

function hide_selection(dialog)
    for i = 1, num_color_groups_per_page do
        dialog
            :modify { id = "ShadeSeparatorTop" .. tostring(i), visible = false }
            :modify { id = "ShadeSeparatorBottom" .. tostring(i), visible = false }
    end
end
function update_selection_page(active_page_num)
    selection.set_range(
        num_color_groups_per_page * (active_page_num - 1) + 1,
        num_color_groups_per_page * active_page_num
    )
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
    function tab_edit_mode(dialog)
        dialog
            :tab{ id="tab_edit_mode", text="Edit Groups" }
            :button {
                id = "edit_mode_add_colors",
                text = "Add Colors",
                selected = false,
                focus = false,
                onclick = function()
                    if not app.sprite then
                        return
                    end

                    local group_idx = selection.index()
                    local selectedColors = app.range.colors
                    local palette = app.sprite.palettes[1]
                    for j = 1, #selectedColors do
                        local color = palette:getColor(selectedColors[j])
                        table.insert(prefs.color_groups[group_idx].colors, {
                            r = color.red,
                            g = color.green,
                            b = color.blue,
                            a = color.alpha,
                        })
                    end
                    update_groups_view(dialog)
                end
            }
            :button {
                id = "edit_mode_clear_colors",
                text = "Clear Colors",
                selected = false,
                focus = false,
                onclick = function()
                    local group_idx = selection.index()
                    prefs.color_groups[group_idx].colors = {}
                    update_groups_view(dialog)
                end
            }
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
                    local edit_mode_group_name = dialog.data.edit_mode_group_name
                    if edit_mode_group_name ~= "" then
                        local group_idx = selection.index()
                        prefs.color_groups[group_idx].name = edit_mode_group_name
                    end
                    update_groups_view(dialog)
                end
            }
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
                    load_color_groups(file)
                    update_groups_view(dialog)
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
                    prefs.color_groups = create_color_groups(num_color_groups)
                    update_groups_view(dialog)
                end
            }
    end
    function tab_labels(dialog)
        dialog
            :tab{ id="tab_label", text="Label" }
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
                    local label = dialog.data.label_input
                    if label == "" then
                        return
                    end
                    local group_idx = selection.index()
                    for i=1, #prefs.color_groups[group_idx].labels do
                        if prefs.color_groups[group_idx].labels[i] == label then
                            return -- no duplicates
                        end
                    end
                    table.insert(prefs.color_groups[group_idx].labels, label)
                    dialog:modify{
                        id = "label_labels_dropdown",
                        option = label,
                        options = prefs.color_groups[group_idx].labels
                    }
                end
            }
            :combobox {
                id = "label_labels_dropdown",
                label = "Remove Label",
                visible = false,
                option = nil,
                options = prefs.color_groups[1].labels
            }
            :button {
                id = "label_remove",
                text = "Remove",
                visible = false,
                onclick = function()
                    local label = dialog.data.label_labels_dropdown
                    if label == nil or label == "" then
                        return
                    end
                    local group_idx = selection.index()
                    for i=1, #prefs.color_groups[group_idx].labels do
                        if prefs.color_groups[group_idx].labels[i] == label then
                            table.remove(prefs.color_groups[group_idx].labels, i)
                            break -- assume labels are not duplicate
                        end
                    end
                    dialog:modify{
                        id = "label_labels_dropdown",
                        option = label,
                        options = prefs.color_groups[group_idx].labels
                    }
                end
            }
    end
    function tab_search(dialog)
        dialog
            :tab{ id="tab_search", text="Label Search" }
            :combobox {
                id = "search_labels",
                label = "Available Labels",
                visible = false,
                options = {},
                onchange = function()
                end
            }
            :entry {
                id = 'search_and',
                label = "All of (AND):",
                visible = false
            }
            :label {
                id = "search_and_text",
                label = "AND",
                visible = false
            }
            :entry {
                id = "search_or",
                label = "Any of (OR):",
                visible = false,
                onclick = function()
                end
            }
            :button {
                id = "search_start",
                text = "Search",
                visible = false,
                onclick = function()
                end
            }
            :button {
                id = "search_clear",
                text = "Clear Search",
                visible = false,
                onclick = function()
                end
            }
    end
    function tab_color_groups(dialog)
        function get_shade_color_table(tbl)
            local shade_table = {}
            for i = 1, #tbl do
                local color = tbl[i]
                table.insert(shade_table, Color{ r=color.r, g=color.g, b=color.b, a=color.a })
            end
            return shade_table
        end

        dialog
            :button {
                id = "sel-prev",
                text = "▲",
                label = "Selection",
                onclick = function()
                    selection.previous()
                    update_selection_visibility(dialog, true)
                    dialog:modify{
                        id = "label_labels_dropdown",
                        options = prefs.color_groups[selection.index()].labels
                    }
                end
            }
            :button {
                id = "sel-next",
                text = "▼",
                onclick = function()
                    selection.next()
                    update_selection_visibility(dialog, true)
                    dialog:modify{
                        id = "label_labels_dropdown",
                        options = prefs.color_groups[selection.index()].labels
                    }
                end
            }

        for i = 1, num_color_groups_per_page do
            dialog
                :label { id = "ShadeSeparatorTop" .. tostring(i), label = " ▼▼▼ ", text = " ▼▼▼ Selected ▼▼▼", visible = false }
                :shades {
                    id = "Shade" .. tostring(i),
                    label = prefs.color_groups[i].name,
                    mode = "pick",
                    colors = get_shade_color_table(prefs.color_groups[i].colors),
                    onclick = function(ev)
                        if ev.button == MouseButton.LEFT then
                            app.fgColor = ev.color
                        elseif ev.button == MouseButton.RIGHT then
                            app.bgColor = ev.color
                        end
                    end
                }
                :label { id = "ShadeSeparatorBottom" .. tostring(i), label = " ▲▲▲ ", text = " ▲▲▲ Selected ▲▲▲", visible = false }
        end

        dialog
            :button {
                id = "nav-first",
                text = "|<",
                label = "Pages",
                selected = false,
                focus = false,
                onclick = function()
                    if active_page ~= 1 then
                        active_page = 1
                        update_selection_page(active_page)
                        update_groups_view(dialog)
                    end
                end
            }
            :button {
                id = "nav-prev-fast",
                text = "<<",
                selected = false,
                focus = false,
                onclick = function()
                    active_page = active_page - fast_forward_pages
                    if active_page < 1 then
                        active_page = 1
                    end
                    update_selection_page(active_page)
                    update_groups_view(dialog)
                end
            }
            :button {
                id = "nav-prev",
                text = "<",
                selected = false,
                focus = false,
                onclick = function()
                    if active_page > 1 then
                        active_page = active_page - 1
                        update_selection_page(active_page)
                        update_groups_view(dialog)
                    end
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
                selected = false,
                focus = false,
                onclick = function()
                    if active_page < last_page then
                        active_page = active_page + 1
                        update_selection_page(active_page)
                        update_groups_view(dialog)
                    end
                end
            }
            :button {
                id = "nav-next-fast",
                text = ">>",
                selected = false,
                focus = false,
                onclick = function()
                    active_page = active_page + fast_forward_pages
                    if active_page > last_page then
                        active_page = last_page
                    end
                    update_selection_page(active_page)
                    update_groups_view(dialog)
                end
            }
            :button {
                id = "nav-last",
                text = ">|",
                selected = false,
                focus = false,
                onclick = function()
                    if active_page ~= last_page then
                        active_page = last_page
                        update_selection_page(active_page)
                        update_groups_view(dialog)
                    end
                end
            }
    end

    prepare_preferences(plugin)

    local dialog = Dialog {
        title = dialog_title,
        onclose = fn_on_close,
    }
    tab_guide(dialog)
    tab_edit_mode(dialog)
    tab_save_load(dialog)
    tab_labels(dialog)
    tab_search(dialog)

    dialog:endtabs{
        id="tab_end",
        selected="tab_edit_mode",
        align=Align.CENTER|Align.TOP,
        onchange=function(ev)
            update_guide_visibility(dialog, ev.tab == "tab_guide")
            update_edit_mode_visibility(dialog, ev.tab == "tab_edit_mode")
            update_save_load_visibility(dialog, ev.tab == "tab_save_load")
            update_label_visibility(dialog, ev.tab == "tab_label")
            update_search_visibility(dialog, ev.tab == "tab_search")

            if ev.tab == "tab_search" then
                dialog:modify{ id = "search_labels", options = get_all_labels() }
            end

            update_selection_visibility(dialog, ev.tab ~= "tab_search")
            dialog:modify{ id = "sel-prev", enabled = ev.tab ~= "tab_search", visible = ev.tab ~= "tab_search" }
            dialog:modify{ id = "sel-next", enabled = ev.tab ~= "tab_search", visible = ev.tab ~= "tab_search" }
        end
    }

    tab_color_groups(dialog)
    update_groups_view(dialog)
    update_selection_visibility(dialog, true)

    return dialog
end