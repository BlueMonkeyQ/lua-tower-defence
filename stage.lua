Stage = {}
Stage.index = Stage

function Stage:new()
    self.font = love.graphics.newFont(30)
    return Stage
end

function Stage:draw()
    love.graphics.setCanvas()

    -- Run Info
    -- love.graphics.print(text,x,y,r,sx,sy,ox,oy)
    love.graphics.setFont(self.font)
    love.graphics.printf(Director.score, BaseLayouts.GameWindowLayout.x, BaseLayouts.GameWindowLayout.y, BaseLayouts.GameWindowLayout.width, "right")

    -- Player
    DrawPlayer()
    Shieldbar()
    Healthbar()
end