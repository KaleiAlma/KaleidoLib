local Object = require('lib.foundation.Object')
local Canvas = require('lib.foundation.Canvas')
local Sound = require('lib.foundation.Sound')
local Task = require('lib.foundation.Task')
local ef_rand = require('lib.foundation.rand')

local Player = require('lib.game.Player')
local instances = require('lib.game.instances')
local Laser = require('lib.game.Laser')
local Move = require('lib.game.Move')
local WISys = require('lib.game.WISys').player
local rand = require('lib.game.rand')

local M = {}

M.resdesc = {
    { name = 'player:marisa', type = 'tex', args = {'player/marisa/marisa.png'} },
    -- { name = 'player:marisa_laser', type = 'tex', args = {'player/marisa/laser.png'} },
    { name = 'player:marisa_spark', type = 'tex', args = {'player/marisa/spark.png'} },
    { name = 'player:marisa', type = 'imggrp', args = {'player:marisa', 0, 0.5, 32, 48, 8, 3, 0.5, 0.5} },
    { name = 'player:marisa_bullet', type = 'img', args = {'player:marisa', 0, 144, 32, 16, 16, 16} },
    { name = 'player:marisa_bullet_ef', type = 'ani', args = {'player:marisa', 0, 144, 32, 16, 4, 1, 4} },
    { name = 'player:marisa_missile', type = 'img', args = {'player:marisa', 192.5, 224, 32, 16, 20, 16} },
    { name = 'player:marisa_missile_ef', type = 'ani', args = {'player:marisa', 64, 224, 32, 32, 4, 1, 2, 3, 3} },
    { name = 'player:marisa_option', type = 'img', args = {'player:marisa', 144, 144, 16, 16} },
    { name = 'player:marisa_bomb_option_1', type = 'img', args = {'player:marisa', 128, 144, 16, 16} },
    { name = 'player:marisa_bomb_option_2', type = 'img', args = {'player:marisa', 160, 144, 16, 16} },
    { name = 'player:marisa_bomb_option_3', type = 'img', args = {'player:marisa', 176, 144, 16, 16} },
    { name = 'player:marisa_laser_light', type = 'img', args = {'player:marisa', 224, 224, 32, 32} },
    { name = 'player:marisa_spark_orig', type = 'img', args = {'player:marisa_spark', 0, 64, 256, 128} },
    { name = 'player:marisa_spark_wave', type = 'img', args = {'player:marisa_spark', 257, 0, 96, 256, 100, 180} },
    { name = 'player:marisa_sp_ef', type = 'ps', args = {'player/marisa/sp_ef.psi', 'misc:star'} },
    { name = 'player:marisa_hit', type = 'ps', args = {'player/marisa/hit.psi', 'misc:star'} },
}

function M.postLoad()
    lstg.SetTextureSamplerState('player:marisa', 'linear+wrap')
    lstg.SetImageState('player:marisa_bullet', '', lstg.Color(0xAAFFFFFF))
    lstg.SetAnimationState('player:marisa_bullet_ef', '', lstg.Color(0xAAFFFFFF))

    lstg.SetImageState('player:marisa_missile', '', lstg.Color(0xEEFFFFFF))
	lstg.SetAnimationState('player:marisa_missile_ef', 'mul+add', lstg.Color(0x70FFFFFF))
    lstg.SetImageState('player:marisa_laser_light', 'mul+add', lstg.Color(0xFFFFFFFF))

    lstg.SetImageState('player:marisa_spark_orig', '', lstg.Color(0xFFDDDDDD))
    -- lstg.SetImageState('player:marisa_spark_wave', 'mul+add', lstg.Color(0xFFFFFFFF))

    lstg.CreateRenderTarget('player:marisa_spark_rt', 256, 128)
    lstg.LoadImage('player:marisa_ndlaser', 'player:marisa_spark_rt', 0, 0, 256, 128)
    lstg.LoadImage('player:marisa_spark', 'player:marisa_spark_rt', 0, 0, 256, 128)
    lstg.SetImageCenter('player:marisa_spark', 0, 64)
end

-- forwards declarations

---@class marisa.option: foundation.object.class
local option = Object.createClass(true)
option.render_group = RDR_GROUP.FIELD

---@class marisa.bomb_option: foundation.object.class
local bomb_option = Object.createClass(true)
bomb_option.render_group = RDR_GROUP.FIELD

---@class marisa.missle: foundation.object.class
local missle = Object.createClass()
missle.render_group = RDR_GROUP.FIELD

