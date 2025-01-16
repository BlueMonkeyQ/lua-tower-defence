function DrawPlayer()
    local r, g, b = HexToRGB("#00D9FF")
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)

    if Player.abilities.shield.unlocked and Player.abilities.shield.active then
        r, g, b = HexToRGB("#4682B4")
        love.graphics.setColor(r, g, b, .3)
        local outerRadius = Player.abilities.shield.radius + 2
        love.graphics.setLineWidth(5)
        love.graphics.circle("line", Player.x + Player.width / 2, Player.y + Player.height / 2, outerRadius)

        r, g, b = HexToRGB("#00D9FF")
        love.graphics.setColor(r, g, b)
        love.graphics.setLineWidth(1)
        love.graphics.circle("line", Player.x + Player.width / 2, Player.y + Player.height / 2,Player.abilities.shield.radius)
        
        r, g, b = HexToRGB("#4682B4")
        love.graphics.setColor(r, g, b, .3)
        love.graphics.setLineWidth(5)
        local innerRadius = Player.abilities.shield.radius - 2
        love.graphics.circle("line", Player.x + Player.width / 2, Player.y + Player.height / 2, innerRadius)
    end

    if MouseIn(Player) then
        table.insert(GameState.InfoRows, {"Stats",nil})
        table.insert(GameState.InfoRows, {"Damage ",Player.attack.damage})
        table.insert(GameState.InfoRows, {"Mult ",Player.attack.mult})
        table.insert(GameState.InfoRows, {"Attack Speed ",Player.attack.rate})
        table.insert(GameState.InfoRows, {"Collectors ",Player.collector.count})
        
        if GameState.State == 1 then
            table.insert(GameState.InfoRows, {"DPS", nil})
            table.insert(GameState.InfoRows, {"Auto ",tonumber(string.format("%.2f", Player.attack.dps / GameState.DpsTimer))})
            
            if Player.abilities.chain.unlocked then
                table.insert(GameState.InfoRows, {"Bounces ", Player.abilities.chain.bounce})
                table.insert(GameState.InfoRows, {"Chain ", tonumber(string.format("%.2f", Player.abilities.chain.dps / GameState.DpsTimer))})
            end
        end
        InfoPopup()
    end
    GameState.InfoRows = {}
    love.graphics.setLineWidth(1)
end

