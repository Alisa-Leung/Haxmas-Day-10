local player = {
    x = 80,
    y = 0,
    width = 1,
    height = 1,
    velocityY = 0,
    isJumping = false,
    snailIndex = 1
}

local ground = { y = 0, height = 100 }
local obstacles = {}
local spawnTimer = 0
local spawnInterval = 1.5
local gameSpeed = 300
local score = 0
local highScore = 0
local gameOver = false
local gravity = 1200
local jumpForce = -500
local indexTimer = 0
local indexInterval = 0.1
local defaultTimer = 0
local defaultInterval = 0.5

local images = {}
local snailScale = 1

function love.load()
    love.window.setTitle("Haxmas Day 10: Runner")

    images.snail = {}
    images.snail[1] = love.graphics.newImage("assets/snail1.png")
    images.snail[2] = love.graphics.newImage("assets/shell1.png")
    images.snail[3] = love.graphics.newImage("assets/shell2.png")
    images.snail[4] = love.graphics.newImage("assets/shell3.png")
    images.snail[5] = love.graphics.newImage("assets/shell4.png")
    images.snail[6] = love.graphics.newImage("assets/snail2.png")
    images.salt = love.graphics.newImage("assets/salt.png")
    images.sky = love.graphics.newImage("assets/sky.png")

    local targetHeight = 100
    snailScale = targetHeight / images.snail[player.snailIndex]:getHeight()
    player.width = images.snail[player.snailIndex]:getWidth() * snailScale
    player.height = targetHeight

    ground.y = love.graphics.getHeight() - ground.height
    player.y = ground.y - player.height + 25

    love.graphics.setFont(love.graphics.newFont("assets/pixelifySans.ttf", 20))
end

function love.update(dt)
    if gameOver then return end

    score = score + dt * 10
    gameSpeed = 300 + score * 0.5

    if love.keyboard.isDown("down") then
        indexTimer = indexTimer + dt
        if indexTimer >= indexInterval then
            indexTimer = 0
            player.snailIndex = player.snailIndex + 1
            if player.snailIndex > 5 then
                player.snailIndex = 2
            end
        end
    else
        indexTimer = 0
        defaultTimer = defaultTimer + dt
        if defaultTimer >= defaultInterval then
            defaultTimer = 0
            if player.snailIndex == 1 then
                player.snailIndex = 6
            elseif player.snailIndex == 6 then
                player.snailIndex = 1
            else
                player.snailIndex = 1
            end
        end
    end

    if player.isJumping then
        player.velocityY = player.velocityY + gravity * dt
        player.y = player.y + player.velocityY * dt

        if player.y >= ground.y - player.height + 25 then
            player.y = ground.y - player.height + 25
            player.isJumping = false
            player.velocityY = 0
        end
    end

    spawnTimer = spawnTimer + dt
    if spawnTimer >= spawnInterval then
        spawnTimer = 0
        spawnInterval = math.random(10, 20) / 10
        spawnObstacle()
    end

    for i = #obstacles, 1, -1 do
        local obs = obstacles[i]
        obs.x = obs.x - gameSpeed * dt

        if obs.x + obs.width < 0 then
            table.remove (obstacles, i)
        end

        if checkCollision(player, obs) and (player.snailIndex == 1 or player.snailIndex == 6) then
            gameOver = true
            if score > highScore then
                highScore = score
            end
        end
    end
end

function love.draw()
    love.graphics.clear(1, 1, 1)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(images.sky, 0, 0)

    love.graphics.setColor(162 / 255, 222 / 255, 137 / 255)
    love.graphics.rectangle("fill", 0, ground.y, love.graphics.getWidth(), love.graphics.getHeight() - ground.y)

    love.graphics.setColor(89 / 255, 174 / 255, 101 / 255)
    love.graphics.setLineWidth(3)
    love.graphics.line(0, ground.y, love.graphics.getWidth(), ground.y)

    love.graphics.setColor(1, 1, 1)

    for _, obs in ipairs(obstacles) do
        love.graphics.draw(images.salt, obs.x, obs.y, 0,
            obs.width / images.salt:getWidth(),
            obs.height / images.salt:getHeight())
    end

    love.graphics.draw(images.snail[player.snailIndex], player. x, player.y, 0, snailScale, snailScale)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Score: " .. math.floor(score), 10, 10)
    love.graphics.print("High Score: " .. math.floor(highScore), 10, 35)

    if gameOver then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Game Over", 0, love.graphics.getHeight() / 2 - 30, love.graphics.getWidth(), "center")
        love.graphics.printf("Press [Space] to restart", 0, love.graphics.getHeight() / 2 + 10, love.graphics.getWidth(), "center")
    end
end

function love.keypressed(key)
    if key == "space" or key == "up" then
        if gameOver then
            restartGame()
        elseif not player.isJumping then
            player.isJumping = true
            player.velocityY = jumpForce
        end
    end

    if key == "escape" then
        love.event.quit()
    end
end

function spawnObstacle()
    local obstacle = {
        x = love.graphics.getWidth(),
        width = 100,
        height = 100
    }
    obstacle.y = ground.y - obstacle.height + 35
    table.insert(obstacles, obstacle)
end

function checkCollision(a, b)
    local hitbox = 20
    return a.x + hitbox < b.x + b.width - hitbox and
        a.x + a.width - hitbox > b.x + hitbox and
        a.y + hitbox < b.y + b.height - hitbox and
        a.y + a.height - hitbox > b.y + hitbox
end

function restartGame()
    gameOver = false
    score = 0
    obstacles = {}
    spawnTimer = 0
    gameSpeed = 300
    player.y = ground.y - player.height + 25
    player.isJumping = false
    player.velocityY = 0
end