---@class marisa.missle_ef: foundation.object.class
local missle_ef = Object.createClass()
missle_ef.render_group = RDR_GROUP.FIELD

---@class marisa.laser: foundation.object.class
local laser = Object.createClass()
laser.render_group = RDR_GROUP.FIELD

---@class marisa.hit_ef: foundation.object.class
local hit_ef = Object.createClass()
hit_ef.render_group = RDR_GROUP.FIELD

---@class marisa.ndlaser: foundation.object.class
local ndlaser = Object.createClass(true)
ndlaser.render_group = RDR_GROUP.FIELD

---@class marisa.sp_ef: foundation.object.class
local sp_ef = Object.createClass()
sp_ef.render_group = RDR_GROUP.FIELD

---@class marisa.spark: foundation.object.class
local spark = Object.createClass(true)
spark.render_group = RDR_GROUP.FIELD

---@class marisa.spark_wave: foundation.object.class
local spark_wave = Object.createClass(true)
spark_wave.render_group = RDR_GROUP.FIELD


---@type game.player.chardef
M.chardef = {}
M.chardef.imgs = WISys.imgs8x3('player:marisa')
M.chardef.speed = 5.2
M.chardef.hitbox = 1
M.chardef.shoot_time = 4
M.chardef.bomb_time = 300

---@param self game.player.Player.obj
function M.chardef:init()
    self.options = {
        option.new(self, -30, 10,  -15, 20, 95),
        option.new(self, -12, 32, -7.5, 29, 90),
        option.new(self,  12, 32,  7.5, 29, 90),
        option.new(self,  30, 10,   15, 20, 85),
    }
    self.lasers = {
        laser.new(self.options[1]),
        laser.new(self.options[2]),
        laser.new(self.options[3]),
        laser.new(self.options[4]),
    }

    self.spark_loaded = false
end

---@param self game.player.Player.obj
function M.chardef:frame()
    self.lasers[1].active = false
    self.lasers[2].active = false
    self.lasers[3].active = false
    self.lasers[4].active = false
    if
        (not lstg.IsValid(instances.dialogue)) and
        (self.death > 90 or self.death <= 0) and
        self.input_state.shoot and
        not self.slow and
        self.nextbomb <= 15
    then
        if self.timer % 10 == 0 then
            lstg.PlaySound('lazer02', 0.25, self.x / 360)
        end
        self.lasers[1].active = true
        self.lasers[2].active = true
        self.lasers[3].active = true
        self.lasers[4].active = true
    end
    if self.nextbomb <= 20 then
        self.slowlock = false
    end
end

---@param self game.player.Player.obj
function M.chardef:render()
    if self.spark_loaded then return end
    lstg.PushRenderTarget('player:marisa_spark_rt')
    lstg.RenderClear(0)
    lstg.SetViewport(0, 256, 0, 128)
    lstg.SetScissorRect(0, 256, 0, 128)
    lstg.SetOrtho(0, 256, 0, 128)

    lstg.Render('player:marisa_spark_orig', 128, 64)

    lstg.PopRenderTarget()
    Canvas.viewModeField()

    self.spark_loaded = true
end

---@param self game.player.Player.obj
function M.chardef:shoot()
    local pitch = 1
    if self.slow then
        pitch = 0.9
    end
    Sound.playSfxRandPitchShift('plst00', pitch, 0.08, 0.3, self.x / 360)
    Player.BulletStraight.new('player:marisa_bullet', self.x + 10, self.y, 24, 90, 2, Player.createBulletBreakEff('player:marisa_bullet_ef', 7))
    Player.BulletStraight.new('player:marisa_bullet', self.x - 10, self.y, 24, 90, 2, Player.createBulletBreakEff('player:marisa_bullet_ef', 7))
    if self.slow then
        if self.timer % 16 < 4 then
            Sound.playSfxRandPitch('msl', 0.1, 0.2, self.x / 360)
            missle.new(self.options[1].x, self.options[1].y)
            missle.new(self.options[4].x, self.options[4].y)
        elseif (self.timer - 8) % 16 < 4 then
            Sound.playSfxRandPitch('msl', 0.1, 0.2, self.x / 360)
            missle.new(self.options[2].x, self.options[2].y)
            missle.new(self.options[3].x, self.options[3].y)
        end
    end
end

