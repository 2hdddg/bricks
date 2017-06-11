-- Import section
local graphics = love.graphics
local sprites = require 'sprites'
local print = print
local string = string

-- No more external access
setfenv(1, {})

local numbers = sprites.get_numbers()
local blocks = sprites.get_blocks()

local function newGameBoard(state, W, H)
    local me = {}
    local heart = blocks.map['heart']
    local image = blocks.image

    local function draw()
        -- Draw scores
        local n = string.format("%08d", state.score)
        for i=1, #n do
            local c = n:sub(i, i)
            graphics.draw(numbers.image, numbers.map[c],
                          10 + (12 * i), 12, 0, 2, 2)
        end

        -- Draw lives
        local x = 300
        local y = 5
        for i=1, state.lives do
            graphics.draw(blocks.image, blocks.map['heart'],
                          x, y, 0, 2, 2)
            x = x + 25
        end
    end

    me.draw = draw

    return me
end

return {
    newGameBoard = newGameBoard,
}
