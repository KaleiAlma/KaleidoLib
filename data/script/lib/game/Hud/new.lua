local config = require('lib._config').hud.setting.new
local Canvas = require('lib.foundation.Canvas')
local vars = require('lib.game.vars')

local loader

---@class game.hud.new: game.hud
local M = {}
function M.init()
end

function M.update()
    
end

function M.render()
    lstg.RenderRect('hud:bg', 0, Canvas.width, 0, Canvas.height)
    lstg.SetImageState('white', '', lstg.Color(0x80000000))
    lstg.RenderRect('white', Canvas.field.screen.l - 60, Canvas.field.screen.l, Canvas.field.screen.b, Canvas.field.screen.b + 388)
    lstg.RenderRect('white', Canvas.field.screen.r, Canvas.field.screen.r + 60, Canvas.field.screen.b, Canvas.field.screen.b + 388)
    for i = 0, vars.player.life - 1 do
        lstg.Render('hud:life', Canvas.field.screen.l - 30, Canvas.field.screen.b + 25 + 48 * i, 0, 0.4)
    end
    for i = 0, vars.player.bomb - 1 do
        lstg.Render('hud:bomb', Canvas.field.screen.r + 30, Canvas.field.screen.b + 25 + 48 * i, 0, 0.4)
    end
end

return M