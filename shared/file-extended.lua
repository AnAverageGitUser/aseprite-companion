local fileextended = {}

function fileextended.fileExists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

function fileextended.openPathFolder(path)
    os.execute("start ".. path.."\\groups")
end

return fileextended