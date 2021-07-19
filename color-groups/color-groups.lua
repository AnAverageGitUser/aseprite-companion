tableextended = dofile("../shared/table-extended.lua")
fileextended = dofile("../shared/file-extended.lua")
colorgroupswidget = dofile("./color-groups-widget.lua")
colorgroupspage = dofile("./color-groups-pages.lua")
alertextended = dofile("../shared/alert-extended.lua")

local pathtofolder = app.fs.userConfigPath

local dialogbounds
local nbcolorgroup = 30
local activepage = 1
local editorvisible = true
local colorgroups = {}

function createcolorgroups(nb)
    local tbl = {}
    for i = 1, nb do
        colorgroups[i] = { "Group-" .. tostring(i) }
        --table.insert(tbl, { "Group-" .. tostring(i) })
    end
    return tbl
end

createcolorgroups(nbcolorgroup)
local selectedgroup = colorgroups[1][1]

function getdropdownoptions(tbl)
    local dropdowntbl = {}
    for i = 1, #tbl do
        table.insert(dropdowntbl, tbl[i][1])
    end
    return dropdowntbl
end

function savecolorgroups(name)
    local path = pathtofolder .. "\\groups\\" .. name .. ".lua"
    if (name ~= "")
    then
        if (fileextended.fileexists(path))
        then
            local result = app.alert { title = "Color Groups",
                                       text = {"A file with the same name already exsists","Are you sure you want to overwrite this file?"},
                                       buttons = { "Yes", "No" } }
            if result == 1 then
                os.execute("mkdir " .. pathtofolder .. "\\groups")
                tableextended.save(colorgroups, path)
                app.alert { title = "Color Groups",
                            text = { "-- Save successful --"},
                            buttons = alertextended.randomconfirmtext()
                }
            end
        else
            os.execute("mkdir " .. pathtofolder .. "\\groups")
            tableextended.save(colorgroups, path)
            app.alert { title = "Color Groups",
                        text = { "-- Save successful --"},
                        buttons = alertextended.randomconfirmtext()
            }
        end
    else
        app.alert { title = "Color Groups",
                    text = { "-- Save failed --",
                             "File Name entry is empty.",
                             "Please specify a name." },
                    buttons = alertextended.randomconfirmtext()
        }
    end
end

function loadcolorgroups(name)
    local path = pathtofolder .. "\\groups\\" .. name .. ".lua"
    if (fileextended.fileexists(path))
    then
        colorgroups = tableextended.load(path)
    else
        app.alert { title = "Color Groups",
                    text = { "-- Load failed --",
                             "File Name entry don't match any existing file.",
                             "Please specify an existing file name. You may use [Open Folder] to find the file name." },
                    buttons = alertextended.randomconfirmtext()
        }
    end
end

function showgroupsdialog()
    local colorgroupsdlg = colorgroupsdialog("Color Groups")
    editormode(colorgroupsdlg, editorvisible)
    colorgroupsdlg:show { wait = false, bounds = dialogbounds }
end

function closegroupsdialog(closingdialog, renamed)
    local data = closingdialog.data
    if renamed == true then
        selectedgroup = data.groupname
    else
        selectedgroup = data.groupsdropdown

    end
    dialogbounds = closingdialog.bounds
    closingdialog:close()
end

function editormode(dialog, visible)
    editorvisible = visible
    local text = ""
    if visible == true then
        text = "Enable Create Mode"
    else
        text = "Enable Edit Mode"
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

