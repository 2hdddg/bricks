-- Import section
local graphics = love.graphics
local physics = love.physics
local audio = love.audio
local sprites = require 'sprites'
local pairs = pairs
local print = print
local table = table
local math = math

-- No more external access
setfenv(1, {})

local export = {}

local blocks = sprites.get_blocks()

local function constantSpeed(body, speed, boost_x, boost_y)
    local vel_x, vel_y

    vel_x, vel_y = body:getLinearVelocity()

    local actualSpeed = math.abs(vel_x) + math.abs(vel_y)
    local diff  = actualSpeed - speed
    local fact = diff / speed
    if diff < 0 then
        vel_x = vel_x * (1 + fact)
        vel_y = vel_y * (1 + fact)
    elseif diff > 0 then
        vel_x = vel_x * fact * -1
        vel_y = vel_y * fact * -1
    end
    body:applyForce(vel_x + boost_x, vel_y + boost_y)
end

local function drawBoundingBox(fixture)
    local x1, x2
    local y1, y2

    x1, y1, x2, y2 = fixture:getBoundingBox()
    graphics.rectangle('line', x1, y1, x2 - x1, y2 - y1)
end

export.newBall = function (world, x, y)
    local ball = { name = 'ball' }
    local body, shape, fixture
    local speed = 250
    local boost_x = 0
    local boost_y = 0
    local is_locked = true

    body = physics.newBody(world, x, y, "dynamic")
    shape = physics.newCircleShape(9)
    fixture = physics.newFixture(body, shape)
    fixture:setUserData(ball)
    -- Bounciness
    fixture:setRestitution(1)
    -- No decrease in speed and initial speed
    body:setLinearDamping(0)
    body:setAngularDamping(0)
    body:setLinearVelocity(0, speed)
    body:setAngularVelocity(0)
    -- Avoid problem with ball getting trapped
    -- in the bat
    body:setBullet(true)
    body:resetMassData()

    local function hit(other)
    end

    local function update(dt)
        if is_locked then
            body:setLinearVelocity(0, 0)
        else
            constantSpeed(body, speed, boost_x, boost_y)
            boost_x = 0
            boost_y = 0
        end
    end

    local function draw()
        local x = body:getX() - 12
        local y = body:getY() - 12
        graphics.draw(blocks.image, blocks.map['ball'],
                      x, y, 0, 3, 3)
    end

    local function drawShape()
        drawBoundingBox(fixture)
    end

    local function boost(x, y)
        boost_x = x
        boost_y = y
    end

    local function lock(x, y)
        is_locked = true
        body:setX(x)
        body:setY(y)
    end

    local function release(x, y)
        is_locked = false
        boost_x = x
        boost_y = y
    end

    ball.hit = hit
    ball.update = update
    ball.draw = draw
    ball.drawShape = drawShape
    ball.boost = boost
    ball.lock = lock
    ball.release = release

    return ball
end

export.newBat = function(world, x, H, ball)
    local speed = 0
    local max_speed = 280
    local me = { name = 'bat' }
    local body, shape, fixture1, fixture2, fixture3
    local bat = blocks.map['bat']
    local has_ball = true
    local hitBatSound = audio.newSource('hitbat.wav', 'static')

    body = physics.newBody(world, x, H - 30, "dynamic")
    shape = physics.newRectangleShape(0, 3, 64, 20+10)
    fixture1 = physics.newFixture(body, shape)
    shape = physics.newRectangleShape(-47, 0, 28, 36)
    fixture2 = physics.newFixture(body, shape)
    shape = physics.newRectangleShape(47, 0, 28, 36)
    fixture3 = physics.newFixture(body, shape)
    body:setFixedRotation(true)

    fixture1:setUserData(me)
    fixture2:setUserData(me)
    fixture3:setUserData(me)
    -- Bounciness
    fixture1:setRestitution(1.2)
    fixture2:setRestitution(1.2)
    fixture3:setRestitution(1.2)

    body:setLinearDamping(max_speed/100)
    body:resetMassData()

    local function hit(other)
        if other.name == 'ball' then
            hitBatSound:play()
        end
    end

    local function update(dt)
        if speed > 0 or speed < 0 then
            body:setLinearVelocity(speed, 0)
            speed = 0
        end

        if has_ball then
            local x = body:getX()
            local y = body:getY() - 22
            ball.lock(x, y)
        end
    end

    local function left()
        speed = -max_speed
    end

    local function right()
        speed = max_speed
    end

    local function up()
        if has_ball then
            has_ball = false
            ball.release(100, -9000)
        end
    end

    local function down()
    end

    local function draw()
        x = body:getX() - 64
        y = body:getY() - 20
        graphics.draw(blocks.image, bat, x, y, 0, 2, 2)
    end

    local function drawShape()
        drawBoundingBox(fixture1)
        drawBoundingBox(fixture2)
        drawBoundingBox(fixture3)
    end

    local function lockBall()
        has_ball = true
    end

    me.hit = hit
    me.update = update
    me.draw = draw
    me.drawShape = drawShape
    me.left = left
    me.right = right
    me.up = up
    me.down = down
    me.lockBall = lockBall

    return me
