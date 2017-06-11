-- Import section
local physics = love.physics
local print = print
local objects = require 'gameobjects'

-- No more external access
setfenv(1, {})

local export = {}

export.newGame = function(state, W, H)
    local world
    local ball, bat, walls, bricks, void

    local function collision (f1, f2, contact)
        local o1 = f1:getUserData()
        local o2 = f2:getUserData()

        o1.hit(o2)
        o2.hit(o1)
    end

    local function update(dt)
        ball.update(dt)
        bat.update(dt)
        bricks.update(dt)

        world:update(dt)
    end

    local function draw()
        bat.draw()
        -- Draw ball after bat, looks nicer when
        -- ball is locked.
        ball.draw()
        bricks.draw()

        --bat.drawShape()
        --ball.drawShape()
        --walls.drawShape()
        --bricks.drawShape()
        --void.drawShape()
    end

    -- When ball is lost
    local function lostBall()
        state.lostLife()
        bat.lockBall()
    end

    -- When all bricks are destroyed
    local function allDestroyed()
        state.completedLevel()
    end

    world = physics.newWorld(0, 0, true)
    ball = objects.newBall(world, W / 2, (H / 4) * 3)
    bat  = objects.newBat(world, W / 2, H, ball)
    walls = objects.newWalls(world, W, H)
    void = objects.newVoid(world, W / 2, H - 2, W, 5, lostBall)
    bricks = objects.newBricks(world, state, allDestroyed)

    world:setCallbacks(collision)
    return {
        update = update,
        draw = draw,
        left = bat.left,
        right = bat.right,
        up = bat.up,
        down = bat.down,
    }
end

return export
