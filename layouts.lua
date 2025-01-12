function Header()
    
    love.graphics.setColor(0,.5,1)
    love.graphics.rectangle("fill", Layouts.HeaderLayout.x, Layouts.HeaderLayout.y, Layouts.HeaderLayout.width, Layouts.HeaderLayout.height)
end

function GameWindow()
    love.graphics.setColor(0,1,0)
    love.graphics.rectangle("line", Layouts.GameWindowLayout.x, Layouts.GameWindowLayout.y, Layouts.GameWindowLayout.width, Layouts.GameWindowLayout.height)
end

function DrawPlayer()
    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.width, Player.height)

    if Player.abilities.shield.unlocked and Player.abilities.shield.active then
        love.graphics.setColor(0,0,1)
       love.graphics.circle("line", Player.x + Player.width / 2, Player.y + Player.height / 2,Player.abilities.shield.radius)     
    end
end

function Popup(r,g,b)
    love.graphics.setColor(r,g,b)
    love.graphics.rectangle("fill", Layouts.PopupLayout.x, Layouts.PopupLayout.y, Layouts.PopupLayout.width, Layouts.PopupLayout.height)
end

function StatsWindow()
    Popup(128,128,128)
    love.graphics.setFont(love.graphics.newFont(40))
    love.graphics.setColor(0,0,0)
    love.graphics.printf("HP " ..Player.hp .. "/" ..Player.maxHp, Layouts.PopupLayout.x, Layouts.PopupLayout.y, ScreenWidth, "left")
    love.graphics.printf("Gold " ..Player.gold, Layouts.PopupLayout.x, Layouts.PopupLayout.y*2, ScreenWidth, "left")
    love.graphics.printf("Kills " ..Player.killCount, Layouts.PopupLayout.x, Layouts.PopupLayout.y*3, ScreenWidth, "left")
    love.graphics.printf("Run Time " ..math.floor(GameState.Timer/60) .. "." ..math.floor(GameState.Timer%60), Layouts.PopupLayout.x, Layouts.PopupLayout.y*4, ScreenWidth, "left")
end

function DebugWindow()
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Wave " .. GameState.Wave, Layouts.DebugLayout.x, Layouts.DebugLayout.y, Layouts.DebugLayout.width, "left")
    love.graphics.printf("Time " .. math.floor(GameState.WaveTimer), Layouts.DebugLayout.x, Layouts.DebugLayout.y + 25, Layouts.DebugLayout.width, "left")
    love.graphics.printf("Max " .. GameState.NumEnemies, Layouts.DebugLayout.x, Layouts.DebugLayout.y + 50, Layouts.DebugLayout.width, "left")
    love.graphics.printf("Spawned " .. GameState.CreatedEnemies, Layouts.DebugLayout.x, Layouts.DebugLayout.y + 75, Layouts.DebugLayout.width, "left")
    love.graphics.printf("Hp " .. Player.hp .. "/" .. Player.maxHp, Layouts.DebugLayout.x, Layouts.DebugLayout.y + 100, Layouts.DebugLayout.width, "left")
    love.graphics.printf("Shield " .. Player.abilities.shield.hp .. "/" .. Player.abilities.shield.maxHP, Layouts.DebugLayout.x, Layouts.DebugLayout.y + 125, Layouts.DebugLayout.width, "left")
    love.graphics.printf("Value " .. Player.value, Layouts.DebugLayout.x, Layouts.DebugLayout.y + 150, Layouts.DebugLayout.width, "left")
    love.graphics.printf("Drops " .. #GameState.Drops, Layouts.DebugLayout.x, Layouts.DebugLayout.y + 175, Layouts.DebugLayout.width, "left")
    love.graphics.printf("Collectors " .. #Player.collectors, Layouts.DebugLayout.x, Layouts.DebugLayout.y + 200, Layouts.DebugLayout.width, "left")

    love.graphics.setColor(1, 1, 1)  -- Set the color to white for the radius circle
    -- love.graphics.circle(mode,x,y,radius)
    love.graphics.circle("line", Player.x + Player.width / 2, Player.y + Player.height / 2, Player.attackRadius)
end

function BuyWindow()
    Popup(128,128,128)
end

function Footer()
    
    love.graphics.setColor(0,.5,1)
    love.graphics.rectangle("fill", Layouts.FooterLayout.x, Layouts.FooterLayout.y, Layouts.FooterLayout.width, Layouts.FooterLayout.height)
end

function Healthbar()
    
    -- Background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", Layouts.HealthBarLayout.x, Layouts.HealthBarLayout.y, Layouts.HealthBarLayout.width, Layouts.HealthBarLayout.height)

    -- Healthbar
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", Layouts.HealthBarLayout.x, Layouts.HealthBarLayout.y, Layouts.HealthBarLayout.width * (Player.hp / Player.maxHp), Layouts.HealthBarLayout.height)

end

function Shieldbar()
        -- Background
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", Layouts.ShieldBarLayout.x, Layouts.ShieldBarLayout.y, Layouts.ShieldBarLayout.width, Layouts.ShieldBarLayout.height)
    
        -- ShieldBar
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", Layouts.ShieldBarLayout.x, Layouts.ShieldBarLayout.y, Layouts.ShieldBarLayout.width * (Player.abilities.shield.hp / Player.abilities.shield.maxHP), Layouts.ShieldBarLayout.height)
end

function ControlsLayout(text)
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(0,0,0)
    love.graphics.printf(text, Layouts.ControlsLayout.x, Layouts.ControlsLayout.y, ScreenWidth, "center")
end

-- function StatsButton()
--     if MouseInButton(Layouts.StatusButtonLayout) then
--         love.graphics.setColor(.8, .2, 0)
--     else
--         love.graphics.setColor(0, 1, 0)
--     end

--     -- love.graphics.rectangle(mode,x,y,width,height)
--     love.graphics.rectangle("fill", Layouts.StatusButtonLayout.x, Layouts.StatusButtonLayout.y, Layouts.StatusButtonLayout.width, Layouts.StatusButtonLayout.height)
    
--     love.graphics.setColor(0,0,0)
--     love.graphics.setFont()
--     love.graphics.printf("Stats", Layouts.StatusButtonLayout.x, Layouts.StatusButtonLayout.placement, Layouts.StatusButtonLayout.width, "center")
-- end