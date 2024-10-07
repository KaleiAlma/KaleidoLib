local Canvas = require('lib.foundation.Canvas')
local ObjLib = require('lib.foundation.ObjLib')
local Task = require('lib.foundation.Task')
local Tasker = require('lib.game.Tasker')
local instances = require('lib.game.instances')

---@class game.bullet
local M = {}

---@class game.Bullet: game.Object
---@field indes boolean
---@field infinite_graze boolean
---@field grazed boolean

---@class game.RenderBullet: game.RenderObject
---@field indes boolean
---@field infinite_graze boolean
---@field grazed boolean

--------------------------------------------------------------------------------
-- constants and variables
--#region

---@enum game.bullet.color
M.COLOR = {
    DEEP_RED = 1,
    RED = 2,
    DEEP_PURPLE = 3,
    PURPLE = 4,
    DEEP_BLUE = 5,
    BLUE = 6,
    ROYAL_BLUE = 7,
    CYAN = 8,
    DEEP_GREEN = 9,
    GREEN = 10,
    CHARTREUSE = 11,
    YELLOW = 12,
    GOLDEN_YELLOW = 13,
    ORANGE = 14,
    DEEP_GRAY = 15,
    GRAY = 16,
}

local bullet_data = require('assets.game.bullet').data.bullet_data

--#endregion
--------------------------------------------------------------------------------
-- bullet classes
--#region

---@class game.bullet.Bullet: foundation.object.class
M.Bullet = ObjLib.createClass(true)
M.Bullet.render_group = RDR_GROUP.FIELD

---@param bullet_type string
---@param color game.bullet.color
---@param indestructible boolean?
---@return game.bullet.Bullet.obj
function M.Bullet.new(bullet_type, color, indestructible)
    ---@class game.bullet.Bullet.obj: game.RenderBullet
    local self = ObjLib.newInst(M.Bullet)

    self.group = GROUP.ENEMY_BULLET
    self.indes = not not indestructible
    self.colli = false
    local idx
    if bullet_data[bullet_type][1] == 16 then
        idx = color
    else
        idx = math.floor((color + 1) / 2)
    end
    self.color = color
    self.bullet_type = bullet_type
    self.blend = bullet_data[bullet_type][3]
    self._blend = self.blend
    self.img = 'bullet:'..bullet_type..idx
    self.layer = LAYER.ENEMY_BULLET - bullet_data[bullet_type][2] + color * 0.00001
    self.wait = 0

    Tasker.new(function()
        for i = 1, 12 do
            self._a = i * 255 / 12
            self.hscale = (12 - i) / 12 + 1
            self.vscale = (12 - i) / 12 + 1
            Task.wait()
        end
        self.colli = true
    end)

    return self
end

---@param self game.bullet.Bullet.obj
function M.Bullet:kill()
    -- Item.ValueMinor.new(self.x, self.y)  
    local b = Canvas.field.bound
    if lstg.BoxCheck(self, b.l, b.r, b.b, b.t) then
        M.BulletBreak.new(self)
    end
end

---@param self game.bullet.Bullet.obj
function M.Bullet:del()
    local b = Canvas.field.bound
    if lstg.BoxCheck(self, b.l, b.r, b.b, b.t) then
        M.BulletBreak.new(self)
    end
end

---@class game.bullet.BulletBreak: foundation.object.class
M.BulletBreak = ObjLib.createClass(true)
M.BulletBreak.render_group = RDR_GROUP.FIELD

---@param bullet game.bullet.Bullet.obj
---@return game.bullet.BulletBreak.obj
function M.BulletBreak.new(bullet)
    ---@class game.bullet.BulletBreak.obj: game.RenderObject
    local self = ObjLib.newInst(M.BulletBreak)

    self.group = GROUP.GHOST
    self.color = bullet.color
    self.bullet_type = bullet.bullet_type
    self.blend = bullet.blend
    self._blend = bullet._blend
    self.img = bullet.img
    self.x = bullet.x
    self.y = bullet.y
    self.rot = bullet.rot
    self.hscale = bullet.hscale
    self.vscale = bullet.vscale
    self.dhscale = bullet.hscale / 24
    self.dvscale = bullet.vscale / 24
    self.omiga = bullet.omiga
    self.vx = bullet.vx
    self.vy = bullet.vy
    self.ax = -bullet.vx * 0.016
    self.ay = -bullet.vy * 0.016
    self.layer = bullet.layer - 50
    self.bound = true

    return self
end

---@param self game.bullet.BulletBreak.obj
function M.BulletBreak:frame()
    self.hscale = self.hscale + self.dhscale
    self.vscale = self.vscale + self.dvscale
    self._a = 255 - self.timer * 10.6
    if self.timer >= 25 then
        lstg.Del(self)
    end
end

