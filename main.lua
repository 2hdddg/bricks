

function newMainMenuScreen(onGame)
    local self = {}

    local keyreleased = function (key)
        if key == 'escape' then
            love.event.quit()
        end
         onGame()
    end

    local draw = function()
        love.graphics.print("Press any key to start", 400, 300)
    end

    local update = function(dt)
    end

    return {
        keyreleased = keyreleased,
        draw = draw,
        update = update,
    }
end

local motiontable = require 'motiontable'

function newGameScreen(onPause)
    local _table_size = 100
    local _table = motiontable.sine_table(_table_size)
    local _cursor = motiontable.newCursor(_table_size, 0, 2)
    local _cursorX = motiontable.newCursor(_table_size, 70, 2)
    local _motion = 0
    local _motion2 = 0

    local keyreleased = function (key)
        if key == 'escape' then
            onPause()
        end
    end

    local draw = function()
        local y = 0 + _motion * 200
        local x = 0 + _motion2 * 500
        love.graphics.print("In game", x, y)
    end

    local update = function(dt)
        _motion = _table[_cursor.update(dt)]
        _motion2 = _table[_cursorX.update(dt)]
    end

    return {
        keyreleased = keyreleased,
        draw = draw,
        update = update,
    }
end

function newPauseScreen(onResume, onExit)
    local self = {}

    local keyreleased = function (key)
        if key == 'escape' then
            onExit()
        else
            onResume()
        end
    end

    local draw = function()
        love.graphics.print("Paused", 400, 300)
    end

    local update = function(dt)
    end

    return {
        keyreleased = keyreleased,
        draw = draw,
        update = update,
    }
end

_screen = 0

function love.load()
    local onResume
    local onPause
    local onGame
    local onExit

    onResume = function()
        _screen = newGameScreen(onPause)
    end

    onExit = function()
        _screen = newMainMenuScreen(onGame)
    end

    onPause = function()
        _screen = newPauseScreen(onResume, onExit)
    end

    onGame = function ()
        _screen = newGameScreen(onPause)
    end

    _screen = newMainMenuScreen(onGame)
end

function love.keyreleased(key)
    _screen.keyreleased(key)
end

function love.update(dt)
    _screen.update(dt)
end

function love.draw()
    _screen.draw()
end

