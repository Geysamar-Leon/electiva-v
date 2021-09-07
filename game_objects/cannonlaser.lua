local CannonLaser = {
    width = 1,
    height = 4,
    vy = 220,
    quad = love.graphics.newQuad(31, 21, 1, 4, atlas:getDimensions())
}

CannonLaser.__index = CannonLaser

function CannonLaser.new()
    local o = {}
    setmetatable(o, CannonLaser) 
    return o
end

function CannonLaser:load()
    self.x = 0
    self.y = 0
    self.shooting = false
end

function CannonLaser:shoot(x_init, y_init)
    self.x = x_init
    self.y = y_init
    self.shooting = true
end

function CannonLaser:update(dt)
    self.y = self.y - self.vy * dt
    if self.y <= -self.height then
        self.shooting = false
    end
end

function CannonLaser:draw()
    love.graphics.draw(atlas, self.quad, self.x, self.y)
end  

return CannonLaser