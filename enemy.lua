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
    local enemy = setmetatable({}, self)
    local spawnSide = math.random(1,4)

    if spawnSide == 1 then
        self.x = -10
        self.y = math.random(0, Layouts.GameWindowLayout.height)
    elseif spawnSide == 2 then
        self.x = math.random(0, ScreenWidth)
        self.y = Layouts.GameWindowLayout.y - 10
    elseif spawnSide == 3 then
        self.x = ScreenWidth + 10
        self.y = math.random(0, Layouts.GameWindowLayout.height)
    elseif spawnSide == 4 then
        self.x = math.random(0, ScreenWidth)
        self.y = (Layouts.GameWindowLayout.y + Layouts.GameWindowLayout.height) + 10
    end

    self.sides = 3
    self.maxHp = 2 + (math.ceil(self.sides/3))
    self.hp = self.maxHp
    self.speed = 1*60
    self.dead = false
    self.damage = 1
    self.gold = 1
    self.xp = 1

    print( "Spawning Enemy x: " .. enemy.x .. " y: " .. enemy.y)
    return enemy
end

function Enemy:RemoveHp(amount)
    print( "Enemy took " .. amount .. " damage" )
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