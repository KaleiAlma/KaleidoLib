local config = require('lib._config').vars
local seedrand = require('random').splitmix64()
seedrand:seed(os.time())

---@class game.vars
local M = {}

--------------------------------------------------------------------------------
-- player

---@class game.vars.player
M.player = {}
M.player.life = 2
M.player.bomb = 3
if config.enable_power then
    M.player.power = 100
end
M.player.name = ''

--------------------------------------------------------------------------------
-- stage

---@class game.vars.stage
M.stage = {}
M.stage.rng_seed = seedrand:integer()
M.stage.score = 0
M.stage.hiscore = 0
M.stage.graze = 0
M.stage.replay = false

--------------------------------------------------------------------------------
-- boss

---@class game.vars.boss
M.boss = {}
M.boss.sc_bonus = 0

return M