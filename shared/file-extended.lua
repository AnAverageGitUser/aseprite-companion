local fileextended = {}

function fileextended.fileexists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

function fileextended.openpathfolder(path)
    os.execute("start ".. path.."\\groups")
end

return fileextended