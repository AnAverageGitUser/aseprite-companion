tableextended = dofile("../shared/table-extended.lua")
fileextended = dofile("../shared/file-extended.lua")

local pathToFolder = "C:\\Users\\jonat\\AppData\\Roaming\\Aseprite"

local mainWindowBounds

local colorGroup01 = {"Group01",0,0,0,0,0,0}
local colorGroup02 = {"Group02",0,0,0,0,0,0}
local colorGroup03 = {"Group03",0,0,0,0,0,0}
local colorGroup04 = {"Group04",0,0,0,0,0,0}
local colorGroup05 = {"Group05",0,0,0,0,0,0}
local colorGroup06 = {"Group06",0,0,0,0,0,0}

local compiledColorGroups = {colorGroup01,colorGroup02,colorGroup03,colorGroup04,colorGroup05,colorGroup06}
local compiledColorGroupsWithKey = {group1=colorGroup01,group2=colorGroup02,group3=colorGroup03,group4=colorGroup04,group5=colorGroup05,group6=colorGroup06}
local dropDownOptions = {colorGroup01[1],colorGroup02[1],colorGroup03[1],colorGroup04[1],colorGroup05[1],colorGroup06[1]}

function saveColorGroup(name)
	local path = pathToFolder.. "\\groups\\" .. name .. ".lua"
    if (name ~= "")
        then
            if (fileextended.fileExists(path))
                then
                    app.alert("TODO: Confirm ovewrite file dialog box")
                else
                    os.execute("mkdir ".. pathToFolder.."\\groups")
                    tableextended.save(compiledColorGroups, path)
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
        	compiledColorGroups = tableextended.load(path)
        	colorGroup01 = compiledColorGroups[1]
        	colorGroup02 = compiledColorGroups[2]
        	colorGroup03 = compiledColorGroups[3]
        	colorGroup04 = compiledColorGroups[4]
        	colorGroup05 = compiledColorGroups[5]
        	colorGroup06 = compiledColorGroups[6]
        else
            app.alert("Could not load. (Reason: The file does not exists.)")
        end
end

function showdialog()
    local dlg = colorgroupsdialog("Color Groups")
    dlg:show { wait = false, bounds = dialogbounds }
end

function closedialog(closingdialog)
    mainWindowBounds = closingdialog.bounds
    closingdialog:close()
end

