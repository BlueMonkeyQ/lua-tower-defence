Player = {}
Player.index = Player

function Player:Init(x, y)
    local player = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.xp = 0
    self.maxHp = 10
    self.hp = Player.maxHp
    self.healthRegen = 1
    self.damage = 1
    self.attackSpeed = 5
    self.dead = false
    self.gold = 0

    self.abilities = {
        auto = true,
        autoOn = false
    }
    return player
end

function Player:removeHp(amount)
    self.hp = self.hp - amount
    print( "Player took " .. amount .. " damage" )
    print( "Hp remaining " .. self.hp .. "/" .. self.maxHp)
    if self.hp <= 0 then
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