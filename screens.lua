
-- Import section
local motiontable = require 'motiontable'
local graphics = love.graphics
local audio = love.audio
local physics = love.physics
local draw = graphics.draw
local event = love.event
local print = print
local sprites = require 'sprites'
local game = require 'game'
local gameboard = require 'gameboard'

-- No more external access
setfenv(1, {})

local letters = sprites.get_letters()
local export = {}

export.newMainMenuScreen = function(onGame)
    local _table_size = 100
    local _table = motiontable.genSineTable(_table_size)
    local _cursor = motiontable.newCursor(_table_size, 0, 2)
    local _index = 0
    local _blink = 0
    local _blink_time = 0

    local _b = letters['B']

    local _source = audio.newSource('saw.mp3')
    audio.play(_source)
    _source:stop()


    local keyreleased = function (key)
        if key == 'escape' then
            event.quit()
        end
         onGame()
    end

    local keypressed = function(key, scancode, isrepeat)
    end

    local function multi_draw_h_ys(set, names, x, y, ys, w, z)
        for i = 1, #names do
            graphics.draw(set.image, set.map[names[i]],
                          x + (w * i), y + ys[i], 0, z, z)
        end
    end

    local function multi_draw_h(set, names, x, y, w, z)
        for i = 1, #names do
            graphics.draw(set.image, set.map[names[i]],
                          x + (w * i), y, 0, z, z)
        end
    end

    local draw = function()
        local y
        local off_y = 50
        local off_x = 200

        local logo = {'B', 'L', 'O', 'C', 'K', 'S'}
        local ys = {
            _table[_index] * 200,
            _table[_cursor.delayed(0.1)] * 200,
            _table[_cursor.delayed(0.2)] * 200,
            _table[_cursor.delayed(0.3)] * 200,
            _table[_cursor.delayed(0.4)] * 200,
            _table[_cursor.delayed(0.5)] * 200,
        }

        multi_draw_h_ys(letters, logo,
                        off_x, off_y, ys, 60, 10)

        if _blink then
            off_x = 320
            off_y = 350
            local text = {'P', 'R', 'E', 'S', 'S'}
            multi_draw_h(letters, text, off_x + 10, off_y, 12, 2)
            text = {'A', 'N', 'Y'}
            multi_draw_h(letters, text, off_x + 82, off_y, 12, 2)
            text = {'K', 'E', 'Y'}
            multi_draw_h(letters, text, off_x + 130, off_y, 12, 2)
        end
    end

    local update = function(dt)
        _index = _cursor.update(dt)
        _blink_time = _blink_time + dt
        if _blink_time >= 0.8 then
            _blink = not _blink
            _blink_time = 0
        end
    end

    return {
        keyreleased = keyreleased,
        keypressed = keypressed,
        draw = draw,
        update = update,
    }
end

export.newGameScreen = function(state, onPause, W, H)

    local board = gameboard.newGameBoard(state, W, 20)
    local game = game.newGame(state, W, H - 20)

    local keyreleased = function (key)
        if key == 'escape' then
            onPause()
        end
    end

    local keypressed = function(key, isrepeat)
        if key == 'left' then
            game.left()
        elseif key == 'right' then
            game.right()
        elseif key == 'up' then
            game.up()
        elseif key == 'down' then
            game.down()
        end
    end

    local draw = function()
        graphics.push()
        graphics.translate(0, 0)
        board.draw()
        graphics.pop()

        graphics.push()
        graphics.translate(0, 20)
        game.draw()
        graphics.pop()
    end

    local update = function(dt)
        game.update(dt)
    end

    return {
        keyreleased = keyreleased,
        keypressed = keypressed,
        draw = draw,
        update = update,
    }
end

export.newPauseScreen = function(gameScreen, onResume, onExit)

    local keyreleased = function (key)
        if key == 'escape' then
            onExit()
        else
            onResume()
        end
    end

    local keypressed = function(key, scancode, isrepeat)
    end

    local draw = function()
        gameScreen.draw()
        graphics.print("Paused", 400, 300)
    end

    local update = function(dt)
    end

    return {
        keyreleased = keyreleased,
        keypressed = keypressed,
        draw = draw,
        update = update,
    }
end

export.newGameOverScreen = function(gameScreen, onKey)

    local keyreleased = function (key)
        onKey()
    end

    local keypressed = function(key, scancode, isrepeat)
    end

    local draw = function()
        gameScreen.draw()
        graphics.print("GAME OVER", 400, 300)
    end

    local update = function(dt)
    end

    return {
        keyreleased = keyreleased,
        keypressed = keypressed,
        draw = draw,
        update = update,
    }
end

export.newLevelCompletedScreen = function(gameScreen, onKey)

    local keyreleased = function (key)
        onKey()
    end

    local keypressed = function(key, scancode, isrepeat)
    end

    local draw = function()
        gameScreen.draw()
        graphics.print("Level completed!", 400, 300)
    end

    local update = function(dt)
    end

    return {
        keyreleased = keyreleased,
        keypressed = keypressed,
        draw = draw,
        update = update,
    }
end

export.newGameCompletedScreen = function(gameScreen, onKey)
    local keyreleased = function (key)
        onKey()
    end

    local keypressed = function(key, scancode, isrepeat)
    end

    local draw = function()
        gameScreen.draw()
        graphics.print("GAME COMPLETED", 400, 300)
    end

    local update = function(dt)
    end

    return {
        keyreleased = keyreleased,
        keypressed = keypressed,
        draw = draw,
        update = update,
    }
end

return export