end

export.newWalls = function(world, W, H, shaker)
    local walls = {}
    local hitWallSound = audio.newSource('hitwall.wav', 'static')

    local function newWall(x, y, cx, cy, vx, vy, shake)
        local wall = { name = 'wall' }
        local body, shape, fixture

        body = physics.newBody(world, x, y)
        shape = physics.newRectangleShape(cx, cy)
        fixture = physics.newFixture(body, shape)
        fixture:setUserData(wall)
        -- Bounciness
        fixture:setRestitution(1.1)

        local function hit(other)
            if other.name == 'ball' then
                hitWallSound:play()
                other.boost(vx, vy)
                shake()
            elseif other.name == 'bat' then
                hitWallSound:play()
                shake()
            end
        end

        local function drawShape()
            drawBoundingBox(fixture)
        end

        wall.drawShape = drawShape
        wall.hit = hit

        return wall
    end

    local function draw()
    end

    local function update(dt)
    end

    local function drawShape()
        walls.left.drawShape()
        walls.top.drawShape()
        walls.right.drawShape()
    end

    walls.left = newWall(2, H / 2, 5, H, 0, 80, shaker.left)
    walls.top = newWall(W / 2, 2, W, 5, 20, 0, shaker.up)
    walls.right = newWall(W - 2, H / 2, 5, H, 0, 80, shaker.right)
    walls.draw = draw
    walls.drawShape = drawShape

    return walls
end

export.newBricks = function(world, gamestate, onDestroyed)
    local bricks = {}
    local num = 0
    local hitBrickSound = audio.newSource('hitbrick.wav', 'static')
    local dying_time = 0.3

    local function empty()
    end

    local function newBrick(x, y)
        local brick = { name = 'brick '}
        local body, shape, fixture
        local dying = 0
        local dead = false

        body = physics.newBody(world, x, y)
        shape = physics.newRectangleShape(64, 32)
        fixture = physics.newFixture(body, shape)
        fixture:setUserData(brick)
        body:resetMassData()
        body:setMass(body:getMass() * 100)

        local function update(dt)
        end

        local function update_dying(dt)
            dying = dying + dt

            if dying > dying_time then
                brick.update = empty
                dead = true
            end
        end

        local function draw()
            local x = body:getX() - 32
            local y = body:getY() - 16
            graphics.draw(blocks.image, blocks.map['brick1'],
                          x, y, 0, 2, 2)
        end

        local function draw_dying()
            if dead then
                body:destroy()
                brick.draw = empty
                brick.drawShape = empty
                return
            end

            local how_dead = 1 - (dying / dying_time)
            local x = body:getX() - (32 * how_dead)
            local y = body:getY() - (16 * how_dead)
            graphics.draw(blocks.image, blocks.map['brick1'],
                          x, y, 6 * how_dead, 2 * how_dead, 2 * how_dead)
        end

        local function hit(other)
            if other.name == 'ball' then
                hitBrickSound:play()
                gamestate.addScore(10)
                num = num - 1
                if num == 0 then
                    onDestroyed()
                end

                -- Only track first hit
                brick.hit = empty
                brick.update = update_dying
                brick.draw = draw_dying
            end
        end

        local function drawShape()
            drawBoundingBox(fixture)
        end

        brick.update = update
        brick.draw = draw
        brick.drawShape = drawShape
        brick.hit = hit

        return brick
    end

    local function renderLevel()
        local y = 30
        local x
        local cx = 64 + 10
        local cy = 32 + 10
        local row
        local col
        local level = gamestate.level

        for row = 1, #level.bricks do
            x = 65
            for col = 1, #level.bricks[row] do
                local b = level.bricks[row][col]

                if b == '1' then
                    table.insert(bricks, newBrick(x, y))
                    num = num + 1
                end
                x = x + cx
            end
            y = y + cy
        end
    end

    local function draw()
        for i, b in pairs(bricks) do
            b.draw()
        end
    end

    local function drawShape()
        for i, b in pairs(bricks) do
            b.drawShape()
        end
    end

    local function update(dt)
        for i, b in pairs(bricks) do
            b.update(dt)
        end
    end

    renderLevel()

    return {
        update = update,
        draw = draw,
        drawShape = drawShape
    }
end

export.newVoid = function(world, x, y, cx, cy, onLostBall)
    local void = { name = 'void' }
    local body, shape, fixture
    local lostBallSound = audio.newSource('lostball.wav', 'static')

    body = physics.newBody(world, x, y)
    shape = physics.newRectangleShape(cx, cy)
    fixture = physics.newFixture(body, shape)
    fixture:setUserData(void)

    local function hit(other)
        if other.name == 'ball' then
            lostBallSound:play()
            onLostBall()
        end
    end

    local function drawShape()
        drawBoundingBox(fixture)
    end

    void.drawShape = drawShape
    void.hit = hit

    return void
end

return export
