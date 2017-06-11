-- Import section
local screens = require 'screens'
local gamestate = require 'gamestate'

-- No more external access
setfenv(1, {})

local export = {}

export.newController = function(love, W, H)
    local me = {}

    local currentGameState
    local currentGameScreen

    local function attachScreen(screen)
        love.keyreleased = screen.keyreleased
        love.keypressed = screen.keypressed
        love.update = screen.update
        love.draw = screen.draw
    end

    me.startGame = function()
        currentGameState = gamestate.newGameState(me.gameOver,
                                                  me.levelCompleted,
                                                  me.gameCompleted)
        currentGameScreen = screens.newGameScreen(currentGameState,
                                                  me.pauseGame,
                                                  W, H)
        attachScreen(currentGameScreen)
    end

    me.mainMenu = function()
        attachScreen(screens.newMainMenuScreen(me.startGame))
    end

    me.pauseGame = function()
        attachScreen(screens.newPauseScreen(currentGameScreen,
                                           me.resumeGame,
                                           me.mainMenu))
    end

    me.resumeGame = function()
        attachScreen(currentGameScreen)
    end

    me.nextLevel = function()
        currentGameScreen = screens.newGameScreen(currentGameState,
                                                  me.pauseGame,
                                                  W, H)
        attachScreen(currentGameScreen)
    end

    me.levelCompleted = function()
        attachScreen(screens.newLevelCompletedScreen(currentGameScreen,
                                                     me.nextLevel))
    end

    me.gameCompleted = function()
        attachScreen(screens.newGameCompletedScreen(currentGameScreen,
                                                    me.mainMenu))
    end

    me.gameOver = function()
        attachScreen(screens.newGameOverScreen(currentGameScreen,
                                               me.mainMenu))
    end

    return me
end

return export
