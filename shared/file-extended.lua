local fileextended = {}

function fileextended.file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

return fileextended