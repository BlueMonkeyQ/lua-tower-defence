function love.load()
    require("layouts")
    require("player")
    require("enemy")

    math.randomseed(os.time())

    ScreenWidth = love.graphics.getWidth()
    ScreenHeight = love.graphics.getHeight()

    Layouts = {
        GameWindowLayout = {
            x = 0,
            y = 50,
            width = ScreenWidth,
            height = 400,
        },
        HeaderLayout = {
            x = 0,
            y = 0,
            width = ScreenWidth,
            height = 50,
        },
        PopupLayout = {
            x = 50,
            y = 50,
            width = 700,
            height = 500,
        },
        FooterLayout = {
            x = 0,
            y = 450,
            width = ScreenWidth,
            height = 150,
        },
        HealthBarLayout = {
            x = 0,
            y = 450,
            width = ScreenWidth,
            height = 50,
        }
    }

    GameState = {}
    GameState.State = 0
    GameState.Popup = false

    Player:Init((Layouts.GameWindowLayout.width/2) - 10, (Layouts.GameWindowLayout.height/2) + 50)
    
    Enemys = {}
    Projectiles = {}

    Sprites = {}
    Sprites.background = love.graphics.newImage("data/sprites/background.jpg")
    Sprites.enemy = love.graphics.newImage("data/sprites/enemy.png")

    TickCounter = 0
    TickDuration = 0.5

    NearestEnemy = nil
    LastAttackTime = 0
    LastHealthTime = 0
end

function love.update(dt)
    
    if Player.abilities.auto and Player.abilities.autoOn then
        LastAttackTime = LastAttackTime + dt
        local interval = 1 / Player.attackSpeed
        if LastAttackTime >= interval then
            NearestEnemy = FindNearestEnemy()
            if NearestEnemy ~= nil then
                SpawnProjectile(false)
            end
            LastAttackTime = LastAttackTime - interval
        end
    end

    if Player.healthRegen > 0 and Player.hp < Player.maxHp then
        LastHealthTime = LastHealthTime + dt
        local interval = 1 / Player.healthRegen
        if LastHealthTime >= interval then
            Player:addHp(1)
            LastHealthTime = LastHealthTime - interval
        end
    end

    -- Update Enemy postion to player
    for i = #Enemys, 1, -1 do
        local e = Enemys[i]
        e.x = e.x + (math.cos( EnemyPlayerAngel(e) ) * e.speed * dt)
        e.y = e.y + (math.sin( EnemyPlayerAngel(e) ) * e.speed * dt)

        -- Detect Collision with player
        if DistanceBetween(e.x, e.y, Player.x, Player.y) < 10 then
            print("Enemy " .. i .. " Collided, deleting enemy")
            Player:removeHp(e.damage)
            table.remove(Enemys, i)

            if Player.dead then
                print( "Player is Dead" )
                EndGame()
            end
        end
    end

    -- Update Projectile postion
    for _, p in ipairs(Projectiles) do
        p.x = p.x + (math.cos( p.direction ) * p.speed * dt)
        p.y = p.y + (math.sin( p.direction ) * p.speed * dt)
    end

    -- Check if any projectiles are out of bounds
    for i = #Projectiles, 1, -1 do
        local p = Projectiles[i]
        if p.x < Layouts.GameWindowLayout.x or p.y < Layouts.GameWindowLayout.y or p.x > ScreenWidth or p.y > (Layouts.GameWindowLayout.y + Layouts.GameWindowLayout.height) then
            print("Projectile " .. i .. " Out of bounds, deleting projectile")
            table.remove(Projectiles, i)
        end
    end

    -- Check if any projectiles collide with enemy
    for i = #Enemys, 1, -1 do
        local e = Enemys[i]
        for j, p in ipairs(Projectiles) do
            if DistanceBetween( e.x, e.y, p.x, p.y ) < 10 then
                print ( "Projectile " .. j .. " collided with enemy " .. i )
                e:RemoveHp(1)
                if e.dead then
                    print( "Enemy Killed +" ..e.xp .."xp " .. e.gold .. "$")
                    Player.gold = Player.gold + e.gold
                    table.remove(Enemys, i)
                end
                p.dead = true
            end
        end
    end

    -- Remove any enemies flagged dead
    for i = #Enemys, 1, -1 do
        local e = Enemys[i]
        if e.dead then
            print( "Removing enemy " .. i)
            table.remove(Enemys, i)
        end
    end

    -- Remove any projectiles flagged dead
    for i = #Projectiles, 1, -1 do
        local p = Projectiles[i]
        if p.dead then
            print( "Removing projectile " .. i)
            table.remove(Projectiles, i)
        end
    end
