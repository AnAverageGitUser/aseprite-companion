table_extended = dofile("../shared/table-extended.lua")
file_extended = dofile("../shared/file-extended.lua")
color_groups_pages = dofile("./color-groups-pages.lua")
alert_extended = dofile("../shared/alert-extended.lua")

local groups_folder_path = app.fs.userConfigPath .. "groups\\"

local dialogbounds
local fast_forward_pages = 5
local active_page = 1

local selected_group_index = 1
local num_color_groups_per_page = 10
local num_color_groups = 300
local last_page = math.tointeger((num_color_groups + num_color_groups_per_page - 1) / num_color_groups_per_page)

function create_color_groups(num_table_entries)
    local color_groups = {}
    for i = 1, num_table_entries do
        color_groups[i] = {}
        color_groups[i].name = "Group " .. tostring(i)
        color_groups[i].colors = {}
    end
    return color_groups
end
local color_groups = create_color_groups(num_color_groups)

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

function get_page_first_group_idx()
    return num_color_groups_per_page * (active_page - 1) + 1
end
function get_page_last_group_idx()
    return num_color_groups_per_page * active_page
end
function get_dropdown_index(selected_string)
    local colon_index = selected_string:find(":", 6, true) -- plain substring search for ':' after "Slot "
    local substr = selected_string:sub(6, colon_index - 1) -- cut out between "Slot " and ":"
    return math.tointeger(substr)
end
function get_dropdown_table_index(selected_string)
    local page_start_index = get_page_first_group_idx()
    local drop_idx = get_dropdown_index(selected_string)
    return drop_idx + page_start_index - 1
end

function get_dropdown_options()
    local page_start_index = get_page_first_group_idx()
    local page_end_index = get_page_last_group_idx()

    local options = {}
    local widget_index = 1
    for i = page_start_index, page_end_index do
        if i <= #color_groups then
            table.insert(options, "Slot " .. tostring(widget_index) .. ": " .. color_groups[i].name)
        else
            break
        end
        widget_index = widget_index + 1
    end
    return options
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
            buttons = { "Yes", "No" }
        }
        if result ~= 1 then
            return
        end
    end

    os.execute("mkdir " .. groups_folder_path)
    table_extended.save(color_groups, path)
    alert_extended.alert_info{
        "Saved file successfully to:",
        "" .. path
    }
end

function load_color_groups(name)
    local path = groups_folder_path .. name .. ".json"
    if file_extended.file_exists(path) then
        color_groups = table_extended.load(path)
    else
        alert_extended.alert_error{
            "Trying to load non existent file:",
            "" .. path,
            "",
            "Please specify an existing file name. You may use [Open Folder] to find the file name."
        }
    end
end

function update_groups_view(dialog)
    color_groups_pages(dialog, num_color_groups_per_page, color_groups, active_page, get_dropdown_options, selected_group_index, last_page)
end

function update_guide_visibility(dialog, visible)
    for i = 1, #quick_guide_text do
        dialog:modify{ id="guide"..tostring(i), visible=visible }
    end
end
function update_edit_mode_visibility(dialog, visible)
    dialog:modify{ id="edit_mode_groups_dropdown", visible=visible }
    dialog:modify{ id="edit_mode_clear_colors", visible=visible }
    dialog:modify{ id="edit_mode_add_colors", visible=visible }
    dialog:modify{ id="edit_mode_rename", visible=visible }
end
function update_save_load_visibility(dialog, visible)
    dialog:modify{ id="save_load_filename", visible=visible }
    dialog:modify{ id="save_load_save", visible=visible }
    dialog:modify{ id="save_load_load", visible=visible }
    dialog:modify{ id="save_load_open_folder", visible=visible }
end

function create_dialog(dialog_title)
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
            :combobox {
                id = "edit_mode_groups_dropdown",
                label = "Selected Group",
                option = nil,
                options = get_dropdown_options(color_groups),
                onchange = function()
                    selected_group_index = get_dropdown_table_index(dialog.data.edit_mode_groups_dropdown)
                end
            }
            :button {
                id = "edit_mode_add_colors",
                text = "Add Colors",
                selected = false,
                focus = false,
                onclick = function()
                    local data = dialog.data
                    local group_idx = get_dropdown_table_index(data.edit_mode_groups_dropdown)
                    local selectedColors = app.range.colors
                    local palette = app.sprite.palettes[1]
                    for j = 1, #selectedColors do
                        local color = palette:getColor(selectedColors[j])
                        table.insert(color_groups[group_idx].colors, {
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
                    local data = dialog.data
                    local group_idx = get_dropdown_table_index(data.edit_mode_groups_dropdown)
                    color_groups[group_idx].colors = {}
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
                    local data = dialog.data
                    if data.edit_mode_group_name ~= "" then
                        local group_idx = get_dropdown_table_index(data.edit_mode_groups_dropdown)
                        color_groups[group_idx].name = data.edit_mode_group_name
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
                focus = boolean,
                onclick = function()
                end
            }
            :button {
                id = "save_load_save",
                text = "Save",
                selected = false,
                focus = false,
                onclick = function()
                    local data = dialog.data
                    save_color_groups(data.filename)
                end
            }
            :button {
                id = "save_load_load",
                text = "Load",
                selected = false,
                focus = false,
                onclick = function()
                    local data = dialog.data
                    load_color_groups(data.filename)
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

        dialog
            :button {
                id = "nav-first",
                text = "|<",
                selected = false,
                focus = false,
                onclick = function()
                    selected_group_index = 1
                    if active_page ~= 1 then
                        active_page = 1
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
                    selected_group_index = 1
                    active_page = active_page - fast_forward_pages
                    if active_page < 1 then
                        active_page = 1
                    end
                    update_groups_view(dialog)
                end
            }
            :button {
                id = "nav-prev",
                text = "<",
                selected = false,
                focus = false,
                onclick = function()
                    selected_group_index = 1
                    if active_page > 1 then
                        active_page = active_page - 1
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
                    selected_group_index = 1
                    if active_page < last_page then
                        active_page = active_page + 1
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
                    selected_group_index = 1
                    active_page = active_page + fast_forward_pages
                    if active_page > last_page then
                        active_page = last_page
                    end
                    update_groups_view(dialog)
                end
            }
            :button {
                id = "nav-last",
                text = ">|",
                selected = false,
                focus = false,
                onclick = function()
                    selected_group_index = 1
                    if active_page ~= last_page then
                        active_page = last_page
                        update_groups_view(dialog)
                    end
                end
            }
    end

    local dialog = Dialog(dialog_title)
    tab_guide(dialog)
    tab_edit_mode(dialog)
    tab_save_load(dialog)

    dialog:endtabs{
        id="tab_end",
        selected="tab_edit_mode",
        align=Align.CENTER|Align.TOP,
        onchange=function(ev)
            update_guide_visibility(dialog, ev.tab == "tab_guide")
            update_edit_mode_visibility(dialog, ev.tab == "tab_edit_mode")
            update_save_load_visibility(dialog, ev.tab == "tab_save_load")
        end
    }

    tab_color_groups(dialog)
    update_groups_view(dialog)

    return dialog
end

return function(dialog_title)
    local dialog = create_dialog(dialog_title)

    dialog:show {
        wait = false,
        bounds = dialogbounds
    }
    return dialog
end