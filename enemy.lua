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
function Enemy:SpawnEnemy()
    local enemy = setmetatable({}, { __index = self })
    local spawnSide = math.random(1,4)

    if spawnSide == 1 then
        enemy.x = -10
        enemy.y = math.random(0, Layouts.GameWindowLayout.height)
    elseif spawnSide == 2 then
        enemy.x = math.random(0, ScreenWidth)
        enemy.y = Layouts.GameWindowLayout.y - 10
    elseif spawnSide == 3 then
        enemy.x = ScreenWidth + 10
        enemy.y = math.random(0, Layouts.GameWindowLayout.height)
    elseif spawnSide == 4 then
        enemy.x = math.random(0, ScreenWidth)
        enemy.y = (Layouts.GameWindowLayout.y + Layouts.GameWindowLayout.height) + 10
    end

    enemy.id = #GameState.Enemys + 1
    enemy.sides = 3
    enemy.maxHp = 2 + (math.ceil(enemy.sides/3))
    enemy.hp = enemy.maxHp
    enemy.speed = 1*60
    enemy.dead = false
    enemy.damage = 1
    enemy.value = 1
    enemy.xp = 1

    print( "Spawning Enemy " ..enemy.id)
    return enemy
end

function Enemy:RemoveHp(amount)
    print( "Enemy " ..self.id .. " took " .. amount .. " damage" )
    self.hp = self.hp - amount
    print( "Hp remaining " .. self.hp .. "/" .. self.maxHp)
    if self.hp <= 0 then
        self.dead = true
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