---@param self game.player.Player.obj
function M.chardef:bomb()
    lstg.PlaySound('nep00', 1, self.x / 500)
    lstg.PlaySound('slash', 1, self.x / 500)

    self.nextshoot = 285

    if self.slow then
        -- master spark
        self.ndl = false
        for _, opt in ipairs(self.options) do
            local s = sp_ef.new(opt.x, opt.y - 4 , self)
            Task.new(s, function(_)
                Move.toBezier(s, 10, Move.LERP_MODE.DECEL, opt.x, self.y + 60, self.x, self.y + 60)
                Task.wait(15)
                lstg.Kill(s)
            end)
        end
        spark.new(self)
        self.slowlock = true
    else
        -- non-directional laser
        self.ndl = true
        local rot = rand:integer(360)
        local dir = rand:sign()
        for i = 1, 3 do
            bomb_option.new(self, i, i * 120 + rot, dir)
        end
    end
end

function option.new(player, relx, rely, focus_relx, focus_rely, shotangle)
    ---@class marisa.option.obj: game.player.Option.obj
    local self = Player.Option.new(player, 'player:marisa_option', relx, rely, focus_relx, focus_rely, shotangle)
    self.class = option

    return self
end

-- option.frame = Player.Option.frame

---@param self marisa.option.obj
function option:frame()
    Player.Option.frame(self)
    local p = self.player
    if p.nextbomb > 285 and p.ndl then
        self._a = (p.nextbomb - 285) * 255 / 15
    elseif p.nextbomb > 25 and p.ndl then
        self.hide = true
    elseif p.nextbomb > 0 and p.ndl then
        self.hide = false
        self._a = math.min((25 - p.nextbomb) * 255 / 15, 255)
    end
end

---@param self marisa.option.obj
function option:render()
    lstg.DefaultRenderFunc(self)
    local p = self.player

    if
        (not lstg.IsValid(instances.dialogue)) and
        (p.death > 90 or p.death <= 0) and
        p.input_state.shoot and
        not p.slow and
        p.nextbomb <= 0
    then
        lstg.Render('player:marisa_laser_light', self.x, self.y, self.timer * 5, 1 + 0.4 * lstg.sin(self.timer * 30))
    end
end

function bomb_option.new(player, idx, angle, dir)
    ---@class marisa.bomb_option.obj: game.player.Option.obj
    local self = Player.Option.new(player, 'player:marisa_bomb_option_' .. idx, 0, 0, 0, 0, angle)
    self.class = bomb_option

    self.idx = idx
    self.dir = dir

    ndlaser.new(self)

    return self
end

-- bomb_option.frame = Player.Option.frame

---@param self marisa.bomb_option.obj
function bomb_option:frame()
    local d = math.min(self.timer, 40)
    self._a = math.min(self.timer * 25, 255)
    if self.timer >= 270 then
        lstg.Kill(self)
    elseif self.timer >= 260 then
        d = self.timer - 220
        self._a = 255 + (250 - self.timer) * 25
    end
    self.shotangle = self.shotangle + 2 * self.dir
    self.relx = d * lstg.cos(self.shotangle)
    self.rely = d * lstg.sin(self.shotangle)
    self.focus_relx = self.relx
    self.focus_rely = self.rely
    Player.Option.frame(self)
end

---@param x number
---@param y number
function missle.new(x, y)
    ---@class marisa.missle.obj: game.player.BulletStraight.obj
    local self = Player.BulletStraight.new('player:marisa_missile', x, y, 3, 90, 1.4, function(self)
        lstg.PlaySound('msl2', 0.3, self.x / 360)
        local a, r = rand:number(360), rand:number(6)
        missle_ef.new(self.x + r * lstg.cos(a), self.y + r * lstg.sin(a) + 8, 5, 0.01)
    end)
    self.class = missle

    return self
end

---@param self marisa.missle.obj
function missle:frame()
    self.vy = math.min(self.timer / 3 + 3, 12)
end

missle.kill = Player.BulletStraight.kill

function missle_ef.new(x, y, dmg, t)
    ---@class marisa.missle_ef.obj: game.player.BulletBreak.obj
    local self = Player.BulletBreak.new('player:marisa_missile_ef', x, y, 15, dmg)
    self.t2 = t
    self.class = missle_ef

    return self
end

---@param self marisa.missle_ef.obj
function missle_ef:frame()
    if self.timer == 3 and self.t2 > 0 then
        local a, r = rand:number(360), rand:number(6, 16)
        missle_ef.new(self.x + r * lstg.cos(a), self.y + r * lstg.sin(a), self.dmg * 0.86, self.t2 - 1)
        self.dmg = self.dmg * 0.3
    end
    self.dmg = self.dmg * 0.9

    Player.BulletBreak.frame(self)
end

