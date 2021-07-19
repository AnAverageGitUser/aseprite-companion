local alertextended = {}

function alertextended.randomconfirmtext()
    local txt = { "Okay!", "Ok!", "Alright!", "Sure!", "Got it!", "Absolutely!",
                  "Of course!", "All good!", "Okie dokie!", "Hoy!", "Zug Zug!", "Mamma mia!", "Hey, listen!", "Objection!"}
    local index = 0
    math.randomseed(os.time())
    index = math.random(#txt)
    return txt[index]
end

return alertextended
