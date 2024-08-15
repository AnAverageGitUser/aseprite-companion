local this = {
    range_min = 1,
    range_max = 1,
    pos = 1,
}

function this.cap()
    if this.pos < this.range_min then
        this.pos = this.range_min
    elseif this.pos > this.range_max then
        this.pos = this.range_max
    end
end

function this.wrap()
    if this.pos < this.range_min then
        this.pos = this.range_max
    elseif this.pos > this.range_max then
        this.pos = this.range_min
    end
end

function this.offset()
    return this.pos - this.range_min
end

function this.set_range(min, max)
    local offset = this.offset()
    this.range_min = min
    this.range_max = max
    this.pos = this.range_min + offset
    this.cap()
end

function this.index()
    return this.pos
end

function this.previous()
    this.pos = this.pos - 1
    this.wrap()
end

function this.next()
    this.pos = this.pos + 1
    this.wrap()
end

function this.is_min()
    return this.pos == this.range_min
end

function this.is_max()
    return this.pos == this.range_max
end

return this