Enemy = {}
Enemy.__index = Enemy

--[[
Creates enemy object and adds to Enemys Table.
Spawn Direction:
    1: left
    2: top
    3: right
    4: down
--]]

function Enemy:new(id, sides)
    local enemy = setmetatable({}, self)
    enemy.id = id
    enemy.sides = sides
    enemy.maxHp = 2 * sides
    enemy.hp = enemy.maxHp
    enemy.radius = 10
    enemy.speed = 1*60
    enemy.damage = 1
    enemy.value = 1
    enemy.score = 1
    enemy.active = false
    enemy.dead = false
    
    enemy.spawnTime = math.random(1,30)

    local spawnSide = math.random(1,4)
    if spawnSide == 1 then
        enemy.x = -10
        enemy.y = math.random(0, BaseLayouts.GameWindowLayout.height)
    elseif spawnSide == 2 then
        enemy.x = math.random(0, ScreenWidth)
        enemy.y = BaseLayouts.GameWindowLayout.y - 10
    elseif spawnSide == 3 then
        enemy.x = ScreenWidth + 10
        enemy.y = math.random(0, BaseLayouts.GameWindowLayout.height)
    elseif spawnSide == 4 then
        enemy.x = math.random(0, ScreenWidth)
        enemy.y = (BaseLayouts.GameWindowLayout.y + BaseLayouts.GameWindowLayout.height) + 10
    end

    return enemy
end

function Enemy:update(dt)
    -- Position
    self.x = self.x + (math.cos( self:playerAngle() ) * self.speed * (dt * GameState.GameSpeed))
    self.y = self.y + (math.sin( self:playerAngle() ) * self.speed * (dt * GameState.GameSpeed))
    
    -- Collision
    if Player.abilities.shield.active then
        if DistanceBetween(self.x, self.y, Player.x, Player.y) <= Player.abilities.shield.radius then
            Player.abilities.shield.hp = Player.abilities.shield.hp - self.damage
            if Player.abilities.shield.hp <= 0 then
                Player.abilities.shield.active = false
                Player.abilities.shield.hp = 0
            end
            self.dead = true
            if Player.dead then
                return
            end
        end
    else
        if DistanceBetween(self.x, self.y, Player.x, Player.y) < 10 then
            Player:removeHp(self.damage)
            self.dead = true
            if Player.dead then
                return
            end
        end
    end
end

function Enemy:playerAngle()
    return math.atan2( Player.y - self.y, Player.x - self.x )
end

-- function Enemy:SpawnEnemy()
--     local enemy = setmetatable({}, { __index = self })
--     local spawnSide = math.random(1,4)

--     if spawnSide == 1 then
--         enemy.x = -10
--         enemy.y = math.random(0, BaseLayouts.GameWindowLayout.height)
--     elseif spawnSide == 2 then
--         enemy.x = math.random(0, ScreenWidth)
--         enemy.y = BaseLayouts.GameWindowLayout.y - 10
--     elseif spawnSide == 3 then
--         enemy.x = ScreenWidth + 10
--         enemy.y = math.random(0, BaseLayouts.GameWindowLayout.height)
--     elseif spawnSide == 4 then
--         enemy.x = math.random(0, ScreenWidth)
--         enemy.y = (BaseLayouts.GameWindowLayout.y + BaseLayouts.GameWindowLayout.height) + 10
--     end
--     return enemy
-- end

function Enemy:RemoveHp(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.dead = true
        Player.killCount = Player.killCount + 1
    end
end

function Enemy:Shape(radius)
    local vertices = {}
    local angleStep = 2 * math.pi / self.sides  -- Angle between each vertex

    for i = 0, self.sides - 1 do
        local angle = i * angleStep  -- Angle for this vertex
        local vx = self.x + radius * math.cos(angle)
        local vy = self.y + radius * math.sin(angle)
        table.insert(vertices, vx)
        table.insert(vertices, vy)
    end

    return vertices
end