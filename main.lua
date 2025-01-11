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
        },
        DebugLayout = {
            x = 0,
            y = 50,
            width = ScreenWidth/5,
            height = 50,
        }
    }

    -- State = 0 (Menu) / 1 (Game Start)
    GameState = {}
    GameState.State = 0
    GameState.Timer = 0
    GameState.Stats = false
    GameState.Debug = true
    GameState.Buy = false
    GameState.Wave = 0
    GameState.NumEnemies = 0
    GameState.CreatedEnemies = 0
    GameState.WaveTimer = 0
    GameState.GameSpeed = 1
    GameState.Enemys = {}
    GameState.Projectiles = {}
    GameState.Chains = {}

    Player:Init((Layouts.GameWindowLayout.width/2) - 10, (Layouts.GameWindowLayout.height/2) + 50)

    EnemyIdCounter = 1
    ProjectileIdCounter = 1

    NextWaveTime = 15
    NextSpawnTime = 1

    NearestEnemy = nil
    LastAttackTime = 0
    LastHealthTime = 0

    GameTimer = 0
end

function love.update(dt)

    -- Game is Running
    if GameState.State == 1 then
        GameState.Timer = GameState.Timer + dt * GameState.GameSpeed
        GameState.WaveTimer = GameState.WaveTimer + dt * GameState.GameSpeed

        if #GameState.Enemys > 0 then
            print( "---------- Enemy List ----------")
            for _, e in ipairs(GameState.Enemys) do
                print("Enemy " .. e.id)
            end
            print( "----------  ----------")
        end


        if Player.dead then
            GameState.Enemys = {}
            GameState.Projectiles = {}
            GameEnd()
        end

        -- 
        if GameState.WaveTimer >= NextSpawnTime and GameState.CreatedEnemies < GameState.NumEnemies then
            local numEnemies = math.floor(GameState.NumEnemies * (NextWaveTime/100))
            print( "Spawning " .. numEnemies .. " Enemies" )
            for i = 1, numEnemies, 1 do
                local enemy = Enemy:SpawnEnemy()
                table.insert(GameState.Enemys, enemy)
                GameState.CreatedEnemies = GameState.CreatedEnemies + 1
            end
            NextSpawnTime = NextSpawnTime + 1
            print( "Created Enemies " .. GameState.CreatedEnemies)
        end

        -- 
        if GameState.WaveTimer >= NextWaveTime and #GameState.Enemys == 0 then
            WaveStart()
        end
          
        -- Auto Attacking
        if Player.abilities.auto and Player.abilities.autoOn then
            LastAttackTime = LastAttackTime + dt * GameState.GameSpeed
            local interval = 1 / Player.attackSpeed
            if LastAttackTime >= interval then
                print("Attack Speed Interval: " ..interval)
                NearestEnemy = FindNearestEnemy()
                if NearestEnemy ~= nil then
                    SpawnProjectile()
                end
                LastAttackTime = LastAttackTime - interval
            end
        end
    
        -- Health Regen
        if Player.healthRegen > 0 and Player.hp < Player.maxHp then
            LastHealthTime = LastHealthTime + dt * GameState.GameSpeed
            local interval = 1 / Player.healthRegen
            if LastHealthTime >= interval then
                print("Health Regen Interval: " ..interval)
                Player:addHp(1)
                LastHealthTime = LastHealthTime - interval
            end
        end
    
        -- Update Enemy postion to player
        for i = #GameState.Enemys, 1, -1 do
            local e = GameState.Enemys[i]
            e.x = e.x + (math.cos( EnemyPlayerAngel(e) ) * e.speed * (dt * GameState.GameSpeed))
            e.y = e.y + (math.sin( EnemyPlayerAngel(e) ) * e.speed * (dt * GameState.GameSpeed))
    
            -- Detect Collision with player
            if DistanceBetween(e.x, e.y, Player.x, Player.y) < 10 then
                print("Enemy " .. i .. " Collided, deleting enemy")
                Player:removeHp(e.damage)
                table.remove(GameState.Enemys, i)
                if Player.dead then
                    return
                end
            end
        end
    
        -- Update Projectile postion
        for i, p in ipairs(GameState.Projectiles) do
            p.x = p.x + (math.cos( p.direction ) * p.speed * (dt * GameState.GameSpeed))
            p.y = p.y + (math.sin( p.direction ) * p.speed * (dt * GameState.GameSpeed))

            -- Check for Enemy Collision
            for _, e in ipairs(GameState.Enemys) do
                if DistanceBetween(e.x, e.y, p.x, p.y) < 10 then
                    print( "Projectile " ..p.id .. " collided with Enemy " ..e.id )
                    e:RemoveHp(Player.damage)
                    Player:Abilities(e)

                    table.remove(GameState.Projectiles, i)
                    i = i -1
                end
            end
        
            -- Check for Out of Bounds
            if p.x < Layouts.GameWindowLayout.x or p.y < Layouts.GameWindowLayout.y or p.x > ScreenWidth or p.y > (Layouts.GameWindowLayout.y + Layouts.GameWindowLayout.height) then
                print("Projectile " .. i .. " Out of bounds, deleting projectile")
                table.remove(GameState.Projectiles, i)
                i = i -1
            end
        end

        for i, e in ipairs(GameState.Enemys) do
            if e.dead then
                table.remove(GameState.Enemys, i)
            end
        end

        local currentTime = love.timer.getTime()
        for i = #GameState.Chains, 1, -1 do
            local chain = GameState.Chains[i]
            if currentTime - chain.startTime >= .1 then
                table.remove(GameState.Chains, i)
            end
        end
    end
