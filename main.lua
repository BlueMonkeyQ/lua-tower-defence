function love.load()
    require("layouts")
    require("player")
    require("enemy")
    require("stage")
    require("director")
    require("console")
    Input = require 'libraries/Input'

    Director = Director:new()
    Stage = Stage:new()
    Console = Console:new()

    TextInput = Input()

    math.randomseed(os.time())

    ScreenWidth = love.graphics.getWidth()
    ScreenHeight = love.graphics.getHeight()

    ButtonFont = love.graphics.newFont(20)

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
    GameState.DpsTimer = 0
    GameState.GameSpeed = 1
    GameState.Enemys = {}
    GameState.Projectiles = {}
    GameState.Drops = {}
    GameState.Chains = {}
    GameState.InfoRows = {}

    BaseLayouts = {
        GameWindowLayout = {
            x = 0,
            y = 0,
            width = ScreenWidth,
            height = ScreenHeight-60,
        },
        InfoLayout = {
            y = 150,
            width = 250,
            height = -20,
        }
    }

    Layouts = {
        RunInfoLayout = {
            x = BaseLayouts.GameWindowLayout.x,
            y = BaseLayouts.GameWindowLayout.y,
            width = ScreenWidth,
        },
        PopupLayout = {
            x = 50,
            y = 50,
            width = 700,
            height = 500,
        },
        HealthBarLayout = {
            x = BaseLayouts.GameWindowLayout.x,
            y = BaseLayouts.GameWindowLayout.height + 30,
            width = ScreenWidth,
            height = 30,
        },
        ShieldBarLayout = {
            x = BaseLayouts.GameWindowLayout.x,
            y = BaseLayouts.GameWindowLayout.height,
            width = ScreenWidth,
            height = 30,
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

    Sounds = {
        AutoAttack = "data/sounds/autoattack.wav"
    }

    Sprites = {
        Background = love.graphics.newImage("data/sprites/background.png"),
        Value = love.graphics.newImage("data/sprites/value.png"),
        KllCount = love.graphics.newImage("data/sprites/killCount.png")
    }

    Player:Init((BaseLayouts.GameWindowLayout.width/2), (BaseLayouts.GameWindowLayout.height/2))
    for i = 1, Player.collector.count, 1 do
        local c = Collector:SpawnCollector()
        table.insert(Player.collector.collectors, c)
    end
    if Player.abilities.shield.unlocked then
        Player.abilities.shield.hp = Player.abilities.shield.maxHP
    end

    EnemyIdCounter = 1
    DropIdCounter = 1
    ProjectileIdCounter = 1

    NextWaveTime = 15
    NextSpawnTime = 1

    NearestEnemy = nil
    LastAttackTime = 0
    LastHealthTime = 0
    LastShieldTime = 0

    GameTimer = 0
end

function love.update(dt)
    Director:Update(dt)
end

-- function love.update(dt)

--     -- Console:update(dt)
--     -- Game is Running
--     if GameState.State == 1 then
--         GameState.Timer = GameState.Timer + dt * GameState.GameSpeed
--         GameState.WaveTimer = GameState.WaveTimer + dt * GameState.GameSpeed

--         if Player.dead then
--             GameState.Enemys = {}
--             GameState.Projectiles = {}
--             GameEnd()
--         end

--         -- DPS Counter
--         if GameState.Timer - GameState.DpsTimer >= 1 then
--             Player.attack.dps = Player.attack.dpsInterval
--             Player.abilities.chain.dps = Player.abilities.chain.dpsInterval
--             GameState.DpsTimer = GameState.Timer
--         end

--         -- Handles Wave and Spawning
--         if GameState.WaveTimer >= NextWaveTime and #GameState.Enemys == 0 then
--             WaveStart()
        
--         elseif GameState.WaveTimer >= NextSpawnTime and GameState.CreatedEnemies < GameState.NumEnemies then
--             local numEnemies = math.floor(GameState.NumEnemies * (NextWaveTime/100))
--             for i = 1, numEnemies, 1 do
--                 local enemy = Enemy:SpawnEnemy()
--                 table.insert(GameState.Enemys, enemy)
--                 GameState.CreatedEnemies = GameState.CreatedEnemies + 1
--             end
--             NextSpawnTime = NextSpawnTime + 1
--         end
  
--         -- Auto Attacking
--         LastAttackTime = LastAttackTime + dt * GameState.GameSpeed
--         local interval = 1 / Player.attack.rate
--         if LastAttackTime >= interval then
--             for i = 1, Player.attack.count, 1 do
                -- NearestEnemy = FindNearestEnemy()
--                 if NearestEnemy ~= nil then
--                     SpawnProjectile()
--                     -- local sound = love.audio.newSource(Sounds.AutoAttack, "static")
--                     -- sound:play()
--                 end
--             end
--             LastAttackTime = LastAttackTime - interval
--         end
    
--         -- Health Regen
--         if Player.healthRegen > 0 and Player.hp < Player.maxHp then
--             LastHealthTime = LastHealthTime + dt * GameState.GameSpeed
--             local interval = 1 / Player.healthRegen
--             if LastHealthTime >= interval then
--                 Player:addHp(1)
--                 LastHealthTime = LastHealthTime - interval
--             end
--         end

--         -- Shield Regen
--         if Player.abilities.shield.hp <= Player.abilities.shield.maxHP then
--             LastShieldTime = LastShieldTime + dt * GameState.GameSpeed
--             local interval = 1 / Player.abilities.shield.rechargeRate
            
--             if LastShieldTime >= interval then
--                 Player.abilities.shield.hp = Player.abilities.shield.hp + 1
--                 if Player.abilities.shield.hp > Player.abilities.shield.maxHP then
--                     Player.abilities.shield.hp = Player.abilities.shield.maxHP
--                 end
--                 Player.abilities.shield.active = true
--                 LastShieldTime = LastShieldTime - interval
--             end
--         end

--         -- Handle Collectors getting drops
--         for _, c in ipairs(Player.collector.collectors) do
--             if c.active then
--                 -- Move the collector to the drop
--                 c.x = c.x + (math.cos( c.direction ) * c.speed * (dt * GameState.GameSpeed))
--                 c.y = c.y + (math.sin( c.direction ) * c.speed * (dt * GameState.GameSpeed))

--                 -- Check the collector made it to its destination
--                 if DistanceBetween(c.x, c.y, c.dx, c.dy) < 10 then
--                     -- Going towards player
--                     if c.reTurn then
--                         Player.value = Player.value + c.value
--                         c:Reset()

--                     -- Going towards drop
--                     else
--                         c.dx = Player.x
--                         c.dy = Player.y
--                         c.direction = GetAngle(c.dx, c.dy,c.x, c.y)
--                         c.reTurn = true
--                         for j, drop in ipairs(GameState.Drops) do
--                             if drop.id == c.dId then
--                                 table.remove(GameState.Drops, j)
--                                 break
--                             end
--                         end
--                     end
--                 end
            
--             else
--                 local d = FindNearestDrop()
--                 if d ~= nil then
--                     d.beingCollected = true
--                     c.active = true
--                     c.dx = d.x
--                     c.dy = d.y
--                     c.dId = d.id
--                     c.direction = GetAngle(c.x, c.y, c.dx, c.dy) + math.pi
--                     c.value = d.value
--                 end
--             end
--         end

--         -- Update Projectile postion
--         for i, p in ipairs(GameState.Projectiles) do
--             p.x = p.x + (math.cos( p.direction ) * p.speed * (dt * GameState.GameSpeed))
--             p.y = p.y + (math.sin( p.direction ) * p.speed * (dt * GameState.GameSpeed))

--             -- Check for Enemy Collision
--             for _, e in ipairs(GameState.Enemys) do
--                 if DistanceBetween(e.x, e.y, p.x, p.y) < 10 then
--                     local damage = Player.attack.damage * Player.attack.mult
--                     e:RemoveHp(damage)
--                     Player.attack.dpsInterval = Player.attack.dpsInterval + damage
--                     Player:Abilities(e)
--                     table.remove(GameState.Projectiles, i)
--                     i = i -1
--                 end
--             end
        
--             -- Check for Out of Bounds
--             if p.x < BaseLayouts.GameWindowLayout.x or p.y < BaseLayouts.GameWindowLayout.y or p.x > ScreenWidth or p.y > (BaseLayouts.GameWindowLayout.y + BaseLayouts.GameWindowLayout.height) then
--                 table.remove(GameState.Projectiles, i)
--                 i = i -1
--             end
--         end

--         -- Update Enemy postion to player
--         for i = #GameState.Enemys, 1, -1 do
--             local e = GameState.Enemys[i]
--             e.x = e.x + (math.cos( EnemyPlayerAngel(e) ) * e.speed * (dt * GameState.GameSpeed))
--             e.y = e.y + (math.sin( EnemyPlayerAngel(e) ) * e.speed * (dt * GameState.GameSpeed))
            
--             -- Detect Collision with shield if active
--             if Player.abilities.shield.active then
--                 if DistanceBetween(e.x, e.y, Player.x, Player.y) <= Player.abilities.shield.radius then
--                     Player.abilities.shield.hp = Player.abilities.shield.hp - e.damage
--                     if Player.abilities.shield.hp <= 0 then
--                         Player.abilities.shield.active = false
--                         Player.abilities.shield.hp = 0
--                     end
--                     table.remove(GameState.Enemys, i)
--                     if Player.dead then
--                         return
--                     end
--                 end
--             end

--             -- Detect Collision with player
--             if DistanceBetween(e.x, e.y, Player.x, Player.y) < 10 then
--                 Player:removeHp(e.damage)
--                 table.remove(GameState.Enemys, i)
--                 if Player.dead then
--                     return
--                 end
--             end
--         end

--         -- Removes Enemys
--         for i, e in ipairs(GameState.Enemys) do
--             if e.dead then
--                 SpawnDrops(e)
--                 table.remove(GameState.Enemys, i)
--             end
--         end

--         -- Handles Chain
--         local currentTime = love.timer.getTime()
--         for i = #GameState.Chains, 1, -1 do
--             local chain = GameState.Chains[i]
--             if currentTime - chain.startTime >= .1 then
--                 table.remove(GameState.Chains, i)
--             end
--         end
--     end
-- end

function love.draw()
    Director:draw()
    Stage:draw()
    -- Console:draw()
end

-- function love.draw(dt)
--     local r, g, b = HexToRGB("#1C1C1C")
--     love.graphics.setBackgroundColor(r, g, b, .2)

--     if GameState.State == 0 then
        
--     elseif GameState.State == 1 then

--          -- Handles chain lines
--         for _, chain in ipairs(GameState.Chains) do
--             love.graphics.setColor(1, 0, 0)
--             love.graphics.line(chain.startEnemy.x, chain.startEnemy.y, chain.endEnemy.x, chain.endEnemy.y)
--         end

--         -- Handles Spawned Drops
--         for _, d in ipairs(GameState.Drops) do
--             local r, g, b = HexToRGB("#F4C430")
--             love.graphics.setColor(r, g, b)
--             love.graphics.circle("line", d.x, d.y, d.r )
--         end

--         -- Handle Collectors
--         for _, c in ipairs(Player.collector.collectors) do
--             local r, g, b = HexToRGB("#5D3F6E")
--             love.graphics.setColor(r, g, b)
--             love.graphics.rectangle("fill", c.x, c.y, 10, 10) 
--         end

--         -- Handles Spawned Enemies
--         for _, e in ipairs(GameState.Enemys) do
--             local alpha = e.hp / e.maxHp -- Gets the Transparency of the enemy on % health left
--             local vertices = e:Shape(10)

            -- local r, g, b = HexToRGB("#FF33CC")
            -- -- love.graphics.setColor(r, g, b, alpha)
            -- -- love.graphics.polygon("fill", vertices)
            
            -- love.graphics.setColor(r, g, b,1)
            -- love.graphics.polygon("line", vertices)
--         end
        
--         -- Handle Projectiles
--         for _, p in ipairs(GameState.Projectiles) do
--             local r, g, b = HexToRGB("#FF7F00")
--             love.graphics.setColor(r, g, b)
--             love.graphics.rectangle("fill", p.x, p.y, 10, 10)
--         end

--         -- ControlsLayout( "q) Quit | v) Auto Shoot | c) Stats" )
--     end
    
    
--     -- WaveHeader()
--     Shieldbar()
--     Healthbar()
--     DrawPlayer()
--     RunInfoScreen()
--     -- love.graphics.setColor(1, 1, 1, 1)
--     -- love.graphics.draw(Sprites.Background, 0, 0)
--     -- DebugWindow()
-- end

function GameStart()
    GameState.State = 1
    GameState.Timer = 0
    Player.hp = Player.maxHp
    Player.attack.total = 0
    
    if Player.abilities.shield.unlocked then
        Player.abilities.shield.active = true
        Player.abilities.shield.hp = Player.abilities.shield.maxHP
    end
    WaveStart()
end

function GameEnd()
    GameState.State = 0
    GameState.Timer = 0
    GameState.Wave = 0
    GameState.NumEnemies = 0
    GameState.Drops = {}
    GameState.Enemys = {}
    GameState.Projectiles = {}
    Player.dead = false
    Player.hp = Player.maxHp
    Player.killCount = 0
    Player.attack.total = 0
    Player.abilities.chain.total = 0
    Player.abilities.shield.hp = Player.abilities.shield.maxHP
    for _, c in ipairs(Player.collector.collectors) do
        c:Reset()
    end
end

-- Handles all key press events
function love.keypressed(key)

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

function SpawnDrops(e)
    local drop = {}
    drop.id = DropIdCounter
    drop.x = e.x
    drop.y = e.y
    drop.r = 5
    drop.value = e.value
    drop.beingCollected = false
    drop.pickedUp = false
    DropIdCounter = DropIdCounter + 1
    table.insert(GameState.Drops, drop)
end

function FindNearestEnemy()
    local nearestEnemy = nil
    local nearestDistance = math.huge
    for _, e in ipairs(GameState.Enemys) do
        local distance = DistanceBetween(e.x, e.y, Player.x, Player.y)

        if distance < nearestDistance then
            nearestEnemy = e
            nearestDistance = distance
        end
    end

    if nearestEnemy == nil then
        return nil
    else
        return nearestEnemy
    end
end

function FindNearestEnemyviaEnemy(e, r)
    local nearestEnemy = nil
    local nearestDistance = math.huge
    
    if not e then
        return
    end

    if not GameState.Enemys or #GameState.Enemys <= 1 then
        return
    end

    for _, enemy in ipairs(GameState.Enemys) do
        if enemy then
            if enemy.id ~= e.id and not enemy.dead then
                local dist = DistanceBetween(e.x, e.y, enemy.x, enemy.y)
                if (dist <= r) and (dist < nearestDistance) then
                    nearestEnemy = enemy
                    nearestDistance = dist
                end
            end
        end
    end
    
    if nearestEnemy == nil then
        return nil
    else
        return nearestEnemy
    end
end

-- Returns the arc tangent of the player to the enemy
function EnemyPlayerAngel(enemy)
    return math.atan2( Player.y - enemy.y, Player.x - enemy.x )
end

function DropPlayerAngel(drop)
    return math.atan2( Player.y - drop.y, Player.x - drop.x )
end

function GetAngle(x1,y1,x2,y2)
    return math.atan2( y1 - y2, x1 - x2 )
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
function MouseIn(object)
    return love.mouse.getX() >= object.x
    and love.mouse.getX() < object.x + object.width
    and love.mouse.getY() >= object.y
    and love.mouse.getY() < object.y + object.height
end

function EndGame()
    return
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
end

function FindNearestDrop()
    local closestDrop = nil
    local closestDistance = math.huge

    for _, d in ipairs(GameState.Drops) do
        if not d.beingCollected then
            local dist = DistanceBetween(d.x, d.y, Player.x, Player.y)
            if dist < closestDistance then
                closestDrop = d
                closestDistance = dist
            end
        end
    end
    return closestDrop
end

function HexToRGB(hex)
    local r = tonumber(hex:sub(2, 3), 16) / 255
    local g = tonumber(hex:sub(4, 5), 16) / 255
    local b = tonumber(hex:sub(6, 7), 16) / 255
    return r, g, b
end

function love.textinput(t)
    if Console.inputting then
        Console:textinput(t)
    end
end