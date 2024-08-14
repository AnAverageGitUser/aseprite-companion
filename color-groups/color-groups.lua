table_extended = dofile("../shared/table-extended.lua")
file_extended = dofile("../shared/file-extended.lua")
color_groups_widget = dofile("./color-groups-widget.lua")
color_groups_pages = dofile("./color-groups-pages.lua")
alert_extended = dofile("../shared/alert-extended.lua")

local groups_folder_path = app.fs.userConfigPath .. "groups\\"

local dialogbounds
local fast_forward_pages = 5
local active_page = 1
local edit_mode_visible = true

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

function show_groups_dialog()
    local colorgroupsdlg = colorgroupsdialog("Color Groups")
    set_edit_group_visibility(colorgroupsdlg, edit_mode_visible)
    colorgroupsdlg:show { wait = false, bounds = dialogbounds }
end

function update_groups_dialog(dialog)
    color_groups_pages(dialog, num_color_groups_per_page, color_groups, active_page, get_dropdown_options, selected_group_index)
end

function set_edit_group_visibility(dialog, visible)
    edit_mode_visible = visible
    local text = ""
    if visible == true then
        text = "Disable Edit Groups Mode"
    else
        text = "Enable Edit Groups Mode"
    end
    dialog:modify { id = "modebutton", text = text }
    dialog:modify { id = "groupsdropdown", visible = visible }
    dialog:modify { id = "addcolors", visible = visible }
    dialog:modify { id = "clearcolors", visible = visible }
    dialog:modify { id = "groupname", visible = visible }
    dialog:modify { id = "renamebutton", visible = visible }
    dialog:modify { id = "filename", visible = visible }
    dialog:modify { id = "save", visible = visible }
    dialog:modify { id = "load", visible = visible }
    dialog:modify { id = "openpathfolder", visible = visible }
end

function create_color_groups_dialog(dialog)
    dialog
        :separator {
            text = "Mode"
        }
        :button {
            id = "modebutton",
            text = "Enable Edit Mode",
            onclick = function()
                set_edit_group_visibility(dialog, not edit_mode_visible)
            end
        }
        :combobox {
            id = "groupsdropdown",
            label = "Selected Group",
            option = nil,
            options = get_dropdown_options(color_groups),
            onchange = function()
                selected_group_index = get_dropdown_table_index(dialog.data.groupsdropdown)
            end
        }
        :button {
            id = "addcolors",
            text = "Add Colors",
            selected = false,
            focus = false,
            onclick = function()
                local data = dialog.data
                local group_idx = get_dropdown_table_index(data.groupsdropdown)
                local selectedColors = app.range.colors
                for j = 1, #selectedColors do
                    table.insert(color_groups[group_idx].colors, selectedColors[j])
                end
                update_groups_dialog(dialog)
            end
        }
        :button {
            id = "clearcolors",
            text = "Clear Colors",
            selected = false,
            focus = false,
            onclick = function()
                local data = dialog.data
                local group_idx = get_dropdown_table_index(data.groupsdropdown)
                color_groups[group_idx].colors = {}
                update_groups_dialog(dialog)
            end
        }
        :entry {
            id = "groupname",
            label = "Group Name",
            onclick = function()
            end
        }
        :button {
            id = "renamebutton",
            text = "Rename",
            selected = false,
            focus = false,
            onclick = function()
                local data = dialog.data
                if data.groupname ~= "" then
                    local group_idx = get_dropdown_table_index(data.groupsdropdown)
                    color_groups[group_idx].name = data.groupname
                end
                update_groups_dialog(dialog)
            end
        }
        :entry {
            id = 'filename',
            label = "File Name",
            focus = boolean,
            onclick = function()
            end
        }
        :button {
            id = "save",
            text = "Save",
            selected = false,
            focus = false,
            onclick = function()
                local data = dialog.data
                save_color_groups(data.filename)
            end
        }
        :button {
            id = "load",
            text = "Load",
            selected = false,
            focus = false,
            onclick = function()
                local data = dialog.data
                load_color_groups(data.filename)
                update_groups_dialog(dialog)
            end
        }
        :button {
            id = "openpathfolder",
            text = "Open Folder",
            selected = false,
            focus = false,
            onclick = function()
                os.execute("start " .. groups_folder_path)
            end
        }
        :separator {
            id = "groupsseparator",
            text = "Groups"
        }