function InfoPopup()
    local r, g, b = HexToRGB("#1C1C1C")
    love.graphics.setColor(r, g, b, .8)
    love.graphics.rectangle("fill", love.mouse.getX(), love.mouse.getY(), BaseLayouts.InfoLayout.width, BaseLayouts.InfoLayout.height - #GameState.InfoRows * 20)
    -- love.graphics.rectangle("fill", love.mouse.getX(), love.mouse.getY() - BaseLayouts.InfoLayout.y, BaseLayouts.InfoLayout.width, BaseLayouts.InfoLayout.height + #GameState.InfoRows * 20)
    
    
    for i, v in ipairs(GameState.InfoRows) do
        local row = i - 1
        if v[2] == nil then
            InfoHeader(v[1], row)
        else
            InfoText(v[1], v[2], row)
        end
    end

    love.graphics.setLineWidth(2)
    r, g, b = HexToRGB("#00D9FF")
    love.graphics.setColor(r, g, b, .3)
    love.graphics.rectangle("line", love.mouse.getX(), love.mouse.getY(), BaseLayouts.InfoLayout.width, BaseLayouts.InfoLayout.height - #GameState.InfoRows * 20)
    -- love.graphics.rectangle("line", love.mouse.getX(), love.mouse.getY() - BaseLayouts.InfoLayout.y, BaseLayouts.InfoLayout.width, BaseLayouts.InfoLayout.height + #GameState.InfoRows * 20)
    love.graphics.setLineWidth(1)
end

function InfoHeader(text, row)
    love.graphics.setFont(love.graphics.newFont(20))
    local r, g, b = HexToRGB("#FF33CC")
    love.graphics.setColor(r, g, b)
    love.graphics.printf(text, love.mouse.getX(), love.mouse.getY() + (BaseLayouts.InfoLayout.height - #GameState.InfoRows * 20) + 20*row, BaseLayouts.InfoLayout.width, "center")
    -- love.graphics.printf(text, love.mouse.getX(), (love.mouse.getY() - BaseLayouts.InfoLayout.y) + (20*row), BaseLayouts.InfoLayout.width, "center")
end

function InfoText(text, value, row)
    love.graphics.setFont(love.graphics.newFont(20))
    local r, g, b = HexToRGB("#FF33CC")
    love.graphics.setColor(r, g, b)
    love.graphics.printf(text, love.mouse.getX() + 2, love.mouse.getY() + (BaseLayouts.InfoLayout.height - #GameState.InfoRows * 20) + 20*row, BaseLayouts.InfoLayout.width, "left")
    -- love.graphics.printf(text, love.mouse.getX() + 2, (love.mouse.getY() - BaseLayouts.InfoLayout.y) + (20*row), BaseLayouts.InfoLayout.width, "left")
    love.graphics.printf(value, love.mouse.getX() - 2, love.mouse.getY() + (BaseLayouts.InfoLayout.height - #GameState.InfoRows * 20) + 20*row, BaseLayouts.InfoLayout.width, "right")
    -- love.graphics.printf(value, love.mouse.getX() - 2, (love.mouse.getY() - BaseLayouts.InfoLayout.y) + (20*row), BaseLayouts.InfoLayout.width, "right")
end

function DebugWindow()
    local r, g, b = HexToRGB("#1C1C1C")
    love.graphics.setColor(r, g, b, .8)
    love.graphics.rectangle("fill", BaseLayouts.GameWindowLayout.x, BaseLayouts.GameWindowLayout.y, BaseLayouts.InfoLayout.width, -BaseLayouts.InfoLayout.height)
    love.graphics.setColor(1,1,1, .8)
    love.graphics.printf(GameState.Timer, BaseLayouts.GameWindowLayout.x, BaseLayouts.GameWindowLayout.y + (20*1), BaseLayouts.InfoLayout.width, "left")
end

function Healthbar()
    local r, g, b = HexToRGB("#FF33CC")
    local hp = Player.health.hp
    local maxHp = Player.health.maxHp
    
    -- Background
    love.graphics.setColor(r, g, b , .2)
    love.graphics.rectangle("fill", Layouts.HealthBarLayout.x, Layouts.HealthBarLayout.y, Layouts.HealthBarLayout.width, Layouts.HealthBarLayout.height)

    -- Healthbar
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", Layouts.HealthBarLayout.x, Layouts.HealthBarLayout.y, Layouts.HealthBarLayout.width * (hp/maxHp), Layouts.HealthBarLayout.height)

    if MouseIn(Layouts.HealthBarLayout) then
        table.insert(GameState.InfoRows, {"Health ", hp .. "/" .. maxHp})
        table.insert(GameState.InfoRows, {"Regen Rate ", (math.floor(1/Player.health.regenRate))})
        table.insert(GameState.InfoRows, {"Regen Amount ", Player.health.regenAmount})
        InfoPopup()
    end
    GameState.InfoRows = {}

end

function Shieldbar()
    local r, g, b = HexToRGB("#4682B4")
    -- Background
    love.graphics.setColor(r, g, b, .2)
    love.graphics.rectangle("fill", Layouts.ShieldBarLayout.x, Layouts.ShieldBarLayout.y, Layouts.ShieldBarLayout.width, Layouts.ShieldBarLayout.height)

    -- ShieldBar
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", Layouts.ShieldBarLayout.x, Layouts.ShieldBarLayout.y, Layouts.ShieldBarLayout.width * (Player.abilities.shield.hp/Player.abilities.shield.maxHP), Layouts.ShieldBarLayout.height)

    if MouseIn(Layouts.ShieldBarLayout) then
        table.insert(GameState.InfoRows, {"Shield ", Player.abilities.shield.hp .. "/" .. Player.abilities.shield.maxHP})
        table.insert(GameState.InfoRows, {"Regen Rate ", (math.floor(1/Player.abilities.shield.rechargeRate))})
        table.insert(GameState.InfoRows, {"Regen Amount ", Player.abilities.shield.amount})
        InfoPopup()
    end
    GameState.InfoRows = {}
end

function RunInfoScreen()
    love.graphics.setColor(1,1,1,1)
    -- love.graphics.draw(drawable,x,y,r,sx,sy,ox,oy)
    love.graphics.draw(Sprites.Value, Layouts.RunInfoLayout.x, Layouts.RunInfoLayout.y)
    love.graphics.draw(Sprites.KllCount, Layouts.RunInfoLayout.x, Layouts.RunInfoLayout.y + 42)
    love.graphics.setFont(love.graphics.newFont(30))
    local r, g, b = HexToRGB("#FF33CC")
    love.graphics.setColor(r, g, b)
    love.graphics.printf(Player.value, Layouts.RunInfoLayout.x + 42, Layouts.RunInfoLayout.y + 2, BaseLayouts.InfoLayout.width, "left")
    love.graphics.printf(Player.killCount, Layouts.RunInfoLayout.x + 42, Layouts.RunInfoLayout.y + 42, BaseLayouts.InfoLayout.width, "left")
end