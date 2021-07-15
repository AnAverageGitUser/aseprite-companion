local tableextended = {}

function tableextended.length(tbl)
    local count = 0
    for k,v in pairs(tbl) do
        count = count + 1
    end
    return count
end

return tableextended