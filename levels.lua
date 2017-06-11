-- Import section

-- No more external access
setfenv(1, {})

local export = {}

-- A level has the following properties
--   speed  - integer 1 - 5 where 5 is the
--            speediest
--   bricks - 2d array of bricks, brick can
--            be: ' ' (empty), '1' (brick type 1)
--            Size of array is 10*7
local levels = {
    {
        speed = 1,
        bricks = {
            { '1' },
        },
    },
    {
        speed = 1,
        bricks = {
            { ' ', '1', ' ', '1', ' ', '1', ' ', '1', ' ', '1' },
            { '1', ' ', '1', ' ', '1', ' ', '1', ' ', '1', ' ' },
            { ' ', '1', ' ', '1', ' ', '1', ' ', '1', ' ', '1' },
            { '1', ' ', '1', ' ', '1', ' ', '1', ' ', '1', ' ' },
            { ' ', '1', ' ', '1', ' ', '1', ' ', '1', ' ', '1' },
            { '1', ' ', '1', ' ', '1', ' ', '1', ' ', '1', ' ' },
            { ' ', '1', ' ', '1', ' ', '1', ' ', '1', ' ', '1' },
        },
    },
}

local function newLevel(data)
    local me = {
        speed = data.speed,
        bricks = data.bricks
    }

    return me
end

export.getLevel = function(index)
    local data = levels[index]

    return newLevel(data)
end

export.isLast = function(index)
    return index == #levels
end

return export
