local ObjLib = require('lib.foundation.ObjLib')
local Canvas = require('lib.foundation.Canvas')
local Sound = require('lib.foundation.Sound')

local Player = require('lib.game.Player')
local WISys = require('lib.game.WISys').player
local rand = require('lib.game.rand')

local M = {}

M.resdesc = {
    { name = 'player:reimu', type = 'tex', args = {'player/reimu/reimu.png'} },
    { name = 'player:reimu', type = 'imggrp', args = {'player:reimu', 0, -0.5, 32, 48, 8, 3, 0.5, 0.5} },
    { name = 'player:reimu_bullet_red', type = 'img', args = {'player:reimu', 192, 160, 64, 16, 16, 16} },
    { name = 'player:reimu_bullet_red_ef', type = 'ani', args = {'player:reimu', 0, 144, 16, 16, 4, 1, 4} },
    { name = 'player:reimu_bullet_blue', type = 'img', args = {'player:reimu', 0, 160, 16, 16, 16, 16} },
    { name = 'player:reimu_bullet_blue_ef', type = 'ani', args = {'player:reimu', 0, 160, 16, 16, 4, 1, 4} },
    { name = 'player:reimu_bullet_orange', type = 'img', args = {'player:reimu', 64, 176.5, 64, 16, 64, 16} },
    { name = 'player:reimu_option', type = 'img', args = {'player:reimu', 64.25, 144.25, 15.5, 15.5} },
    { name = 'player:reimu_sp_ef', type = 'ps', args = {'player/reimu/sp_ef.psi', 'misc:fuzzy_circle', 16, 16} },
    { name = 'player:reimu_explode', type = 'snd', args = {'sfx/explode.wav'} },
}

function M.postLoad()
    lstg.SetImageState('player:reimu_bullet_red', '', lstg.Color(0xAAFFFFFF))
    lstg.SetImageCenter('player:reimu_bullet_red', 56, 8)

    lstg.SetImageState('player:reimu_bullet_blue', '', lstg.Color(0x88FFFFFF))
    lstg.SetImageState('player:reimu_bullet_orange', '', lstg.Color(0x88FFFFFF))
end

-- forwards declarations

---@class reimu.sp_ef1: foundation.object.class
local sp_ef1 = ObjLib.createClass()
sp_ef1.render_group = RDR_GROUP.FIELD

---@class reimu.sp_ef2: foundation.object.class
local sp_ef2 = ObjLib.createClass()
sp_ef2.render_group = RDR_GROUP.FIELD

---@class reimu.sp_ef3: foundation.object.class
local sp_ef3 = ObjLib.createClass(true)
sp_ef3.render_group = RDR_GROUP.FIELD

---@class reimu.bubble: foundation.object.class
local bubble = ObjLib.createClass(true)
bubble.render_group = RDR_GROUP.FIELD


---@type game.player.chardef
M.chardef = {}
M.chardef.imgs = WISys.imgs8x3('player:reimu')
M.chardef.speed = 4.5
M.chardef.hitbox = 0.5
M.chardef.shoot_time = 4
M.chardef.bomb_time = 240
M.chardef.deathbomb = 15

---@param self game.player.Player.obj
function M.chardef:init()
    self.options = {
        Player.Option.new(self, 'player:reimu_option', -36, -12, -18, 20, 110, 3),
        Player.Option.new(self, 'player:reimu_option', -16, -32,  -6, 28, 100, 3),
        Player.Option.new(self, 'player:reimu_option',  16, -32,   6, 28,  80, 3),
        Player.Option.new(self, 'player:reimu_option',  36, -12,  18, 20,  70, 3),
    }
end

---@param self game.player.Player.obj
function M.chardef:shoot()
    local pitch = 1
    if self.slow then
        pitch = 0.9
    end
    Sound.playSfxRandPitchShift('plst00', pitch, 0.08, 0.3, self.x / 360)
    Player.BulletStraight.new('player:reimu_bullet_red', self.x + 10, self.y, 24, 90, 2)
    Player.BulletStraight.new('player:reimu_bullet_red', self.x - 10, self.y, 24, 90, 2)
    if self.slow then
        for _, opt in ipairs(self.options) do
            local b
            b = Player.Option.shootStraight(opt, 'player:reimu_bullet_orange', 24, 0.3, 90)
            b.x = b.x + 3
            b = Player.Option.shootStraight(opt, 'player:reimu_bullet_orange', 24, 0.3, 90)
            b.x = b.x - 3
        end
    else
        if self.timer % 8 < 4 then
            for _, opt in ipairs(self.options) do
                Player.Option.shootHoming(opt, 'player:reimu_bullet_blue', 8, 0.67, 900)
            end
        end
    end
