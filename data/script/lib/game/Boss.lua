local ObjLib = require('lib.foundation.ObjLib')
local Task = require('lib.foundation.Task')
local Sound = require('lib.foundation.Sound')
local Enemy = require('lib.game.Enemy')
local vars = require('lib.game.vars')

---@class game.boss
local M = {}

---@class game.boss.bossdef
---
--- images for boss walk image system, undefined (nueball) sprite is
--- used if this is nil
---@field imgs game.wisys.boss.imgs? 
---
--- 
---@field cards
---
--- callbacks
---
---@field init game.player.callback? init callback
---@field frame game.player.callback? frame callback
---@field render game.player.callback? render callback
---@field colli game.player.callback? collision callback
---@field prespell game.player.callback? pre-spell callback (called before every pattern)
---@field postspell game.player.callback? post-spell callback (called after every pattern)

---@class game.boss.Boss: foundation.object.class
M.Boss = ObjLib.createClass()
M.Boss.render_group = RDR_GROUP.FIELD

---@param bossdef game.boss.bossdef
---@return game.boss.Boss.obj
function M.Boss.new(bossdef)
    ---@class game.boss.Boss.obj: game.Enemy
    ---@field wisys game.WalkImageSystemInst?
    local self = ObjLib.newInst(M.Boss)

    self.group = GROUP.ENEMY
    self.layer = LAYER.ENEMY
    self.bound = true
    self.a = 24
    self.b = 24

    if wisys then
        self.wisys = wisys.new(self, wisysargs)
    end

    self.maxhp = hp
    self.hp = hp
    self.protect = 10
    self.dmgt = 0
    self.no_collide_player = not not no_collide_player

    return self
end


M.Boss.colli = Enemy.Colli

return M