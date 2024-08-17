return function(r, g, b)
    local h, s, v
    local min, max, delta

    if r < g then min = r else min = g end
    if min >= b then min = b end

    if r > g then max = r else max = g end
    if max <= b then max = b end
    v = max

    delta = max - min
    if (delta < 0.00001) then
        s = 0
        h = 0
        return h, s, v;
    end
    if max > 0.0 then
        s = (delta / max)
    else
        s = 0
        h = 0
        return h, s, v
    end
    if r >= max then
        -- yellow-ish to magenta-ish
        h = ( g - b ) / delta
    elseif g >= max then
        -- cyan-ish to yellow-ish
        h = 2.0 + ( b - r ) / delta
    else
        -- magenta-ish to cyan-ish
        h = 4.0 + ( r - g ) / delta
    end

    h = h * 60.0
    if h < 0.0 then
        h = h + 360.0;
    end
    -- normalize degrees to one back again
    return h / 360, s, v;
end
