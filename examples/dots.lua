-- a more modern take on https://github.com/szymonkaliski/Dotfiles/blob/ae42c100a56c26bc65f6e3ca2ad36e30b558ba10/Dotfiles/hammerspoon/utils/spaces/dots.lua

local spaces = require("hs.spaces")
local screen = require("hs.screen")
local canvas = require("hs.canvas")

local module = {}

-- display as circle or "squashed rounded rect"
module.circle        = false

-- dot diameter
module.radius        = 4

-- distance between dot centers
module.distance      = 16

-- base dot color
module.color         = { white = 0.7, alpha = 0.45 }

-- current space on non-active screen
module.selectedColor = { white = 0.7, alpha = 0.95 }

-- current space on active screen
module.activeColor   = { green = 0.5, alpha = 0.75 }

local cache = {
    running = false,
    watchers = {},
    dots     = {}
}

local clearDots = function()
    for _, v in pairs(cache.dots) do v:hide():delete() end
    cache.dots = {}
end

local drawDots = function()
    local focusedSpace = spaces.focusedSpace()
    local activeSpaces = spaces.activeSpaces()
    local allSpaces    = spaces.allSpaces()
    clearDots()

    for _, display in ipairs(screen.allScreens()) do
        local displayFrame  = display:fullFrame()
        local displayUUID   = display:getUUID()
        local displaySpaces = allSpaces[displayUUID]

        if displaySpaces then -- (NEED TO CONFIRM) when screens don't have separate spaces, it won't appear in the layout
            local dotCanvas = canvas.new{
                x = displayFrame.x + (displayFrame.w - (module.radius * 2 + (#displaySpaces - 1) * module.distance)) / 2,
                y = displayFrame.y + displayFrame.h - module.radius * (module.circle and 2 or 1),
                w = module.radius * 2 + (#displaySpaces - 1) * module.distance,
                h = module.radius * (module.circle and 2 or 1),
            }:behavior(canvas.windowBehaviors.canJoinAllSpaces)
             :level(canvas.windowLevels.popUpMenu)
             :show()

            for i = 1, #displaySpaces, 1 do
                local spaceID = displaySpaces[i]

                dotCanvas[i] = {
                    id        = tostring(spaceID),
                    type      = "circle",
                    action    = "fill",
                    center    = {
                        x = (i - 1) * module.distance + module.radius,
                        y = module.radius / (module.circle and 1 or 2)
                    },
                    radius    = module.radius,
                    fillColor = (spaceID == focusedSpace              and module.activeColor)   or
                                (spaceID == activeSpaces[displayUUID] and module.selectedColor) or
                                module.color
                }
            end
            cache.dots[displayUUID] = dotCanvas
        end
    end
end

module.start = function()
    if not cache.running then
        cache.running = true
        cache.watchers.spaces = spaces.watcher.new(drawDots):start()
        cache.watchers.screen = screen.watcher.newWithActiveScreen(drawDots):start()
        drawDots()
    end
    return module
end

module.stop = function()
    if cache.running then
        for _, v in pairs(cache.watchers) do v:stop() end
        cache.watchers = {}
        clearDots()
        cache.running = false
    end
    return module
end

module.start()

return module