end

---@param self game.player.Player.obj
function M.chardef:bomb()
    lstg.PlaySound('nep00', 0.8, self.x / 500)
    lstg.PlaySound('slash', 0.8, self.x / 500)
    local rot = rand:integer(360)
    if self.slow then
        -- fantasy seal (concentrate)
        lstg.SetSESpeed('player:reimu_explode', 1)
        for i = 1, 8 do
            sp_ef1.new(self.x, self.y, rot + i * 45, 40 - 10 * i, self)
        end
    else
        -- fantasy seal (spread)
        for i = 1, 6 do
            sp_ef2.new(self.x, self.y, rot + i * 60, 18 - 6 * i, self)
        end
    end
end


function sp_ef1.new(x, y, angle, t, player)
    ---@class reimu.sp_ef1.obj: game.Object
    local self = ObjLib.newInst(sp_ef1)

    self.group = GROUP.SPELL
    self.layer = LAYER.PLAYER_BULLET
    self.img = 'player:reimu_sp_ef'
    self.hscale = 0.44
    self.vscale = 0.44
    self.a = self.a * 1.2
    self.b = self.b * 1.2
    self.x = x
    self.y = y
    self.rot = angle - 50
    self.bound = false

    self.orig_emi = lstg.ParticleGetEmission(self)
    self.emi = self.orig_emi * 0.5
    lstg.ParticleSetEmission(self, self.emi)

    self.no_kill_on_collide = true
    self.trail = 1200
    self.dmg = 2

    self.v = 8
    self.angle = angle - 50
    self.t = t
    self.player = player

    return self
end

---@param self reimu.sp_ef1.obj
function sp_ef1:frame()
    if self.timer < 10 then
        self.emi = math.lerp((self.timer + 1) * 0.1, self.emi, self.orig_emi)
        lstg.ParticleSetEmission(self, self.emi)
        self.rot = self.angle + 5 * self.timer
        self.x = 8 * (10 - self.timer) * lstg.cos(self.rot) + self.player.x
        self.y = 8 * (10 - self.timer) * lstg.sin(self.rot) + self.player.y
    elseif self.timer < 160 + self.t then
        self.hscale = 1.2
        self.vscale = 1.2
        self.rot = self.angle - 4 * self.timer
        self.x = (self.timer - 10) * lstg.cos(self.rot) + self.player.x
        self.y = (self.timer - 10) * lstg.sin(self.rot) + self.player.y
    elseif self.timer < 240 then
        self.no_kill_on_collide = false
        self.dmg = 35

        Player.BulletHoming.frame(self --[[@as game.player.BulletHoming.obj]])
        lstg.SetV(self, self.v, self.rot)

        local b = Canvas.field

        if self.x > b.r then
            self.x = b.r
            self.vx = 0
            self.vy = 0
        end
        if self.x < b.l then
            self.x = b.l
            self.vx = 0
            self.vy = 0
        end
        if self.y > b.t then
            self.y = b.t
            self.vx = 0
            self.vy = 0
        end
        if self.y < b.b then
            self.y = b.b
            self.vx = 0
            self.vy = 0
        end
    elseif self.timer < 250 then
        self.no_kill_on_collide = true
        self.dmg = 0.4
        self.a = self.a * 2
        self.b = self.b * 2
        self.vscale = (self.timer - 240) * 0.5 + 1.2
        self.hscale = (self.timer - 240) * 0.5 + 1.2
    else
        lstg.Kill(self)
    end
end

---@param self reimu.sp_ef1.obj
---@param other game.Bullet | game.Enemy
function sp_ef1:colli(other)
    if not other.indes then
        lstg.Kill(other)
    end
end

---@param self reimu.sp_ef1.obj
function sp_ef1:kill()
    lstg.PlaySound('explode', 0.3, 0)

    local b = Canvas.field
    bubble.new(math.clamp(self.x, b.l + 1, b.r - 1), math.clamp(self.y, b.b + 1, b.t - 1))
    local a = rand:number(360)
    for i = 1, 12 do
        sp_ef3.new(self.x, self.y, rand:number(4, 6), a + i * 30)
    end
end

---@param self reimu.sp_ef1.obj
function sp_ef1:del()
    lstg.PlaySound('explode', 0.3, 0)
    bubble.new(self.x, self.y)
end


