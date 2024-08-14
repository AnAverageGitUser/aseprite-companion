stringextended = dofile("./string-extended.lua")
alert_extended = dofile("../shared/alert-extended.lua")

local table_extended = {}

function table_extended.length(tbl)
    local count = 0
    for k,v in pairs(tbl) do
        count = count + 1
    end
    return count
end

function table_extended.save(table, filename)
    local file, err = io.open(filename, "wb")
    if err then
        alert_extended.alert_error({
            "Error while saving file '" .. filename .. "':",
            "" .. err,
        })
        return _, err
    end

    local json_table = json.encode(table)
    file:write(json_table)
    file:close()
end

function table_extended.load(filename)
    local file, err = io.open(filename, "rb")
    if err then
        alert_extended.alert_error({
            "Error while loading file '" .. filename .. "':",
            "" .. err,
        })
        return _, err
    end

    local file_content = file:read("a")
    file:close()

    return json.decode(file_content)
end

function table_extended.tostring(tbl )
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

return table_extended