---@class game.bullet.RGBBullet: foundation.object.class
M.RGBBullet = ObjLib.createClass(true)
M.RGBBullet.render_group = RDR_GROUP.FIELD

---@param bullet_type string
---@param color lstg.Color
---@param indestructible boolean?
---@return game.bullet.RGBBullet.obj
function M.RGBBullet.new(bullet_type, color, indestructible)
    ---@class game.bullet.RGBBullet.obj: game.RenderObject
    local self = ObjLib.newInst(M.RGBBullet)

    -- if indestructible then
    --     self.group = GROUP.INDES
    -- else
    --     self.group = GROUP.ENEMY_BULLET
    -- end
    self.group = GROUP.ENEMY_BULLET
    self.indes = indestructible
    self.colli = false
    local idx
    if bullet_data[bullet_type][1] == 16 then
        idx = 15
    else
        idx = 8
    end
    self.color = color
    self._color = color
    self.bullet_type = bullet_type
    self.blend = bullet_data[bullet_type][3]
    if self.blend == '' then
        self.blend = 'add+alpha'
    elseif self.blend == 'mul+add' then
        self.blend = 'add+add'
    end
    self._blend = self.blend
    self.img = 'bullet:'..bullet_type..idx
    self.layer = LAYER.ENEMY_BULLET - bullet_data[bullet_type][2]
    self.wait = 0

    local _a = color.a
    Tasker.new(function()
        for i = 1, 12 do
            self._a = i * _a / 12
            self.hscale = (12 - i) / 12 + 1
            self.vscale = (12 - i) / 12 + 1
            Task.wait()
        end
        self.colli = true
    end)

    return self
end

---@param self game.bullet.RGBBullet.obj
function M.RGBBullet:kill()
    -- Item.ValueMinor.new(self.x, self.y)  
    local b = Canvas.field.bound
    if lstg.BoxCheck(self, b.l, b.r, b.b, b.t) then
        ObjLib.newInst(M.RGBBulletBreak, self)
    end
end

---@param self game.bullet.RGBBullet.obj
function M.RGBBullet:del()
    local b = Canvas.field.bound
    if lstg.BoxCheck(self, b.l, b.r, b.b, b.t) then
        ObjLib.newInst(M.RGBBulletBreak, self)
    end
end

---@class game.bullet.RGBBulletBreak: foundation.object.class
M.RGBBulletBreak = ObjLib.createClass(true)
M.RGBBulletBreak.render_group = RDR_GROUP.FIELD


---@param bullet game.bullet.RGBBullet.obj
---@return game.bullet.RGBBulletBreak.obj
function M.RGBBulletBreak.new(bullet)
    ---@class game.bullet.RGBBulletBreak.obj: game.RenderObject
    local self = ObjLib.newInst(M.RGBBulletBreak)

    self.group = GROUP.GHOST
    self.color = bullet.color
    self._color = bullet._color
    self.bullet_type = bullet.bullet_type
    self.blend = bullet.blend
    self._blend = bullet._blend
    self.img = bullet.img
    self.x = bullet.x
    self.y = bullet.y
    self.rot = bullet.rot
    self.hscale = bullet.hscale
    self.vscale = bullet.vscale
    self.dhscale = bullet.hscale / 24
    self.dvscale = bullet.vscale / 24
    self.omiga = bullet.omiga
    self.vx = bullet.vx
    self.vy = bullet.vy
    self.ax = -bullet.vx / 15.5
    self.ay = -bullet.vy / 15.5
    self.layer = bullet.layer - 50
    self.bound = true

    return self
end

---@param self game.bullet.RGBBulletBreak.obj
function M.RGBBulletBreak:frame()
    self.hscale = self.hscale + self.dhscale
    self.vscale = self.vscale + self.dvscale
    self._a = 255 - self.timer * 10.6
    if self.timer >= 25 then
        lstg.Del(self)
    end
end

--#endregion
--------------------------------------------------------------------------------
-- utility functions and classes
--#region

--- Fires a single bullet.
---@param bullet_type string
---@param color game.bullet.color
---@param x number
---@param y number
---@param v number
---@param ang number
---@param aim boolean?
---@param indestructible boolean?
---@param wait integer?
---@return game.bullet.Bullet.obj
function M.fire(bullet_type, color, x, y, v, ang, aim, indestructible, wait)
    local b = M.Bullet.new(bullet_type, color, indestructible)
    b.x = x
    b.y = y
    if aim and lstg.IsValid(instances.player) then
        ang = ang + lstg.Angle(b, instances.player)
    end
    if wait then
        b.rot = ang
        b.wait = wait
        Tasker.new(function()
            Task.wait(wait)
            if lstg.IsValid(b) then
                lstg.SetV(b, v, ang, true)
            end
        end)
    else
        lstg.SetV(b, v, ang, true)
    end
    return b