return function(dialogtitle)
        local dlg = Dialog(dialogtitle)
        local actSpr = app.activeSprite
        local actPal = actSpr.palettes[ 1 ]

        function indexToColor(index)
            local c = actPal:getColor(index)
            return c
        end
        -- MAIN DIALOG
        dlg
                :separator{
            text="Colors"
        }
                :combobox{
            id="ShadesDropDown",
            label="Group",
            options={ colorGroup01[1],colorGroup02[1],colorGroup03[1],colorGroup04[1],colorGroup05[1],colorGroup06[1]}
        }
                :button{
            id="Assign",
            text="Assign FG Color",
            selected=false,
            focus=false,
            onclick=function()
                local data = dlg.data
                for i=1,6 do
                    if (data.ShadesDropDown == dropDownOptions[i]) then
                        local c = app.fgColor
                        local selectedColors = app.range.colors
                        for j=2,7 do
                            compiledColorGroupsWithKey["group"..tostring(i)][j] = selectedColors[j-1]
                        end
                    end
                end
                closedialog(dlg)
                showdialog()
            end
        }
                :entry{
            id="ShadeName",
            label="Group Name",
            onclick=function()
                local data = dlg.data
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
                    if (data.ShadesDropDown == colorGroup01[1])
                    then
                        colorGroup01[1] = data.ShadeName
                    end
                    if (data.ShadesDropDown == colorGroup02[1])
                    then
                        colorGroup02[1] = data.ShadeName
                    end
                    if (data.ShadesDropDown == colorGroup03[1])
                    then
                        colorGroup03[1] = data.ShadeName
                    end
                    if (data.ShadesDropDown == colorGroup04[1])
                    then
                        colorGroup04[1] = data.ShadeName
                    end
                    if (data.ShadesDropDown == colorGroup05[1])
                    then
                        colorGroup05[1] = data.ShadeName
                    end
                    if (data.ShadesDropDown == colorGroup06[1])
                    then
                        colorGroup06[1] = data.ShadeName
                    end
                end
                closedialog(dlg)
                showdialog()
            end
        }
                :separator{
            text="Shades"
        }
                :shades{
            id="Shade1",
            label=colorGroup01[1],
            mode="pick",
            colors={ indexToColor(colorGroup01[2]), indexToColor(colorGroup01[3]), indexToColor(colorGroup01[4]), indexToColor(colorGroup01[5]), indexToColor(colorGroup01[6]), indexToColor(colorGroup01[7])},
            onclick=function(ev)
                app.fgColor = ev.color
            end
        }
                :shades{
            id="Shade2",
            label=colorGroup02[1],
            mode="pick",
            colors={ indexToColor(colorGroup02[2]), indexToColor(colorGroup02[3]), indexToColor(colorGroup02[4]), indexToColor(colorGroup02[5]), indexToColor(colorGroup02[6]), indexToColor(colorGroup02[7])},
            onclick=function(ev)
                app.fgColor = ev.color
            end
        }
                :shades{
            id="Shade3",
            label=colorGroup03[1],
            mode="pick",
            colors={ indexToColor(colorGroup01[2]), indexToColor(colorGroup01[3]), indexToColor(colorGroup01[4]), indexToColor(colorGroup01[5]), indexToColor(colorGroup01[6]), indexToColor(colorGroup01[7])},
            onclick=function(ev)
                app.fgColor = ev.color
            end
        }
                :shades{
            id="Shade4",
            label=colorGroup04[1],
            mode="pick",
            colors={ indexToColor(colorGroup01[2]), indexToColor(colorGroup01[3]), indexToColor(colorGroup01[4]), indexToColor(colorGroup01[5]), indexToColor(colorGroup01[6]), indexToColor(colorGroup01[7])},
            onclick=function(ev)
                app.fgColor = ev.color
            end
        }
                :shades{
            id="Shade5",
            label=colorGroup05[1],
            mode="pick",
            colors={ indexToColor(colorGroup01[2]), indexToColor(colorGroup01[3]), indexToColor(colorGroup01[4]), indexToColor(colorGroup01[5]), indexToColor(colorGroup01[6]), indexToColor(colorGroup01[7])},
            onclick=function(ev)
                app.fgColor = ev.color
            end
        }
                :shades{
            id="Shade6",
            label=colorGroup06[1],
            mode="pick",
            colors={ indexToColor(colorGroup01[2]), indexToColor(colorGroup01[3]), indexToColor(colorGroup01[4]), indexToColor(colorGroup01[5]), indexToColor(colorGroup01[6]), indexToColor(colorGroup01[7])},
            onclick=function(ev)
                app.fgColor = ev.color
            end
        }
                :shades{
            id="Shade7",
            label=colorGroup06[1],
            mode="pick",
            colors={ indexToColor(colorGroup01[2]), indexToColor(colorGroup01[3]), indexToColor(colorGroup01[4]), indexToColor(colorGroup01[5]), indexToColor(colorGroup01[6]), indexToColor(colorGroup01[7])},
            onclick=function(ev)
                app.fgColor = ev.color
            end
        }
                :shades{
            id="Shade8",
            label=colorGroup06[1],
            mode="pick",
            colors={ indexToColor(colorGroup01[2]), indexToColor(colorGroup01[3]), indexToColor(colorGroup01[4]), indexToColor(colorGroup01[5]), indexToColor(colorGroup01[6]), indexToColor(colorGroup01[7])},
            onclick=function(ev)
                app.fgColor = ev.color
            end
        }
                :button{
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
        }
                :separator{
            text="Save/Load"
        }
                :entry{
            id='Name',
            label="File Name",
            text=Name,
            focus=boolean,
            onclick=function(ev)
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
                local data = dlg.data
                fileextended.openPathFolder(pathToFolder)
            end
        }

        dlg:show{
            wait=false,
            bounds= mainWindowBounds
        }
    return dlg
end