---@param opt game.player.Option.obj
function laser.new(opt)
    ---@class marisa.laser.obj: game.laser.HitscanLaser.obj
    local self = Laser.HitscanLaser.new(GROUP.PLAYER_BULLET, LAYER.PLAYER_BULLET, opt.x, opt.y, opt.shotangle, 16)
    self.class = laser

    self.dmg = 0.25
    self.active = false
    self.opt = opt
    self.x = self.opt.x
    self.y = self.opt.y
    local w_x = 0.5 * self.width * lstg.cos(self.rot)
    local w_y = 0.5 * self.width * lstg.sin(self.rot)
    local l_x = self._length * lstg.cos(self.rot)
    local l_y = self._length * lstg.sin(self.rot)
    self.rdrtbl = {
        {self._x       - w_y, self._y       + w_x, 0,            0, 176, lstg.Color(0x88FFFFFF)},
        {self._x       + w_y, self._y       - w_x, 0,            0, 192, lstg.Color(0x88FFFFFF)},
        {self._x + l_x + w_y, self._y + l_y - w_x, 0, self._length, 192, lstg.Color(0x88FFFFFF)},
        {self._x + l_x - w_y, self._y + l_y + w_x, 0, self._length, 176, lstg.Color(0x88FFFFFF)},
    }
    self.hit_par = lstg.ParticleSystemData('player:marisa_hit')
    self.hit_par:setEmissionFreq(25)

    return self
end

---@param self marisa.laser.obj
function laser:frame()
    self.x = self.opt.x
    self.y = self.opt.y

    Laser.HitscanLaser.frame(self)

    local l_x = self._length * lstg.cos(self.rot)
    local l_y = self._length * lstg.sin(self.rot)

    self.hit_par:Update(1 / 60, self._x + l_x, self._y + l_y, self.rot)

    -- self.hit_par:setSpinVar(2)
    -- self.hit_par:setSpinStart(-2)
    -- self.hit_par:setSpinEnd(-2)
    self.hit_par:setActive(self.active and self._length < self.max_length)

    if not self.active then return end

    local w_x = 0.5 * self.width * lstg.cos(self.rot)
    local w_y = 0.5 * self.width * lstg.sin(self.rot)
    local tick = self.rdrtbl[1][4] - 16
    local col = lstg.Color(0x88FFFFFF)
    if self._length < self.max_length then
        col = lstg.Color(0x884444FF)
    end

    self.rdrtbl[1][1] = self._x - w_y
    self.rdrtbl[1][2] = self._y + w_x
    self.rdrtbl[1][4] = tick
    self.rdrtbl[1][6] = col

    self.rdrtbl[2][1] = self._x + w_y
    self.rdrtbl[2][2] = self._y - w_x
    self.rdrtbl[2][4] = tick
    self.rdrtbl[2][6] = col

    self.rdrtbl[3][1] = self._x + l_x + w_y
    self.rdrtbl[3][2] = self._y + l_y - w_x
    self.rdrtbl[3][4] = tick + self._length
    self.rdrtbl[3][6] = col

    self.rdrtbl[4][1] = self._x + l_x - w_y
    self.rdrtbl[4][2] = self._y + l_y + w_x
    self.rdrtbl[4][4] = tick + self._length
    self.rdrtbl[4][6] = col

end

---@param self marisa.laser.obj
function laser:render()
    if self.active then
        lstg.RenderTexture('player:marisa', 'mul+add', unpack(self.rdrtbl))
    end
    self.hit_par:Render(0.36)
end

local ndlaser_colors = {lstg.Color(0xFF66BB55), lstg.Color(0xFF5588CC), lstg.Color(0xFF9955CC)}

---@param opt marisa.bomb_option.obj
function ndlaser.new(opt)
    ---@class marisa.ndlaser.obj: game.RenderObject
    local self = Object.newInst(ndlaser)

    self.group = GROUP.SPELL
    self.layer = LAYER.PLAYER_BULLET
    self.img = 'player:marisa_ndlaser'
    self.bound = false
    self.x = opt.x
    self.y = opt.y
    self.rot = opt.shotangle
    self.hscale = 2.5
    self.vscale = 0
    self.a = 320
    self.b = 20
    self.hide = true
    self._blend = 'add+add'
    self._color = ndlaser_colors[opt.idx]
    self._a = 0

    self.no_kill_on_collide = true

    self.opt = opt
    self.dmg = 2
end

