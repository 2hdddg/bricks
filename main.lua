-- Import section
local print = print
local controller = require 'controller'
local love = love

-- No more external access
setfenv(1, {})

local W = 800
local H = 480

local function printFullscreenModes()
    local modes = love.window.getFullscreenModes()
    for i = 1, #modes do
        print(modes[i].width .. 'x' .. modes[i].height)
    end
end

function love.load()
    printFullscreenModes()
    love.window.setMode(W, H)
    --love.window.setFullscreen(true, 'normal')
    love.keyboard.setKeyRepeat(true)

    controller.newController(love, W, H).mainMenu()
end