return function(dialogtitle)
    local quickguidetable = {
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

    local colorgroupsdlg = Dialog(dialogtitle)
    local actspr = app.activeSprite
    local actpal = actspr.palettes[1]

    local guidevisible = false

    function displaycolorgroupsguide(dialog ,widgetstable ,visible)
        local len = tableextended.length(widgetstable)
        for i = 1, len do
            if widgetstable[i][1] ~= "newrow" then
                dialog:modify{ id= "guide"..tostring(i), visible = visible, enabled = true }
            end
        end
        dialog:modify{ id = "resize", visible = visible, enabled = true }
    end

    colorgroupsdlg:separator{ text = "Quick Reference"}
    colorgroupsdlg:button{ id = "guidebutton", text = "▼",
                   onclick=function()
                       if guidevisible == false then
                           displaycolorgroupsguide(colorgroupsdlg,quickguidetable,true)
                           guidevisible = true
                           colorgroupsdlg:modify{ id = "guidebutton", text = "▲"}
                       else
                           displaycolorgroupsguide(colorgroupsdlg,quickguidetable,false)
                           guidevisible = false
                           colorgroupsdlg:modify{ id = "guidebutton", text = "▼"}
                       end
                   end
    }
    colorgroupsdlg:label{id = "resize", text = "Resize ▶ ▶ ▶ "}
    for i = 1, tableextended.length(quickguidetable) do
        if quickguidetable[i][1] == "separator" then
            colorgroupsdlg:separator{ id = "guide"..tostring(i), text = quickguidetable[i][2] }
        elseif quickguidetable[i][1] == "label" then
            colorgroupsdlg:label{ id = "guide"..tostring(i), text = quickguidetable[i][2] }
        elseif quickguidetable[i][1] == "newrow" then
            colorgroupsdlg:newrow()
        end
    end

    displaycolorgroupsguide(colorgroupsdlg,quickguidetable,false)

    colorgroupsdlg
            :separator {
        text = "Mode"
    }
            :button { id = "modebutton", text = "Enable Edit Mode",
                      onclick = function()
                          if editorvisible == false then
                              editormode(colorgroupsdlg, true)
                          else
                              editormode(colorgroupsdlg, false)
                          end
                      end
    }
            :combobox {
        id = "groupsdropdown",
        label = "Selected Group",
        option = selectedgroup,
        options = getdropdownoptions(colorgroups)
    }
            :button {
        id = "addcolors",
        text = "Add Colors",
        selected = false,
        focus = false,
        onclick = function()
            local data = colorgroupsdlg.data
            for i = 1, nbcolorgroup do
                if (data.groupsdropdown == colorgroups[i][1]) then
                    local selectedColors = app.range.colors
                    --while #colorgroups[i] > 1 do
                    --    table.remove(colorgroups[i], 2)
                    --end
                    for j = 2, #selectedColors + 1 do
                        table.insert(colorgroups[i], selectedColors[j - 1])
                    end
                end
            end
            closegroupsdialog(colorgroupsdlg)
            showgroupsdialog()
        end
    }
            :button {
        id = "clearcolors",
        text = "Clear Colors",
        selected = false,
        focus = false,
        onclick = function()
            local data = colorgroupsdlg.data
            for i = 1, nbcolorgroup do
                if (data.groupsdropdown == colorgroups[i][1]) then
                    while #colorgroups[i] > 1 do
                        table.remove(colorgroups[i], 2)
                    end
                end
            end
            closegroupsdialog(colorgroupsdlg)
            showgroupsdialog()
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
            local data = colorgroupsdlg.data
            if (data.groupname ~= "")
            then
                for i = 1, #colorgroups do
                    if (data.groupsdropdown == colorgroups[i][1])
                    then
                        colorgroups[i][1] = data.groupname
                    end
                end
            end
            closegroupsdialog(colorgroupsdlg, true)
            showgroupsdialog()
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
            local data = colorgroupsdlg.data
            savecolorgroups(data.filename)
        end
    }
            :button {
        id = "load",
        text = "Load",
        selected = false,
        focus = false,
        onclick = function()
            local data = colorgroupsdlg.data
            loadcolorgroups(data.filename)
            closegroupsdialog(colorgroupsdlg)
            showgroupsdialog()
        end
    }
            :button {
        id = "openpathfolder",
        text = "Open Folder",
        selected = false,
        focus = false,
        onclick = function()
            fileextended.openpathfolder(pathtofolder)
        end
    }
            :separator {
        text = "Groups"
    }
    colorgroupswidget(colorgroupsdlg, nbcolorgroup, colorgroups, actpal)
            :button {
        id = "refresh",
        text = "Refresh",
        selected = false,
        focus = false,
        onclick = function()
            closegroupsdialog(colorgroupsdlg)
            actspr = app.activeSprite
            actpal = actspr.palettes[1]
            showgroupsdialog()
        end
    }
            :newrow()
            :button {
        id = "Prev",
        text = "Prev",
        selected = false,
        focus = false,
        onclick = function()
            if activepage ~= 1 then
                activepage = activepage - 1
                closegroupsdialog(colorgroupsdlg)
                showgroupsdialog()
            end
        end
    }
            :button {
        id = "Next",
        text = "Next",
        selected = false,
        focus = false,
        onclick = function()
            if activepage ~= 3 then
                activepage = activepage + 1
                closegroupsdialog(colorgroupsdlg)
                showgroupsdialog()
            end
        end
    }

    if activepage == 1 then
        colorgroupsdlg:modify { id = "Prev", text = "" }
    else
        colorgroupsdlg:modify { id = "Prev", text = "Prev" }
    end
    if activepage == 3 then
        colorgroupsdlg:modify { id = "Next", text = "" }
    else
        colorgroupsdlg:modify { id = "Next", text = "Next" }
    end
    if activepage == 1 then
        colorgroupspage(colorgroupsdlg, 1, 10, true)
        colorgroupspage(colorgroupsdlg, 11, 20, false)
        colorgroupspage(colorgroupsdlg, 21, 30, false)
    elseif activepage == 2 then
        colorgroupspage(colorgroupsdlg, 1, 10, false)
        colorgroupspage(colorgroupsdlg, 11, 20, true)
        colorgroupspage(colorgroupsdlg, 21, 30, false)
    elseif activepage == 3 then
        colorgroupspage(colorgroupsdlg, 1, 10, false)
        colorgroupspage(colorgroupsdlg, 11, 20, false)
        colorgroupspage(colorgroupsdlg, 21, 30, true)
    end

    colorgroupsdlg:show {
        wait = false,
        bounds = dialogbounds
    }
    return colorgroupsdlg
end