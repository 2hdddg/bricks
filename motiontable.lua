
-- Import section
local pi = math.pi
local sin = math.sin
local floor = math.floor

-- No more external access
setfenv(1, {})

local function sine_table(n)
    local step = pi / n
    local table = {}

    for i = 0, n do
        local v = sin(i * step)
        table[i] = v
    end

    return table
end

function newCursor(size, initial, cycle_time)
    local _aggr_time = 0
    local _size = size
    local _entry_time = cycle_time / _size

    _aggr_time = initial * _entry_time

    local update = function(delta_time)
        _aggr_time = _aggr_time + delta_time

        return floor((_aggr_time / _entry_time) % _size)
    end

    return {
        update = update
    }
end

return {
    sine_table = sine_table,
    newCursor = newCursor,
}
