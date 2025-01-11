Player = {}
Player.index = Player

function Player:Init(x, y)
    local player = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.width = 10
    self.height = 10
    self.xp = 0
    self.maxHp = 5
    self.hp = Player.maxHp
    self.healthRegen = .25
    self.damage = 1
    self.attackSpeed = 2
    self.attackRadius = 100
    self.dead = false
    self.gold = 0
    self.killCount = 0

    self.abilities = {
        auto = true,
        autoOn = true,
        spread = false,
        chain = true,
        chainAmount = 2,
    }
    return player
end

function Player:removeHp(amount)
    self.hp = self.hp - amount
    print( "Player took " .. amount .. " damage" )
    print( "Hp remaining " .. self.hp .. "/" .. self.maxHp)
    if self.hp <= 0 then
        self.hp = 0
        self.dead = true
    end
end

function Player:addHp(amount)
    self.hp = self.hp + amount
    print( "Player healed " .. amount )

    if self.hp > self.maxHp then
        print( "Overhealed, setting to max HP" )
        self.hp = self.maxHp
    end

    print( "Hp " .. self.hp .. "/" .. self.maxHp)
end

function Player:Abilities(e)
    print( "---------- Abilities ----------")
    if self.abilities.chain then
        local currentEnemy = e
        for i = 1, self.abilities.chainAmount, 1 do
            print( "Chain Ability Bounce " .. i )
            local nearestEnemy = FindNearestEnemyviaEnemy(currentEnemy)
            if nearestEnemy then
                print( "Enemy " .. currentEnemy.id .. " Chaining to Enemy " .. nearestEnemy.id)
                love.graphics.setColor(1, 1, 1)
                love.graphics.line(currentEnemy.x, currentEnemy.y, nearestEnemy.x, nearestEnemy.y)
                nearestEnemy:RemoveHp(Player.damage)
                table.insert(GameState.Chains, {
                    startTime = love.timer.getTime(),
                    startEnemy = currentEnemy,
                    endEnemy = nearestEnemy,
                })
            end
            currentEnemy = nearestEnemy
        end
    end
    print( "----------  ----------")
end