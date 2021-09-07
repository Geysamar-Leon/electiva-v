local UfoClass = require("gameobjects/ufo")

local Squad = {
    left = 100,
    top = 40, 
    ydist = 15, 
    drop_per_turn = 8, 
    min_speed = 11, 
    max_speed = 80, 
    frame_change_speed_factor = 10 
}

Squad.__index = Squad

function Squad.new()
    local o = {
        vx = function(self)
            -- la velocidad horizontal aumenta cuantos menos ovnis queden
            return self.direction *
                (self.min_speed +
                    (self.max_speed - self.min_speed) * (self.attackers_init_count - #self.attackers) *
                        ((self.attackers_init_count + 1) / (self.attackers_init_count)) /
                        (self.attackers_init_count))
        end,
        vy = function(self)
            -- la velocidad vertical aumentara dependiendo de cuantos ovnis queden
            return self.min_speed +
                (self.max_speed - self.min_speed) * (self.attackers_init_count - #self.attackers) *
                    ((self.attackers_init_count + 1) / (self.attackers_init_count)) /
                    (self.attackers_init_count)
        end,
        frame_max_time = function(self)
            return self.frame_change_speed_factor / math.abs(self:vx())
        end,
        states = {
            moving_sideways = {
                update = function(self, dt)
                    for i, ufo in pairs(self.attackers) do
                        if ufo.state == ufo.states.dead then
                            table.remove(self.attackers, i)
                            self:refresh_first_line_ufo_list()
                        else
                            ufo:update(dt, self:vx() * dt, 0) 
                            if ufo.state == ufo.states.normal and (ufo.x > GAME_WIDTH - ufo.type.width or ufo.x <= 0) then
                                self.next_state = self.states.start_moving_down
                            end
                        end
                    end
                end
            },
            start_moving_down = {
                update = function(self, dt)
                    self.vertical_pixels_traveled = 0
                    self.next_state = self.states.moving_down
                end
            },
            moving_down = {
                update = function(self, dt)
                    self.vertical_pixels_traveled = self.vertical_pixels_traveled + self:vy() * dt
                    for i, ufo in pairs(self.attackers) do
                        if ufo.state == ufo.states.dead then
                            table.remove(self.attackers, i)
                        else
                            ufo:update(dt, 0, self:vy() * dt) 
                        end
                    end
                    if self.vertical_pixels_traveled >= self.drop_per_turn then
                        self.direction = -1 * self.direction
                        self.next_state = self.states.moving_sideways
                    end
                end
            },
            invading = {
                update = function(self, dt)
                end
            }
        }
    }
    o.attackers = {}
    setmetatable(o, Squad) 
    return o
end

function Squad:load()
    local xdist = (GAME_WIDTH - self.left * 2) / 10 
    self.direction = 1 
    self.frame = 1 
    self.frame_elapsed_time = 0 

    self.state = self.states.moving_sideways 
    self.next_state = self.state

    
    self.attackers = {}

    -- Escuadrón inicial de enemigos
    for f = 0, 4 do
        for i = 1, 11 do
            local ufo
            if f < 1 then
                ufo = UfoClass.new("squid")
            elseif f < 3 then
                ufo = UfoClass.new("crab")
            else
                ufo = UfoClass.new("octopus")
            end
            ufo:load(self.left - ufo.type.width / 2 + xdist * (i - 1), self.top + self.ydist * f)
            table.insert(self.attackers, ufo)
        end
    end
    self.attackers_init_count = #self.attackers
    self:refresh_first_line_ufo_list()
end


function Squad:refresh_first_line_ufo_list()
    local f = {}
    for _, ufo_a in pairs(self.attackers) do
        if ufo_a.state == ufo_a.states.normal then
            local has_ufo_below = false
            for _, ufo_b in pairs(self.attackers) do
                if ufo_a.x < ufo_b.x + ufo_b.type.width and ufo_b.x < ufo_a.x + ufo_a.type.width and ufo_a.y < ufo_b.y then
                    has_ufo_below = true
                    break
                end
            end
            if has_ufo_below == false then
                table.insert(f, ufo_a)
            end
        end
    end
    self.first_line_ufos = f
    log.trace("Número de UFOS en primera fila = " .. #self.first_line_ufos)
end

function Squad:draw()
    for _, ufo in pairs(self.attackers) do
        ufo:draw(self.frame)
    end
end

function Squad:update(dt)
   
    self.state.update(self, dt)
    if self.state ~= self.next_state then
        self.state = self.next_state
    end

    
    self.frame_elapsed_time = self.frame_elapsed_time + dt
    if self.frame_elapsed_time >= self:frame_max_time() then
        self.frame_elapsed_time = self.frame_elapsed_time % self:frame_max_time()
        self.frame = self.frame + 1
        if self.frame > 2 then
            self.frame = 1
        end
    end
end

function Squad:y_max()
    local y_max = 0
    for _, ufo in pairs(self.attackers) do
        if (ufo.y + ufo.height) > y_max then
            y_max = ufo.y + ufo.height
        end
    end
    return y_max
end

return Squad