end

function create_color_groups_paging_dialog(dlg)
    dlg
        :button {
            id = "nav-first",
            text = "|<",
            selected = false,
            focus = false,
            onclick = function()
                selected_group_index = 1
                if active_page ~= 1 then
                    active_page = 1
                    update_groups_dialog(dlg)
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
                update_groups_dialog(dlg)
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
                    update_groups_dialog(dlg)
                end
            end
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
                    update_groups_dialog(dlg)
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
                update_groups_dialog(dlg)
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
                    update_groups_dialog(dlg)
                end
            end
        }
end

function display_color_groups_guide(dialog , widgetstable , visible)
    local len = table_extended.length(widgetstable)
    for i = 1, len do
        if widgetstable[i][1] ~= "newrow" then
            dialog:modify{ id= "guide"..tostring(i), visible = visible, enabled = true }
        end
    end
    dialog:modify{ id = "resize", visible = visible, enabled = true }
end

return function(dialogtitle)
    local quick_guide_text = {
        { "separator", "Mode" },
        { "label", "-- Select the group to edit." },
        { "newrow" },
        { "label", "-- [Add Colors] Adds selected color/s from palette to the selected group." },
        { "newrow" },
        { "label", "-- [Clear Colors] Clears all colors from selected group." },
        { "newrow" },
        { "label", "-- [Rename] Change the selected group name to the {Group Name} entry." },
        { "newrow" },
        { "label", "-- [Save] Saves with {File Name} entry." },
        { "newrow" },
        { "label", "-- [Load] Loads the {File Name} entry." },
        { "newrow" },
        { "label", "-- [Open Folder] Open your color groups folder. Useful to get an existing file name to load." },
        { "newrow" },
        { "separator", "Groups" },
        { "label", "-- Simply click any color to set it as the foreground color." },
        { "newrow" },
        { "label", "-- [Refresh] Refresh all the groups colors. Useful if palette was modified." },
        { "newrow" },
        { "label", "-- [Prev] [Next] Cycle color groups pages." },
        { "separator", "Notes" },
        { "label", "-- This tool only saves the colors indexes. Any palette modifications will affect your color groups." },
    }
    local color_groups_dialog = Dialog(dialogtitle)
    local guide_visible = false

    color_groups_dialog:separator{ text = "Quick Reference"}
    color_groups_dialog:button{
        id = "guidebutton",
        text = "▼",
        onclick=function()
            if guide_visible == false then
                display_color_groups_guide(color_groups_dialog, quick_guide_text,true)
                guide_visible = true
                color_groups_dialog:modify{ id = "guidebutton", text = "▲"}
            else
                display_color_groups_guide(color_groups_dialog, quick_guide_text,false)
                guide_visible = false
                color_groups_dialog:modify{ id = "guidebutton", text = "▼"}
            end
        end
    }
    color_groups_dialog:label{ id = "resize", text = "Resize ▶ ▶ ▶ "}
    for i = 1, table_extended.length(quick_guide_text) do
        if quick_guide_text[i][1] == "separator" then
            color_groups_dialog:separator{ id = "guide"..tostring(i), text = quick_guide_text[i][2] }
        elseif quick_guide_text[i][1] == "label" then
            color_groups_dialog:label{ id = "guide"..tostring(i), text = quick_guide_text[i][2] }
        elseif quick_guide_text[i][1] == "newrow" then
            color_groups_dialog:newrow()
        end
    end

    display_color_groups_guide(color_groups_dialog, quick_guide_text,false)
    create_color_groups_dialog(color_groups_dialog)
    color_groups_widget(color_groups_dialog, num_color_groups_per_page, color_groups)
    create_color_groups_paging_dialog(color_groups_dialog)
    update_groups_dialog(color_groups_dialog)

    color_groups_dialog:show {
        wait = false,
        bounds = dialogbounds
    }
    return color_groups_dialog
end