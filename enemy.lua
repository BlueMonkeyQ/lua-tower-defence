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

    enemy.maxHp = 2
    enemy.hp = enemy.maxHp
    enemy.speed = 2*60
    enemy.dead = false
    enemy.damage = 1
    enemy.gold = 1
    enemy.xp = 1

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