tableextended = dofile("../shared/table-extended.lua")
fileextended = dofile("../shared/file-extended.lua")
colorgroupswidget = dofile("./color-groups-widget.lua")
colorgroupspage = dofile("./color-groups-pages.lua")
quickguide = dofile("../shared/quick-reference-guide.lua")

local pathtofolder = "C:\\Users\\jonat\\AppData\\Roaming\\Aseprite"

local dialogbounds
local nbcolorgroup = 30
local activepage = 1
local editorvisible = true
local colorgroups = {{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},}

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
        if (fileextended.fileExists(path))
        then
            local result = app.alert { title = "Warning",
                                       text = "Are you sure you want to overwrite this file?",
                                       buttons = { "Yes", "No" } }
            if result == 1 then
                os.execute("mkdir " .. pathtofolder .. "\\groups")
                tableextended.save(colorgroups, path)
                app.alert("Saved.")
            end
        else
            os.execute("mkdir " .. pathtofolder .. "\\groups")
            tableextended.save(colorgroups, path)
            app.alert("Saved.")
        end
    else
        app.alert("Could not save. (Reason: No Entry.)")
    end
end

function loadcolorgroups(name)
    local path = pathtofolder .. "\\groups\\" .. name .. ".lua"
    if (fileextended.fileExists(path))
    then
        colorgroups = tableextended.load(path)
    else
        app.alert("Could not load. (Reason: The file does not exists.)")
    end
end

function showdialog()
    local dlg = colorgroupsdialog("Color Groups")
    editormode(dlg, editorvisible)
    dlg:show { wait = false, bounds = dialogbounds }
end

function closedialog(closingdialog)
    local data = closingdialog.data
    selectedgroup = data.groupsdropdown
    dialogbounds = closingdialog.bounds
    closingdialog:close()
end

function editormode(dialog,visible)
    editorvisible = visible
    local text = ""
    if visible == true then text = "Edit" else text = "Create" end
    dialog:modify{ id = "modebutton", text = text}
    dialog:modify{ id = "groupsdropdown", visible = visible}
    dialog:modify{ id = "addcolors", visible = visible}
    dialog:modify{ id = "clearcolors", visible = visible}
    dialog:modify{ id = "groupname", visible = visible}
    dialog:modify{ id = "renamebutton", visible = visible}
    dialog:modify{ id = "filename", visible = visible}
    dialog:modify{ id = "save", visible = visible}
    dialog:modify{ id = "load", visible = visible}
    dialog:modify{ id = "openpathfolder", visible = visible}
end

return function(dialogtitle)
    local quickguidetable = {
        { "separator", "Mode" },
        { "label", "-- [Add Colors] Adds selected colors from palette to the selected group." },
        { "newrow" },
        { "label", "-- [Clear Colors] Clears all colors from selected group." },
        { "newrow" },
        { "label", "-- [Rename] Change the selected group name to the {Group Name} entry." },
        { "newrow" },
        { "label", "-- [Save] Saves with {File Name} entry." },
        { "newrow" },
        { "label", "-- [Load] Loads the {File Name} entry." },
        { "newrow" },
        { "label", "-- [Open Folder] Open your color groups folder. Useful to get an existing file name to load" },
        { "newrow" },
        { "separator", "Groups" },
        { "label", "-- Simply click any color to set it as the foreground color." },
        { "newrow" },
        { "label", "-- [Refresh] Refresh all the groups colors. Useful if palette was modifed" },
        { "newrow" },
        { "label", "-- [Prev] [Next] Cycle color groups pages" },
    }

    local dlg = Dialog(dialogtitle)
    local actspr = app.activeSprite
    local actpal = actspr.palettes[1]

    quickguide(dlg, quickguidetable)
    dlg
            :separator {
        text = "Mode"
    }
            :button{ id = "modebutton", text = "Edit",
                     onclick=function()
                         if editorvisible == false then
                             editormode(dlg,true)
                         else
                             editormode(dlg,false)
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
            local data = dlg.data
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
            closedialog(dlg)
            showdialog()
        end
    }
            :button {
        id = "clearcolors",
        text = "Clear Colors",
        selected = false,
        focus = false,
        onclick = function()
            local data = dlg.data
            for i = 1, nbcolorgroup do
                if (data.groupsdropdown == colorgroups[i][1]) then
                    while #colorgroups[i] > 1 do
                        table.remove(colorgroups[i], 2)
                    end
                end
            end
            closedialog(dlg)
            showdialog()
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
            local data = dlg.data
            if (data.groupname ~= "")
            then
                for i = 1, #colorgroups do
                    if (data.groupsdropdown == colorgroups[i][1])
                    then
                        colorgroups[i][1] = data.groupname
                    end
                end
            end
            closedialog(dlg)
            showdialog()
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
            local data = dlg.data
            savecolorgroups(data.filename)
        end
    }
            :button {
        id = "load",
        text = "Load",
        selected = false,
        focus = false,
        onclick = function()
            local data = dlg.data
            loadcolorgroups(data.filename)
            closedialog(dlg)
            showdialog()
        end
    }
            :button {
        id = "openpathfolder",
        text = "Open Folder",
        selected = false,
        focus = false,
        onclick = function()
            fileextended.openPathFolder(pathtofolder)
        end
    }
            :separator {
        text = "Groups"
    }
    colorgroupswidget(dlg, nbcolorgroup, colorgroups, actpal)
            :button {
        id = "refresh",
        text = "Refresh",
        selected = false,
        focus = false,
        onclick = function()
            closedialog(dlg)
            actspr = app.activeSprite
            actpal = actspr.palettes[1]
            showdialog()
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
                closedialog(dlg)
                showdialog()
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
                closedialog(dlg)
                showdialog()
            end
        end
    }

    if activepage == 1 then
        dlg:modify { id = "Prev", text = "" }
    else
        dlg:modify { id = "Prev", text = "Prev" }
    end
    if activepage == 3 then
        dlg:modify { id = "Next", text = "" }
    else
        dlg:modify { id = "Next", text = "Next" }
    end
    if activepage == 1 then
        colorgroupspage(dlg, 1, 10, true)
        colorgroupspage(dlg, 11, 20, false)
        colorgroupspage(dlg, 21, 30, false)
    elseif activepage == 2 then
        colorgroupspage(dlg, 1, 10, false)
        colorgroupspage(dlg, 11, 20, true)
        colorgroupspage(dlg, 21, 30, false)
    elseif activepage == 3 then
        colorgroupspage(dlg, 1, 10, false)
        colorgroupspage(dlg, 11, 20, false)
        colorgroupspage(dlg, 21, 30, true)
    end

    dlg:show {
        wait = false,
        bounds = dialogbounds
    }
    return dlg
end