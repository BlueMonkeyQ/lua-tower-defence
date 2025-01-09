function Header()
    
    love.graphics.setColor(0,.5,1)
    love.graphics.rectangle("fill", Layouts.HeaderLayout.x, Layouts.HeaderLayout.y, Layouts.HeaderLayout.width, Layouts.HeaderLayout.height)
end

function GameWindow()
    love.graphics.setColor(0,1,0)
    love.graphics.rectangle("line", Layouts.GameWindowLayout.x, Layouts.GameWindowLayout.y, Layouts.GameWindowLayout.width, Layouts.GameWindowLayout.height)
end

function Popup()
    love.graphics.setColor(0,1,0)
    love.graphics.rectangle("line", Layouts.PopupLayout.x, Layouts.PopupLayout.y, Layouts.PopupLayout.width, Layouts.PopupLayout.height)
end

function Footer()
    
    love.graphics.setColor(0,.5,1)
    love.graphics.rectangle("fill", Layouts.FooterLayout.x, Layouts.FooterLayout.y, Layouts.FooterLayout.width, Layouts.FooterLayout.height)
end

function Healthbar()
    
    -- Healthbar Background
    love.graphics.setColor(0.2, 0.2, 0.2)  -- Dark gray for the empty bar
    love.graphics.rectangle("fill", Layouts.HealthBarLayout.x, Layouts.HealthBarLayout.y, Layouts.HealthBarLayout.width, Layouts.HealthBarLayout.height)

    -- Healthbar
    love.graphics.setColor(0, 1, 0)  -- Green color for the health bar
    love.graphics.rectangle("fill", Layouts.HealthBarLayout.x, Layouts.HealthBarLayout.y, Layouts.HealthBarLayout.width * (Player.hp / Player.maxHp), Layouts.HealthBarLayout.height)

end