end

--- Fires a single (RGB) bullet.
---@param bullet_type string
---@param color lstg.Color
---@param x number
---@param y number
---@param v number
---@param ang number
---@param aim boolean?
---@param indestructible boolean?
---@param wait integer?
---@return game.bullet.RGBBullet.obj
function M.fireRGB(bullet_type, color, x, y, v, ang, aim, indestructible, wait)
    local b = M.RGBBullet.new(bullet_type, color, indestructible)
    b.x = x
    b.y = y
    if aim and lstg.IsValid(instances.player) then
        ang = ang + lstg.Angle(b, instances.player)
    end
    if wait then
        b.rot = ang
        b.wait = wait
        Tasker.new(function()
            Task.wait(wait)
            if lstg.IsValid(b) then
                lstg.SetV(b, v, ang, true)
            end
        end)
    else
        lstg.SetV(b, v, ang, true)
    end
    return b
end

--- Fires a group of bullets.
---@param bullet_type string
---@param color game.bullet.color
---@param x number
---@param y number
---@param v number
---@param ang number
---@param n integer
---@param spread number
---@param aim boolean?
---@param indestructible boolean?
---@param wait integer?
---@return game.bullet.Bullet.obj[]
function M.fireGroup(bullet_type, color, x, y, v, ang, n, spread, aim, indestructible, wait)
    local l = {}
    if aim and lstg.IsValid(instances.player) then
        ang = ang + lstg.Angle(x, y, instances.player)
    end
    local da = spread / (n)
    ang = ang - da * (n + 1) / 2
    for i = 1, n do
        l[i] = M.Bullet.new(bullet_type, color, indestructible)
        l[i].x = x
        l[i].y = y
    end
    if wait then
        for i, b in ipairs(l) do
            b.rot = ang + da * i
            b.wait = wait
        end
        Tasker.new(function()
            Task.wait(wait)
            for i, b in ipairs(l) do
                if lstg.IsValid(b) then
                    lstg.SetV(b, v, ang + da * i, true)
                end
            end
        end)
    else
        for i, b in ipairs(l) do
            lstg.SetV(b, v, ang + da * i, true)
        end
    end
    return l
end

--- Fires a group of (RGB) bullets.
---@param bullet_type string
---@param color lstg.Color
---@param x number
---@param y number
---@param v number
---@param ang number
---@param n integer
---@param spread number
---@param aim boolean?
---@param indestructible boolean?
---@param wait integer?
---@return game.bullet.RGBBullet.obj[]
function M.fireGroupRGB(bullet_type, color, x, y, v, ang, n, spread, aim, indestructible, wait)
    local l = {}
    if aim and lstg.IsValid(instances.player) then
        ang = ang + lstg.Angle(x, y, instances.player)
    end
    local da = spread / (n)
    ang = ang - da * (n + 1) / 2
    for i = 1, n do
        l[i] = M.RGBBullet.new(bullet_type, color, indestructible)
        l[i].x = x
        l[i].y = y
    end
    if wait then
        for i, b in ipairs(l) do
            b.rot = ang + da * i
            b.wait = wait
        end
        Tasker.new(function()
            Task.wait(wait)
            for i, b in ipairs(l) do
                if lstg.IsValid(b) then
                    lstg.SetV(b, v, ang + da * i, true)
                end
            end
        end)
    else
        for i, b in ipairs(l) do
            lstg.SetV(b, v, ang + da * i, true)
        end
    end
    return l
end

---@class game.bullet.BulletDeleter: foundation.object.class
M.BulletDeleter = ObjLib.createClass()

---@param x number
---@param y number
---@param kill_indes boolean?
---@param kill boolean? true -> use `lstg.Kill`, false -> use `lstg.Del`
---@return game.bullet.BulletDeleter.obj
function M.BulletDeleter.new(x, y, kill_indes, kill)
    ---@class game.bullet.BulletDeleter.obj: game.Bullet
    local self = ObjLib.newInst(M.BulletDeleter)

    self.group = GROUP.PLAYER
    self.x = x
    self.y = y
    self.a = 1
    self.b = 1

    self.kill_indes = not not kill_indes

    self.delfunc = lstg.Del
    if kill then
        self.delfunc = lstg.Kill
    end

    return self
end

---@param self game.bullet.BulletDeleter.obj
function M.BulletDeleter:frame()
    if self.timer >= 60 then
        lstg.Del(self)
    end
    self.a = self.timer * 18
    self.b = self.timer * 18
end

---@param self game.bullet.BulletDeleter.obj
---@param other game.Bullet
function M.BulletDeleter:colli(other)
    if other.group == GROUP.ENEMY_BULLET and (self.kill_indes or not other.indes) then
        self.delfunc(other)
    end
end

--#endregion

return M