end

function love.draw()

    Header()
    Footer()

    if GameState.State == 0 then
        
        ControlsLayout( "q) Quit | s) Start | c) Stats | b) Buy" )

    elseif GameState.State == 1 then

         -- Handles chain lines
        for _, chain in ipairs(GameState.Chains) do
            love.graphics.setColor(1, 0, 0)
            love.graphics.line(chain.startEnemy.x, chain.startEnemy.y, chain.endEnemy.x, chain.endEnemy.y)
        end
        -- Handles Spawned Enemies
        for _, e in ipairs(GameState.Enemys) do
            local alpha = e.hp / e.maxHp -- Gets the Transparency of the enemy on % health left
            local vertices = e:Shape(10)

            love.graphics.setColor(1,0,0, alpha)
            love.graphics.polygon("fill", vertices)
            
            love.graphics.setColor(1,0,0,1)
            love.graphics.polygon("line", vertices)
        end
    
        for _, p in ipairs(GameState.Projectiles) do
            love.graphics.setColor(0,1,0)
            love.graphics.rectangle("fill", p.x, p.y, 10, 10)
        end

        Healthbar()
        ControlsLayout( "q) Quit | v) Auto Shoot | c) Stats" )
    end

    DrawPlayer()

    if GameState.Stats then
        StatsWindow()
    elseif GameState.Buy then
        BuyWindow()
    end

    if GameState.Debug then
        DebugWindow()
    end
end

function GameStart()
    print( "Game Starting ")
    GameState.State = 1
    GameState.Timer = 0
    Player.hp = Player.maxHp
    WaveStart()
end

--[[
TODO: If player dies by enemy. Game crashes
if player quits, game is fine.
--]]
function GameEnd()
    print( "Game Ending ")
    GameState.State = 0
    GameState.Timer = 0
    GameState.Wave = 0
    GameState.NumEnemies = 0
    Player.dead = false
    Player.hp = Player.maxHp
end

