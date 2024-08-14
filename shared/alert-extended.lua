local alert_extended = {}

function alert_extended.alert_error(text)
    app.alert {
        title = "Aseprite Companion: Error",
        text = text,
        buttons = "Close"
    }
end

function alert_extended.alert_info(text)
    app.alert {
        title = "Aseprite Companion: Info",
        text = text,
        buttons = "Close"
    }
end

return alert_extended
