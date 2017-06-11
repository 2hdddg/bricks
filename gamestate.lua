
-- Import section
local levels = require 'levels'
local print = print

-- No more external access
setfenv(1, {})

local export = {}

export.newGameState = function(onGameOver,
                               onCompletedLevel,
                               onCompletedGame)
    local me = {}
    local index = 1

    me.score = 0
    me.lives = 3
    me.level = levels.getLevel(index)

    local function lostLife()
        me.lives = me.lives - 1
        if me.lives <= 0 then
            onGameOver()
        end
    end

    local function addScore(s)
        me.score = me.score + s
    end

    local function completedLevel()
        if levels.isLast(index) then
            onCompletedGame()
        else
            index = index + 1
            me.level = levels.getLevel(index)
            onCompletedLevel()
        end
    end

    me.lostLife = lostLife
    me.addScore = addScore
    me.completedLevel = completedLevel

    return me
end

return export
