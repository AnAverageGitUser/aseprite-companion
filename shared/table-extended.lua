stringextended = dofile("./string-extended.lua")
alert_extended = dofile("../shared/alert-extended.lua")
file_extended = dofile("../shared/file-extended.lua")

local this = {}

function this.length(tbl)
    local count = 0
    for k,v in pairs(tbl) do
        count = count + 1
    end
    return count
end

function this.save(table, filename)
    local file, err = io.open(filename, "wb")
    if err then
        return err
    end

    local json_table = json.encode(table)
    _, err = file:write(json_table)
    if err ~= nil then
        file:close()
        return err
    end
    file:close()
end

function this.save_color_groups(table, folder_path, file_path, name)
    if name == "" then
        alert_extended.alert_error{
            "File Name entry is empty.",
            "Please specify a name."
        }
        return
    end

    if file_extended.file_exists(file_path) then
        local result = app.alert{
            title = "Aseprite Companion: Overwrite file?",
            text = {
                "A file with the same name already exists.",
                "The file in question:",
                "" .. file_path,
                "",
                "Do you want to overwrite this file?"
            },
            buttons = { "Yes: Overwrite File", "No" }
        }
        if result ~= 1 then
            return
        end
    end

    os.execute("mkdir " .. folder_path)
    local err_or_nil_on_success = table_extended.save(table, file_path)
    if err_or_nil_on_success == nil then
        alert_extended.alert_info{
            "Saved file successfully to:",
            "" .. file_path
        }
    else
        alert_extended.alert_error({
            "Error while saving file '" .. file_path .. "':",
            "" .. err_or_nil_on_success,
        })
    end
end

function this.load(filename)
    local file, err = io.open(filename, "rb")
    if err then
        alert_extended.alert_error({
            "Error while loading file '" .. filename .. "':",
            "" .. err,
        })
        return nil
    end

    local file_content = file:read("a")
    file:close()

    return json.decode(file_content)
end

function this.load_color_groups(file_path, fn_is_default_table_in_memory)
    if not file_extended.file_exists(file_path) then
        alert_extended.alert_error{
            "Trying to load non existent file:",
            "" .. file_path,
            "",
            "Please specify an existing file name. You may use [Open Folder] to find the file name."
        }
        return nil
    end

    if not fn_is_default_table_in_memory() then
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
            return nil
        end
    end

    return table_extended.load(file_path)
end

function this.tostring(tbl )
    local result, done = {}, {}
    for k, v in ipairs( tbl ) do
        table.insert( result, table.val_to_str( v ) )
        done[ k ] = true
    end
    for k, v in pairs( tbl ) do
        if not done[ k ] then
            table.insert( result,
                    table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
        end
    end
    return "{" .. table.concat( result, "," ) .. "}"
end

return this