end

function love.draw()
    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", Player.x, Player.y, 10, 10)

    for _, e in ipairs(Enemys) do
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("fill", e.x, e.y, 10, 10)
    end

    for _, p in ipairs(Projectiles) do
        love.graphics.setColor(0,1,0)
        love.graphics.rectangle("fill", p.x, p.y, 10, 10)
    end

    Header()
    Footer()
    Healthbar()

    if GameState.Popup then
        Popup()
    end
end

-- Handles all key press events
function love.keypressed(key)
    print("Key pressed: " .. key)

    if key == "escape" then
        love.event.quit()
    end

    if key == "space" then
        local enemy = Enemy:SpawnEnemy()
        table.insert(Enemys, enemy)
    end

    if GameState.Popup then
        if (key == "q" or key == "Q") then
            GameState.Popup = not GameState.Popup
        elseif key == "c" or key == "C" then
            GameState.Popup = not GameState.Popup
        end
        return
    end

    if key == "c" or key == "C" then
        GameState.Popup = not GameState.Popup
    end

    if key == "v" or key == "V" and Player.abilities.auto then
        Player.abilities.autoOn = not Player.abilities.autoOn
    end

end

--[[
Handles all mouse clicking events
1: left click
2L right click
--]]
function love.mousepressed( x, y, button )
    if button == 1 then
        SpawnProjectile(true)
    end
end

--[[
Creates projectile object and adds to Projectiles Table.
--]]
function SpawnProjectile(userInput)

    local projectile = {}
    projectile.x = Player.x
    projectile.y = Player.y
    projectile.speed = 500

    if userInput then
        projectile.direction = MouseAngle()
    else
        projectile.direction = EnemyPlayerAngel(NearestEnemy) + math.pi
    end

    projectile.dead = false
    print( "Spawning Projectile in Direction: " .. projectile.direction )
    table.insert(Projectiles, projectile)
end

function FindNearestEnemy()
    local closest = 0
    local index = nil
    local enemy = nil
    for i, e in ipairs(Enemys) do
        local distance = DistanceBetween(e.x, e.y, Player.x, Player.y)
        if i == 1 then
            closest = distance
            index = i
            enemy = e
        end

        if distance < closest then
            closest = distance
            index = i
            enemy = e
        end
    end

    if enemy == nil then
        print("No enemys nearby")
        return nil
    else
        print("Nearest Enemy " .. index .. " x: " .. enemy.x .. " y: " .. enemy.y)
        return enemy
    end
end

-- Returns the arc tangent of the player to the enemy
function EnemyPlayerAngel(enemy)
    return math.atan2( Player.y - enemy.y, Player.x - enemy.x )
end

-- Returns the arc tangent of the player to mouse positon
function MouseAngle()
    return math.atan2( Player.y - love.mouse.getY(), Player.x - love.mouse.getX() ) + math.pi
end

-- Returns the distance between two coordinates
function DistanceBetween(x1, y1, x2, y2)
    return math.sqrt( (x2 - x1)^2 +  (y2 - y1)^2 )
end

function EndGame()
    return
    -- print( "Game ended, removing all objects" )
    -- -- Remove all enemies
    -- Enemys = nil

    -- -- Remove all projectiles
    -- Projectiles = nil
end