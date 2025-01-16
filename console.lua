Console = {}
Console.index = Console

function Console:new()
    self.lines = {}
    self.y = 8
    self.baseInput = "~ "
    self.inputText = {}
    self.inputting = true
    self.font = love.graphics.newFont(10)
    Console:addConsoleLine({"Marc", "Ebersberger"})
    Console:addConsoleLine({"Marc", "Ebersberger"})
    return Console
end

function Console:inputLine()
    table.insert(self.lines, {
        x=8, y=self.y,
        text=love.graphics.newText(self.font, self.baseInput)
    })
    self.y = self.y+12
    self.inputting = true
end

function Console:textinput(t)
    if self.inputting then
        table.insert(self.inputText, t)
        self:updateText()
    end
end

function Console:updateText()
    local baseInput = {self.baseInput}
    local inputText = ''
    for _, character in ipairs(self.inputText) do inputText = inputText .. character end
    table.insert(baseInput, inputText)
    self.lines[#self.lines].text:set(baseInput)
end

function Console:addConsoleLine(text)
    table.insert(self.lines, {x=8, y=self.y, text=love.graphics.newText(self.font, text)})
    self.y = self.y + 12
end

function Console:update(dt)
    if self.inputting then
        if TextInput:pressed('return') then
            self.inputting = false
            self.inputText = {}
        end

        if TextInput:pressRepeat('backspace', 0.02, 0.2) then 
            table.remove(self.inputText, #self.inputText) 
            self:updateText()
        end
    end
end

function Console:draw()
    for _, line in ipairs(self.lines) do
        love.graphics.draw(line.text, line.x, line.y)
    end

    if self.inputting and self.cursor_visible then
        local r, g, b = 1,1,1
        love.graphics.setColor(r, g, b, 96)
        local input_text = ''
        for _, character in ipairs(self.inputText) do input_text = input_text .. character end
        local x = 8 + self.font:getWidth('[root]arch~ ' .. input_text)
        love.graphics.rectangle('fill', x, self.lines[#self.lines].y,
      	self.font:getWidth('w'), self.font:getHeight())
        love.graphics.setColor(r, g, b, 255)
    end
end