---@param self marisa.ndlaser.obj
function ndlaser:frame()
    self.rot = self.opt.shotangle
    self.x = self.opt.x + 320 * lstg.cos(self.rot)
    self.y = self.opt.y + 320 * lstg.sin(self.rot)

    if self.timer < 5 then
    elseif self.timer < 20 then
        self._a = (self.timer - 5) * 255 / 15
        self.vscale = (self.timer - 5) * 0.02
        self.hide = false
    elseif self.timer < 255 then
    elseif self.timer < 270 then
        self._a = (270 - self.timer) * 255 / 15
        self.vscale = (270 - self.timer) * 0.02
    else
        lstg.Kill(self)
    end
end

---@param self marisa.ndlaser.obj
---@param other game.Object
function ndlaser:colli(other)
    if not other.indes then
        lstg.Kill(other)
    end
end

function sp_ef.new(x, y, player)
    ---@class marisa.sp_ef.obj: game.Object
    local self = Object.newInst(sp_ef)

    self.group = GROUP.GHOST
    self.layer = LAYER.PLAYER_BULLET
    self.img = 'player:marisa_sp_ef'
    self.hscale = 0.2
    self.vscale = 0.2
    self.x = x
    self.y = y
    self.bound = false

    self.player = player
    self.orig_px = player.x
    self.orig_py = player.y

    return self
end

---@param self marisa.sp_ef.obj
function sp_ef:frame()
    Task.doFrame(self)
    lstg.ParticleSetEmission(self, 80 - self.timer * 8.8)

    self.x = self.x + self.player.x - self.orig_px
    self.y = self.y + self.player.y - self.orig_py
end


---@param player game.player.Player.obj
function spark.new(player)
    ---@class marisa.spark.obj: game.RenderObject
    local self = Object.newInst(spark)

    self.group = GROUP.GHOST
    self.layer = LAYER.PLAYER_BULLET
    self.img = 'player:marisa_spark'
    self.bound = false
    self.x = player.x
    self.y = player.y
    self.rot = 90
    self.hscale = 2.5
    self.vscale = 0
    self._blend = 'add+add'
    self._color = lstg.HSVColor(0, 0, 100, 15)
    -- self._a = 0

    self.player = player
end

---@param self marisa.spark.obj
function spark:frame()
    local a, h, s, v = self._color:AHSV()
    self._color = lstg.HSVColor(a, self.timer % 100, 100, 15)

    self.rot = self.rot - self.player.dx * 0.03

    self.x = self.player.x + 10 * lstg.cos(self.rot)
    self.y = self.player.y + 10 * lstg.sin(self.rot)

    if self.timer < 21 then
        self.vscale = 0.125 * self.timer
        self._a = self.timer * 255 * 0.05
    elseif self.timer < 250 then
    elseif self.timer < 270 then
        self.vscale = 0.125 * (270 - self.timer)
        self._a = (270 - self.timer) * 255 * 0.05
    else
        lstg.Kill(self)
    end

    if self.timer % 12 == 0 then
        spark_wave.new(self)
    end
end


---@param spark marisa.spark.obj
function spark_wave.new(spark)
    ---@class marisa.spark_wave.obj: game.RenderObject
    local self = Object.newInst(spark_wave)

    self.group = GROUP.SPELL
    self.layer = LAYER.PLAYER_BULLET
    self.img = 'player:marisa_spark_wave'
    self.bound = true
    self.x = spark.x
    self.y = spark.y
    self.rot = spark.rot
    self.hscale = 0
    self.vscale = 0
    self._blend = 'add+add'
    self._color = lstg.HSVColor(0, 50, 100, 20)
    -- self._a = 0

    self.spark = spark
    self.dist = 0

    self.no_kill_on_collide = true

    self.dmg = 1.45
end

---@param self marisa.spark_wave.obj
function spark_wave:frame()
    local sp = self.spark

    if not lstg.IsValid(sp) then
        lstg.Kill(self)
        return
    end

    self._color = lstg.HSVColor(0, (sp.timer + 50) % 100, 100, 20)
    self._a = sp._a

    self.rot = sp.rot
    self.dist = self.dist + 12

    self.x = sp.x + self.dist * lstg.cos(self.rot)
    self.y = sp.y + self.dist * lstg.sin(self.rot)

    self.hscale = math.min(self.timer * 0.25, 1.3)
    self.vscale = sp.vscale * 0.6 - math.max(1.3 - 0.08 * self.timer, 0) * sp.vscale * 0.44
end

---@param self marisa.spark_wave.obj
---@param other game.Object
function spark_wave:colli(other)
    if not other.indes then
        lstg.Kill(other)
    end
end

return M