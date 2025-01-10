function love.load()
    require("layouts")
    require("player")
    require("enemy")

    math.randomseed(os.time())

    ScreenWidth = love.graphics.getWidth()
    ScreenHeight = love.graphics.getHeight()

    ButtonFont = love.graphics.newFont(20)

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
        },
        StatusButtonLayout = {
            x = 0,
            y = 500,
            width = ScreenWidth/4,
            height = 50,
            placement = 500 + ((50/2)/2) - 20/2
        },
        ControlsLayout = {
            x = 0,
            y = ScreenHeight-50,
        }
    }

    -- State = 0 (Menu) / 1 (Game Start)
    GameState = {}
    GameState.State = 0
    GameState.Timer = 0
    GameState.Stats = false

    Player:Init((Layouts.GameWindowLayout.width/2) - 10, (Layouts.GameWindowLayout.height/2) + 50)
    
    Enemys = {}
    Projectiles = {}

    TickCounter = 0
    TickDuration = 0.5

    NearestEnemy = nil
    LastAttackTime = 0
    LastHealthTime = 0

    GameTimer = 0
end

function love.update(dt)

    -- Game is Running
    if GameState.State == 1 then
        GameState.Timer = GameState.Timer + dt
        
        -- Auto Attacking
        if Player.abilities.auto and Player.abilities.autoOn then
            LastAttackTime = LastAttackTime + dt
            local interval = 1 / Player.attackSpeed
            if LastAttackTime >= interval then
                print("Attack Speed Interval: " ..interval)
                NearestEnemy = FindNearestEnemy()
                if NearestEnemy ~= nil then
                    SpawnProjectile(false)
                end
                LastAttackTime = LastAttackTime - interval
            end
        end
    
        -- Health Regen
        if Player.healthRegen > 0 and Player.hp < Player.maxHp then
            LastHealthTime = LastHealthTime + dt
            local interval = 1 / Player.healthRegen
            if LastHealthTime >= interval then
                print("Health Regen Interval: " ..interval)
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
                    GameEnd()
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
                        Player.killCount = Player.killCount + 1
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
end

function love.draw()

    Header()
    Footer()

    if GameState.State == 0 then
        
        ControlsLayout( "q) Quit | s) Start | c) Stats" )

    elseif GameState.State == 1 then

        for _, e in ipairs(Enemys) do
            love.graphics.setColor(1,0,0)
            love.graphics.rectangle("fill", e.x, e.y, 10, 10)
        end
    
        for _, p in ipairs(Projectiles) do
            love.graphics.setColor(0,1,0)
            love.graphics.rectangle("fill", p.x, p.y, 10, 10)
        end

        Healthbar()
        ControlsLayout( "q) Quit | v) Auto Shoot | c) Stats" )
    end

    DrawPlayer()

    if GameState.Stats then
        StatsPopup()
    end
end

function GameStart()
    print( "Game Starting ")
    GameState.State = 1
    GameState.Timer = 0
    Player.hp = Player.maxHp
end

--[[
TODO: If player dies by enemy. Game crashes
if player quits, game is fine.
--]]
function GameEnd()
    print( "Game Ending ")
    GameState.State = 0
    GameState.Timer = 0
    Player.hp = Player.maxHp
    for k in pairs(Enemys) do
        Enemys[k] = nil
    end
    for k in pairs(Projectiles) do
        Projectiles[k] = nil
    end
end

-- Handles all key press events
function love.keypressed(key)
    print("Key pressed: " .. key)

    if GameState.State == 0 then
        if key == "s" or key == "S" then
            GameStart()
        end
    end

    if GameState.State == 1 then
        if key == "v" or key == "V" and Player.abilities.auto then
            Player.abilities.autoOn = not Player.abilities.autoOn
        elseif key == 'q' or key == 'Q' then
            GameEnd()
        -- dev
        elseif key == "space" then
            local enemy = Enemy:SpawnEnemy()
            table.insert(Enemys, enemy)
        end
    end

    -- dev
    if key == "escape" then
        love.event.quit()
    end

    -- Handling Stats Scren
    if GameState.Stats then
        if (key == "q" or key == "Q") then
            GameState.Stats = not GameState.Stats
        elseif key == "c" or key == "C" then
            GameState.Stats = not GameState.Stats
        end
        return
    end

    if key == "c" or key == "C" then
        GameState.Stats = not GameState.Stats
    end

end

--[[
Handles all mouse clicking events
1: left click
2L right click
--]]
function love.mousepressed( x, y, button )
    if button == 1 then
        if Player.abilities.autoOn == false then
            SpawnProjectile(true)
        end

        if MouseInButton(Layouts.StatusButtonLayout) then
            GameState.Stats = not GameState.Stats
        end
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

-- Returns True/False if mouse x,y is within button x,y
function MouseInButton(button)
    return love.mouse.getX() >= button.x
    and love.mouse.getX() < button.x + button.width
    and love.mouse.getY() >= button.y
    and love.mouse.getY() < button.y + button.height
end

function EndGame()
    return
    -- print( "Game ended, removing all objects" )
    -- -- Remove all enemies
    -- Enemys = nil

    -- -- Remove all projectiles
    -- Projectiles = nil
end