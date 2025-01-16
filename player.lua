Player = {}
Player.index = Player

function Player:Init(x, y)
    local player = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.width = 10
    self.height = 10
    self.dead = false
    self.value = 0
    self.killCount = 0
    self.health = {
        maxHp = 10,
        hp = 0,
        regenAmount = 1,
        regenRate = .25,
    }
    self.attack = {
        dpsInterval = 0,
        dps = 0,
        count = 1,
        damage = 10,
        rate = 5,
        mult = 1,
        radius = 150,
    }
    self.collector = {
        count = 5,
        speed = 5,
        collectors = {}
    }
    self.abilities = {
        chain = {
            unlocked = true,
            dpsInterval = 0,
            dps = 0,
            bounce = 20,
            radius = 300,
        },
        shield = {
            unlocked = true,
            active = true,
            radius = 50,
            amount = 1,
            rechargeRate = .3,
            maxHP = 5,
            hp = 0,
        }
    }
    return player
end

function Player:update(dt)
    
end

function Player:removeHp(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.hp = 0
        self.dead = true
    end
end

function Player:addHp(amount)
    self.hp = self.hp + amount

    if self.hp > self.maxHp then
        self.hp = self.maxHp
    end
end

function Player:Abilities(e)
    if self.abilities.chain.unlocked then
        local currentEnemy = e
        for i = 1, self.abilities.chain.bounce, 1 do
            local nearestEnemy = FindNearestEnemyviaEnemy(currentEnemy, self.abilities.chain.radius)
            if nearestEnemy then
                love.graphics.setColor(1, 1, 1)
                love.graphics.line(currentEnemy.x, currentEnemy.y, nearestEnemy.x, nearestEnemy.y)
                local damage = Player.attack.damage * Player.attack.mult
                nearestEnemy:RemoveHp(damage)
                Player.abilities.chain.dpsInterval = Player.abilities.chain.dpsInterval + damage
                table.insert(GameState.Chains, {
                    startTime = love.timer.getTime(),
                    startEnemy = currentEnemy,
                    endEnemy = nearestEnemy,
                })
            end
            currentEnemy = nearestEnemy
        end
    end
end

Collector = {}
Collector.__index = Collector

function Collector:SpawnCollector()
    local collector = setmetatable({}, { __index = self })

    collector.id = #Player.collector.collectors + 1
    collector.speed = Player.collector.speed * 60
    collector.active = false
    collector.reTurn = false
    collector.x = Player.x
    collector.y = Player.y
    collector.dId = 0
    collector.dx = 0
    collector.dy = 0
    collector.direction = 0
    collector.value = 0
    return collector
end

function Collector:Reset()
    self.active = false
    self.reTurn = false
    self.x = Player.x
    self.y = Player.y
    self.dId = 0
    self.dx = 0
    self.dy = 0
    self.direction = 0
    self.value = 0
end