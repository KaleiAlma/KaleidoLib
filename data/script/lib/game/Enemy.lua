local Object = require('lib.foundation.Object')
local Task = require('lib.foundation.Task')
local Sound = require('lib.foundation.Sound')
local vars = require('lib.game.vars')


---@class game.enemy
local M = {}


---@class game.Enemy: game.Object
---@field maxhp number
---@field hp number
---@field protect number
---@field dmgt number
---@field no_collide_player boolean
---@field master game.Enemy?
---@field dmg_transfer number?

---@class game.RenderEnemy: game.RenderObject
---@field maxhp number
---@field hp number
---@field protect number
---@field dmgt number
---@field no_collide_player boolean
---@field master game.Enemy?
---@field dmg_transfer number?


---@param self game.Enemy
---@param o game.player.Weapon
function M.Colli(self, o)
    if o.dmg then
        if not o.noscore then
            vars.stage.score = vars.stage.score + 10
        end
        if self.protect <= 0 then
            self.hp = self.hp - o.dmg
            self.dmgt = 4
        end
        if lstg.IsValid(self.master) and self.dmg_transfer and self.master.protect <= 0 then
            self.master.hp = self.master.hp - o.dmg * self.dmg_transfer
        end
    end
    if not o.no_kill_on_collide then
        lstg.Kill(o)
    end
    if o.mute or not o.dmg then return end
    if self.hp > self.maxhp * 0.2 then
        Sound.playSfxRandPitch('damage00', 0.04, 0.4, self.x / 256)
    else
        Sound.playSfxRandPitch('damage01', 0.04, 0.6, self.x / 256)
    end
end


---@class game.enemy.Enemy: foundation.object.class
M.Enemy = Object.createClass()
M.Enemy.render_group = RDR_GROUP.FIELD

---@param hp number
---@param no_collide_player boolean?
---@param wisys game.WalkImageSystem?
---@param ... any
---@return game.enemy.Enemy.obj
function M.Enemy.new(hp, no_collide_player, wisys, ...)
    ---@class game.enemy.Enemy.obj: game.Enemy
    ---@field wisys game.WalkImageSystemInst?
    local self = Object.newInst(M.Enemy)

    self.group = GROUP.ENEMY
    self.layer = LAYER.ENEMY
    self.bound = true
    self.a = 24
    self.b = 24

    if wisys then
        self.wisys = wisys.new(self, ...)
    end

    self.maxhp = hp
    self.hp = hp
    self.protect = 10
    self.dmgt = 0
    self.no_collide_player = not not no_collide_player

    return self
end

---@param self game.enemy.Enemy.obj
function M.Enemy:frame()
    if self.hp <= 0 then
        lstg.Kill(self)
    end

    self.protect = math.max(self.protect - 1, 0)
    self.dmgt = math.max(self.dmgt - 1, 0)

    Task.doFrame(self)

    if self.wisys then self.wisys:frame() end
end

---@param self game.enemy.Enemy.obj
function M.Enemy:render()
    if self.wisys then self.wisys:render() end
end

M.Enemy.colli = M.Colli

---@param self game.enemy.Enemy.obj
function M.Enemy:kill()
    M.DeathEff.new(self.x, self.y)
end


---@class game.enemy.DeathEff: foundation.object.class
M.DeathEff = Object.createClass(true)
M.DeathEff.render_group = RDR_GROUP.FIELD

---@param x number
---@param y number
---@return game.enemy.DeathEff.obj
function M.DeathEff.new(x, y)
    ---@class game.enemy.DeathEff.obj: game.RenderObject
    local self = Object.newInst(M.DeathEff)

    lstg.PlaySound('enep00', 0.3, self.x / 256)

    self.group = GROUP.GHOST
    self.layer = LAYER.ENEMY + 50
    self.bound = false
    self.img = 'misc:bubble'
    self.x = x
    self.y = y

    return self
end


---@param self game.enemy.DeathEff.obj
function M.DeathEff:frame()
    if self.timer >= 30 then
        lstg.Kill(self)
    end

    self._a = 255 * (1 - self.timer / 30)
    self.hscale = self.timer * 0.1 + 0.7
    self.vscale = self.timer * 0.1 + 0.7
end

return M