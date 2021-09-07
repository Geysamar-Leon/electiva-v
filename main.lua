--Integrantes
-- Miguel Pellegrino
-- Geysamar Leon
-- Javier Pineda
-- Heli Rincon
-- Eliam Manuitt

print("Primeras andanzas")


log = require "modules/log/log"
local push = require "modules/push/push"

GAME_WIDTH, GAME_HEIGHT = 384, 216 
COLOR_BACKGROUND = {0.1, 0.1, 0.1}
COLOR_MAIN = {1, 1, 1}
COLOR_ACCENT = {0.2, 0.94901960784314, 0.57647058823529}

high_score = 0

function love.load()
    log.level = "trace" 
    log.info("Iniciando")
    love.mouse.setVisible(false)

    love.graphics.setDefaultFilter("nearest", "linear")

    atlas = love.graphics.newImage("assets/8593.png") 

    font = love.graphics.newFont("assets/fonts/space_invaders.ttf", 7) 
    love.graphics.setFont(font)

    local window_width, window_height = love.window.getDesktopDimensions()
    if love.window.getFullscreen() then
        log.debug("Escalando en pantalla completa")
    else
        log.debug("Escalando dentro de una ventana")
        window_width, window_height = window_width * .7, window_height * .7
    end
    push:setupScreen(
        GAME_WIDTH,
        GAME_HEIGHT,
        window_width,
        window_height,
        {
            fullscreen = love.window.getFullscreen(),
            resizable = true,
            canvas = false,
            pixelperfect = false,
            highdpi = true,
            streched = false
        }
    )

    math.randomseed(os.time())
    change_screen(require("screens/menu"))
end

function love.update(dt)
    screen.update(dt)
end

function love.draw()
    push:start()
    screen.draw()
    push:finish()
end

function love.keypressed(key, scancode, isrepeat)
    screen.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
    screen.keyreleased(key, scancode, isrepeat)
end

function love.resize(w, h)
    log.debug("Redimensionando ventana a " .. w .. " x " .. h .. "px")
    push:resize(w, h)
end

function change_screen(new_screen)
    screen = new_screen
    log.debug("Cargando pantalla: " .. screen.name)
    screen.load()
end

function dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end
