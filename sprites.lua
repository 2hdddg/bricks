
-- Import section
local string = string
local graphics = love.graphics
local print = print


-- No more external access
setfenv(1, {})


local function build_quad_map(image, from, to)
    local w = image:getWidth()
    local h = image:getHeight()
    local a = {}
    local i = 0

    for b=string.byte(from), string.byte(to) do
        local c = string.char(b)
        local q = graphics.newQuad(5 * i + i, 0, 5, 8, w, h)
        i = i + 1
        a[c] = q
    end
    return a
end

local function get_letters()
    local _image = graphics.newImage('az.png')

    _image:setFilter('nearest', 'nearest')

    return {
        map = build_quad_map(_image, 'A', 'Z'),
        image = _image,
    }
end

local function get_numbers()
    local image = graphics.newImage('09.png')

    image:setFilter('nearest', 'nearest')

    return {
        map = build_quad_map(image, '0', '9'),
        image = image,
    }
end

local function get_blocks()
    local image = graphics.newImage('breakout_pieces.png')
    local w = image:getWidth()
    local h = image:getHeight()
    local a = {}

    image:setFilter('nearest', 'nearest')
    a['ball'] = graphics.newQuad(48, 136, 8, 8, w, h)
    a['bat'] = graphics.newQuad(8, 151, 64, 20, w, h)
    a['brick1'] = graphics.newQuad(8, 48, 32, 16, w, h)
    a['heart'] = graphics.newQuad(120, 135, 10, 9, w, h)

    return {
        map = a,
        image = image
    }
end

return {
    get_letters = get_letters,
    get_numbers = get_numbers,
    get_blocks = get_blocks,
}
