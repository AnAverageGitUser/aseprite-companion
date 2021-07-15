local mathextended = {}

function mathextended:norm(value, min, max)
    return (value - min) / (max - min)
end

function mathextended:clamp(num, lower, upper)
    assert(num and lower and upper)
    return math.max(lower, math.min(upper, num))
end

function mathextended:lerp(first, second, by)
    return first * (1 - by) + second * by
end

return mathextended
