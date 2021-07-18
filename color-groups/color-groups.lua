tableextended = dofile("../shared/table-extended.lua")
fileextended = dofile("../shared/file-extended.lua")
colorgroupwidget = dofile("./color-groups-widget.lua")
colorgrouppages = dofile("./color-groups-pages.lua")

local pathToFolder = "C:\\Users\\jonat\\AppData\\Roaming\\Aseprite"

local mainWindowBounds

local nbcolorgroup = 36
local groupnameindex = nbcolorgroup + 1
local activepage = 1

function createcolorgroups(nb)
    local tbl = {}
    for i=1, nb do
        table.insert(tbl,{"Group-"..tostring(i)})
    end
    return tbl
end

function insertcolorgroups(tbl)
    table.insert(tbl,{"Group-"..tostring(groupnameindex)})
    nbcolorgroup = nbcolorgroup + 1
    groupnameindex = groupnameindex + 1
end

function removecolorgroups(tbl, pos)
    table.remove(tbl, pos)
    nbcolorgroup = nbcolorgroup - 1
end

local colorgroups = createcolorgroups(nbcolorgroup)

local shadeselected = colorgroups[1][1]

function getdropdownoptions(tbl)
    local dropdowntbl = {}
        for i=1, #tbl do
            table.insert(dropdowntbl, tbl[i][1])
        end
    return dropdowntbl
end

function saveColorGroup(name)
	local path = pathToFolder.. "\\groups\\" .. name .. ".lua"
    if (name ~= "")
        then
            if (fileextended.fileExists(path))
                then
                    local result = app.alert{ title="Warning",
                                              text="Are you sure you want to overwrite this file?",
                                              buttons={"Yes", "No"}}
                    if result == 1 then
                        os.execute("mkdir ".. pathToFolder.."\\groups")
                        tableextended.save(colorgroups, path)
                        app.alert("Saved.")
                    end
                else
                    os.execute("mkdir ".. pathToFolder.."\\groups")
                    tableextended.save(colorgroups, path)
                    app.alert("Saved.")
                end
        else
            app.alert("Could not save. (Reason: No Entry.)")
        end
end

function loadColorGroup(name)
	local path = pathToFolder.. "\\groups\\" .. name .. ".lua"
    if (fileextended.fileExists(path))
        then
        	colorgroups = tableextended.load(path)
        else
            app.alert("Could not load. (Reason: The file does not exists.)")
        end
end

function showdialog()
    local dlg = colorgroupsdialog("Color Groups")
    dlg:show { wait = false, bounds = dialogbounds }
end

function closedialog(closingdialog)
    local data = closingdialog.data
    shadeselected = data.ShadesDropDown
    mainWindowBounds = closingdialog.bounds
    closingdialog:close()
end