function sp_ef2.new(x, y, angle, t, player)
    ---@class reimu.sp_ef2.obj: game.Object
    local self = ObjLib.newInst(sp_ef2)

    self.group = GROUP.SPELL
    self.layer = LAYER.PLAYER_BULLET
    self.img = 'player:reimu_sp_ef'
    self.hscale = 0.4
    self.vscale = 0.4
    self.a = self.a * 1.65
    self.b = self.b * 1.65
    self.x = x
    self.y = y
    self.rot = angle - 48
    self.bound = false

    self.orig_emi = lstg.ParticleGetEmission(self) * 1.4
    self.emi = self.orig_emi * 0.5
    lstg.ParticleSetEmission(self, self.emi)


    self.no_kill_on_collide = true
    self.trail = 1200
    self.dmg = 2.4

    self.v = 8
    self.angle = angle - 48
    self.t = t
    self.player = player

    return self
end

---@param self reimu.sp_ef2.obj
function sp_ef2:frame()
    self.rot = self.angle - 5.2 * self.timer
    if self.timer < 8 then
        self.emi = math.lerp((self.timer + 1) * 0.125, self.emi, self.orig_emi)
        lstg.ParticleSetEmission(self, self.emi)
        self.rot = self.angle + 6 * self.timer
        self.x = 12 * (8 - self.timer) * lstg.cos(self.rot) + self.player.x
        self.y = 12 * (8 - self.timer) * lstg.sin(self.rot) + self.player.y
    elseif self.timer < 88 + self.t then
        self.hscale = 1.3
        self.vscale = 1.3
        self.x = 2.25 * (self.timer - 8) * lstg.cos(self.rot) + self.player.x
        self.y = 2.25 * (self.timer - 8) * lstg.sin(self.rot) + self.player.y
    elseif self.timer < 168 + self.t then
        self.x = 2.25 * (154 + self.t - self.timer * 0.8) * lstg.cos(self.rot) + self.player.x
        self.y = 2.25 * (154 + self.t - self.timer * 0.8) * lstg.sin(self.rot) + self.player.y
        self.emi = self.emi - 0.5
        lstg.ParticleSetEmission(self, self.emi)
    elseif self.timer < 178 + self.t then
        self.a = self.a * 1.25
        self.b = self.b * 1.25
        self.dmg = 0.5
        self.vscale = (self.timer - 168 - self.t) * 0.12 + 1.5
        self.hscale = (self.timer - 168 - self.t) * 0.12 + 1.5
    else
        lstg.Kill(self)
    end
end

---@param self reimu.sp_ef2.obj
---@param other game.Bullet | game.Enemy
function sp_ef2:colli(other)
    if not other.indes then
        lstg.Kill(other)
    end
end

---@param self reimu.sp_ef2.obj
function sp_ef2:kill()
    Sound.playSfxRandPitch('player:reimu_explode', 0.32, 0.3, self.x / 360)

    bubble.new(self.x, self.y)
    local a = rand:number(360)
    for i = 1, 12 do
        sp_ef3.new(self.x, self.y, rand:number(6, 9), a + i * 30)
    end
end

---@param self reimu.sp_ef2.obj
function sp_ef2:del()
    Sound.playSfxRandPitch('player:reimu_explode', 0.32, 0.3, self.x / 360)
    bubble.new(self.x, self.y)
end


local sp_ef3_colors = {lstg.Color(0xFFFF0000), lstg.Color(0xFF00FF00), lstg.Color(0xFF0000FF)}

function sp_ef3.new(x, y, v, angle)
    ---@class reimu.sp_ef3.obj: game.RenderObject
    local self = ObjLib.newInst(sp_ef3)

    self.group = GROUP.GHOST
    self.layer = LAYER.PLAYER_BULLET
    self.img = 'misc:fuzzy_circle'
    self.bound = false
    self.x = x
    self.y = y
    self.hscale = 4
    self.vscale = 4
    self._color = sp_ef3_colors[rand:integer(1, 3)]
    self._blend = 'mul+add'

    lstg.SetV(self, v, angle, true)

    return self
end

---@param self reimu.sp_ef3.obj
function sp_ef3:frame()
    if self.timer >= 30 then
        lstg.Del(self)
    end

    self._a = (30 - self.timer) * 255 / 30
    self.hscale = 4 - self.timer / 15
    self.vscale = 4 - self.timer / 15
end


function bubble.new(x, y)
    ---@class reimu.bubble.obj: game.Object
    local self = ObjLib.newInst(bubble)

    self.group = GROUP.GHOST
    self.layer = LAYER.ENEMY_BULLET_EF
    self.img = 'misc:bubble'
    self.bound = false
    self.x = x
    self.y = y
    self.hscale = 4
    self.vscale = 4

    return self
end

---@param self reimu.bubble.obj
function bubble:frame()
    if self.timer >= 30 then
        lstg.Del(self)
    end

    self._a = (30 - self.timer) * 255 / 30
    self.hscale = self.timer / 15 + 4
    self.vscale = self.timer / 15 + 4
end


return M