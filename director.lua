-- Director controls the gameplay loop
Director = {}
Director.index = Director

function Director:new()
    setmetatable({}, self)
    self.wave = 0
    self.duration = 5
    self.waveTimer = 0
    self.attackTimer = 0
    self.points = 50
    self.score = 0
    self.killCount = 0
    self.enemyList = {}
    self.enemyActiveList = {}
    return Director
end

function Director:Update(dt)
    self.waveTimer = self.waveTimer + dt
    self.attackTimer = self.attackTimer + dt

    -- Wave
    if self.waveTimer > self.duration or self.wave == 0 then
        print("Starting Wave " .. self.wave)
        self.waveTimer = 0
        self.wave = self.wave + 1
        self.enemyList = {}
        self:GetEnemys()
    end

    -- Player
    local attackRate = 1 / Player.attack.rate
    if self.attackTimer >= attackRate then
        for i = 1, Player.attack.count, 1 do
            local nearestEnemy = Director:nearestEnemy()
            if nearestEnemy ~= nil then
                
            end
        end
    end

    -- Enemys
    if self.enemyList then
        for i, e in ipairs(self.enemyList) do
            if not e.active and self.waveTimer >= e.spawnTime then
                e.active = true
                table.insert(self.enemyActiveList, e)
            end
        end
    end

    if self.enemyActiveList then
        for i, e in ipairs(self.enemyActiveList) do
            e:update(dt)
            if e.dead then
                self.score = self.score + e.score
                table.remove(self.enemyActiveList, i)
            end
        end
    end
end

function Director:draw()
    for _, e in ipairs(self.enemyActiveList) do
        local vertices = e:Shape(e.radius)
        local r, g, b = HexToRGB("#FF33CC")
        love.graphics.setColor(r, g, b,1)
        love.graphics.polygon("line", vertices)
    end
end

function Director:GetEnemys()
    local points = self.points
    while points > 0 do
        local id = #self.enemyList + 1
        local e = Enemy:new(id, 3)
        points = points - 1
        table.insert(self.enemyList, e)
    end
end

function Director:nearestEnemy()
    local nearestEnemy = nil
    local nearestDistance = math.huge
    if self.enemyActiveList then
        for _, e in ipairs(self.enemyActiveList) do
            local distance = DistanceBetween(e.x, e.y, Player.x, Player.y)
    
            if distance < nearestDistance then
                nearestEnemy = e
                nearestDistance = distance
            end
        end
    end

    return nearestEnemy
end

-- function Director:GameStart()
    
-- end

-- function Director:GameOver()
    
-- end