return function(dialogtitle)
    local dlg = Dialog(dialogtitle)
    local actSpr = app.activeSprite
    local actPal = actSpr.palettes[ 1 ]
    -- MAIN DIALOG
    dlg
            :separator{
        text="Colors"
    }
            :combobox{
        id="ShadesDropDown",
        label="Group",
        option= shadeselected,
        options= getdropdownoptions(colorgroups)
    }
            :button{
        id="addcolors",
        text="Add FG Colors",
        selected=false,
        focus=false,
        onclick=function()
            local data = dlg.data
            for i=1,nbcolorgroup do
                if (data.ShadesDropDown == colorgroups[i][1]) then
                    local selectedColors = app.range.colors
                    --while #colorgroups[i] > 1 do
                    --    table.remove(colorgroups[i], 2)
                    --end
                    for j=2, #selectedColors + 1 do
                        table.insert(colorgroups[i], selectedColors[j-1])
                    end
                end
            end
            closedialog(dlg)
            showdialog()
        end
    }
            :button{
        id="clearcolors",
        text="Clear Colors",
        selected=false,
        focus=false,
        onclick=function()
            local data = dlg.data
            for i=1,nbcolorgroup do
                if (data.ShadesDropDown == colorgroups[i][1]) then
                    while #colorgroups[i] > 1 do
                        table.remove(colorgroups[i], 2)
                    end
                end
            end
            closedialog(dlg)
            showdialog()
        end
    }
    --[[        :newrow()
            :button{
        id="AddGroup",
        text="Add Group",
        selected=false,
        focus=false,
        onclick=function()
            insertcolorgroups(colorgroups)
            closedialog(dlg)
            showdialog()
        end
    }
            :button{
        id="RemoveGroup",
        text="Remove Group",
        selected=false,
        focus=false,
        onclick=function()
            local data = dlg.data
            shadeselected = data.ShadesDropDown
            local pos = 0
            for i=1, nbcolorgroup do
                if shadeselected == colorgroups[i][1] then
                    pos = i
                end
            end
            removecolorgroups(colorgroups, pos)
            closedialog(dlg)
            showdialog()
        end
    }]]--
            :entry{
        id="ShadeName",
        label="Group Name",
        onclick=function()
        end
    }
            :button{
        id="RenameButton",
        text="Rename",
        selected=false,
        focus=false,
        onclick=function()
            local data = dlg.data
            if(data.ShadeName ~= "")
            then
                for i=1, #colorgroups do
                    if (data.ShadesDropDown == colorgroups[i][1])
                    then
                        colorgroups[i][1] = data.ShadeName
                    end
                end
            end
            closedialog(dlg)
            showdialog()
        end
    }
            :separator{
        text="Save/Load"
    }
            :entry{
        id='Name',
        label="File Name",
        text=Name,
        focus=boolean,
        onclick=function()
        end
    }
            :button{
        id="Save",
        text="Save",
        selected=false,
        focus=false,
        onclick=function()
            local data = dlg.data
            saveColorGroup(data.Name)
        end
    }
            :button{
        id="Load",
        text="Load",
        selected=false,
        focus=false,
        onclick=function()
            local data = dlg.data
            loadColorGroup(data.Name)
            closedialog(dlg)
            showdialog()
        end
    }
            :button{
        id="OpenShadeFolder",
        text="Open Folder",
        selected=false,
        focus=false,
        onclick=function()
            fileextended.openPathFolder(pathToFolder)
        end
    }
            :separator{
        text="Shades"
    }
    colorgroupwidget(dlg, nbcolorgroup, colorgroups, actPal)
            :button{
        id="Prev",
        text="Prev",
        selected=false,
        focus=false,
        onclick=function()
            if activepage ~= 1 then
                activepage = activepage -1
                closedialog(dlg)
                showdialog()
            end
        end
    }
            :button{
        id="Next",
        text="Next",
        selected=false,
        focus=false,
        onclick=function()
            if activepage ~= 3 then
                activepage = activepage + 1
                closedialog(dlg)
                showdialog()
            end
        end
    }
    if activepage == 1 then dlg:modify{id="Prev", text=""} else dlg:modify{id="Prev", text="Prev"} end
    if activepage == 3 then dlg:modify{id="Next", text=""} else dlg:modify{id="Next", text="Next"} end
    if activepage == 1 then
        colorgrouppages(dlg,1,12,true)
        colorgrouppages(dlg,13,24,false)
        colorgrouppages(dlg,25,36,false)
    elseif activepage == 2 then
        colorgrouppages(dlg,1,12,false)
        colorgrouppages(dlg,13,24,true)
        colorgrouppages(dlg,25,36,false)
    elseif activepage == 3 then
        colorgrouppages(dlg,1,12,false)
        colorgrouppages(dlg,13,24,false)
        colorgrouppages(dlg,25,36,true)
    end
    --[[:button{
id="RefreshAll",
text="Refresh All",
selected=false,
focus=false,
onclick=function()
closedialog(dlg)
actSpr = app.activeSprite
actPal = actSpr.palettes[ 1 ]
showdialog()
end
}]]--

    dlg:show{
        wait=false,
        bounds= mainWindowBounds
    }
    return dlg
end