-- Handles all key press events
function love.keypressed(key)
    print("Key pressed: " .. key)

    if GameState.Buy then -- Handling Buy Window
        if (key == "q" or key == "Q") then
            GameState.Buy = not GameState.Buy
        elseif key == "b" or key == "B" then
            GameState.Buy = not GameState.Buy
        end

    elseif GameState.Stats then -- Handling Stats Window
        if (key == "q" or key == "Q") then
            GameState.Stats = not GameState.Stats
        elseif key == "c" or key == "C" then
            GameState.Stats = not GameState.Stats
        end

    elseif GameState.State == 0 then -- Main Menu
        if key == "s" or key == "S" then
            GameStart()
        elseif key == "b" or key == "B" then
            GameState.Buy = not GameState.Buy
        elseif key == "c" or key == "C" then
            GameState.Stats = not GameState.Stats
        end
    
    elseif GameState.State == 1 then -- Running Game
        if key == "v" or key == "V" and Player.abilities.auto then
            Player.abilities.autoOn = not Player.abilities.autoOn
        elseif key == 'q' or key == 'Q' then
            GameEnd()
        elseif key == "c" or key == "C" then
            GameState.Stats = not GameState.Stats
        -- dev
        elseif key == "1" then
            GameState.GameSpeed = 1
        elseif key == "2" then
            GameState.GameSpeed = 2
        elseif key == "3" then
            GameState.GameSpeed = 3
        end
    end


    -- dev
    if key == "escape" then
        love.event.quit()
    elseif key == "d" then
        GameState.Debug = not GameState.Debug
    end
end

--[[
Creates projectile object and adds to Projectiles Table.
--]]
function SpawnProjectile()

    local projectile = {}
    projectile.id = #GameState.Projectiles + 1
    projectile.x = Player.x
    projectile.y = Player.y
    projectile.speed = 500
    projectile.direction = EnemyPlayerAngel(NearestEnemy) + math.pi
    projectile.dead = false
    table.insert(GameState.Projectiles, projectile)

    if Player.abilities.spread then
        local projectile2 = {}
        projectile2.id = #GameState.Projectiles + 1
        projectile2.x = projectile.x
        projectile2.y = projectile.y
        projectile2.speed = 500
        projectile2.direction = projectile.direction + math.rad(10)
        projectile2.dead = false
        table.insert(GameState.Projectiles, projectile2)

        local projectile3 = {}
        projectile3.id = #GameState.Projectiles + 1
        projectile3.x = projectile.x
        projectile3.y = projectile.y
        projectile3.speed = 500
        projectile3.direction = projectile.direction - math.rad(10)
        projectile3.dead = false
        table.insert(GameState.Projectiles, projectile3)
    end
end

function FindNearestEnemy()
    local nearestEnemy = nil
    local nearestDistance = math.huge
    for _, e in ipairs(GameState.Enemys) do
        local distance = DistanceBetween(e.x, e.y, Player.x, Player.y)
        
        if distance <= Player.attackRadius then
             if distance < nearestDistance then
                nearestEnemy = e
                nearestDistance = distance
            end
        end
    end

    if nearestEnemy == nil then
        print("No enemys nearby")
        return nil
    else
        print("Nearest Enemy " .. nearestEnemy.id .. " x: " .. nearestEnemy.x .. " y: " .. nearestEnemy.y)
        return nearestEnemy
    end
end

function FindNearestEnemyviaEnemy(e)
    local nearestEnemy = nil
    local nearestDistance = math.huge  -- Start with a very large number for comparison
    
    for _, enemy in ipairs(GameState.Enemys) do
        print("Active " .. e.id .. " Enemy " .. enemy.id)
        if enemy.id ~= e.id then
            local dist = DistanceBetween(e.x, e.y, enemy.x, enemy.y)
            if dist < nearestDistance then
                nearestEnemy = enemy
                nearestDistance = dist
            end
        end
    end
    
    if nearestEnemy == nil then
        print("No enemys nearby")
        return nil
    else
        print("Nearest Enemy " .. nearestEnemy.id .. " x: " .. nearestEnemy.x .. " y: " .. nearestEnemy.y)
        return nearestEnemy
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

-- 
function WaveStart()
    if GameState.Wave == 0 then
        GameState.Wave = 1
        GameState.NumEnemies = 15
    else
        GameState.Wave = GameState.Wave + 1
        GameState.NumEnemies = math.ceil(GameState.NumEnemies * 1.25)
    end
    GameState.CreatedEnemies = 0
    GameState.WaveTimer = 0
    NextSpawnTime = 1
    print( "Starting Wave " .. GameState.Wave .. ", " .. GameState.NumEnemies .. " Enemies")
end