local stringextended = {}

function stringextended.exportstring( s )
    return string.format("%q", s)
end

return stringextended