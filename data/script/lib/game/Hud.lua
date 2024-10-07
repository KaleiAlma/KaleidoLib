local config = require('lib._config').hud

---@class game.hud
local M = {}

function M.init()
end

function M.update()
end

function M.render()
end

-- dynamic return
return require('lib.game.Hud.' .. config.type) --[[@as game.hud]]