local Canvas = require('lib.foundation.Canvas')
local KeyInput = require('lib.foundation.KeyInput')
local ObjLib = require('lib.foundation.ObjLib')
local Task = require('lib.foundation.Task')
local Sound = require('lib.foundation.Sound')
local Shapes = require('lib.foundation.Shapes')

local Bullet = require('lib.game.Bullet')
local instances = require('lib.game.instances')
local vars = require('lib.game.vars')
local WISys = require('lib.game.WISys').player

local config = require('lib._config').player

local sfx_rand = require('lib.foundation.rand')

---@class game.player
local M = {}

---@alias game.player.callback fun(self: game.player.Player.obj)

---@class game.player.chardef
---
--- images for player walk image system, no walk image system is
--- created if this is nil
---@field imgs game.wisys.player.imgs? 
---
--- common fields
---
---@field speed number? defaults to 4
---@field slow_speed number? defaults to 2
---@field hitbox number? hitbox size, defaults to 1
---@field grazebox number? graze hitbox size, defaults to 24
---@field shoot_time integer? shoot frames, defaults to 4
---@field bomb_time integer? bomb frames, defaults to 30
---@field special_time integer? special frames, defaults to 30
---@field deathbomb integer? deathbomb frames, defaults to 10
---
--- config-dependent fields
---
--- used only if `_config.player.character_bomb_stock`, defaults to `_config.player.bomb_stock`
---@field bomb_stock integer?
---
--- callbacks
---
---@field init game.player.callback? init callback
---@field frame game.player.callback? frame callback
---@field render game.player.callback? render callback
---@field colli game.player.callback? collision callback
---@field shoot game.player.callback? shoot callback
---@field bomb game.player.callback? bomb callback
---@field special game.player.callback? special callback
---@field actions { [string]: game.player.callback }? extra key actions callbacks

---@class game.player.Weapon: game.Object
---@field dmg number
---@field noscore boolean?
---@field mute boolean?

---@class game.player.RenderWeapon: game.RenderObject
---@field dmg number
---@field noscore boolean?
---@field mute boolean?

--- Finds a suitable target enemy for the given object.
---@param obj game.Object
---@return game.Enemy?
function M.findTarget(obj)
    local maxpri = -1
    local target = nil
    for _, o in lstg.ObjList(GROUP.ENEMY) do
        if o.colli then
            local pri = math.abs(obj.y - o.y) / (math.abs(obj.x - o.x) + 0.01)
            if pri > maxpri then
                maxpri = pri
                target = o --[[@as game.Enemy]]
            end
        end
    end

    return target
end

--------------------------------------------------------------------------------
-- player class
--#region

---@class game.player.Player: foundation.object.class
M.Player = ObjLib.createClass(true)
M.Player.render_group = RDR_GROUP.FIELD

local inputs = {'up', 'down', 'left', 'right', 'shoot', 'bomb', 'special', 'slow'}
for _, act in ipairs(config.actions) do
    table.insert(inputs, act)
end

---@param chardef game.player.chardef
---@return game.player.Player.obj
function M.Player.new(chardef)
    ---@class game.player.Player.obj: lstg.GameRenderObject
    ---@field options game.player.Option.obj[]?
    local self = ObjLib.newInst(M.Player)
    instances.player = self

    -- defaults --

    chardef.speed = chardef.speed or 4
    chardef.slow_speed = chardef.slow_speed or 2
    chardef.hitbox = chardef.hitbox or 1
    chardef.grazebox = chardef.grazebox or 24
    chardef.shoot_time = chardef.shoot_time or 4
    chardef.bomb_time = chardef.bomb_time or 90
    chardef.special_time = chardef.special_time or 30
    chardef.deathbomb = chardef.deathbomb or 10

    -- game object properties --

    self.group = GROUP.PLAYER
    self.layer = LAYER.PLAYER
    self.x = 0
    self.y = -176
    self.bound = false
    -- self.a = chardef.hitbox
    -- self.b = chardef.hitbox

    -- tables --

    if chardef.imgs then
        self.wisys = WISys.new(self, chardef.imgs)
    end
    self.chardef = chardef

    -- player variables --

    self.lock = false
    self.slow = false
    self.slowlock = false
    self.slow_transition = 0
    self.optx = 0
    self.opty = -176
    self.death = 0
    self.protect = 0
    self.nextshoot = 0
    self.nextbomb = 0
    self.nextspecial = 0
    self.nextaction = {}
    for _, act in ipairs(config.actions) do
        self.nextaction[act] = 0
    end

    self.grazer = M.Grazer.new(self)

    -- input state init --

    ---@type { [string]: boolean }
    self.input_state = {}
    for _, inp in ipairs(inputs) do
        self.input_state[inp] = false
    end

    -- call init --

    if chardef.init then chardef.init(self) end

    return self
end

---@param self game.player.Player.obj
function M.Player:getInput()
    if vars.stage.replay then
        -- TODO: replays
    else
        for _, inp in ipairs(inputs) do
            self.input_state[inp] = KeyInput.keyDown(inp)
        end
    end
end

---@param self game.player.Player.obj
function M.Player:frame()
    local c = self.chardef

    M.Player.getInput(self)

    -- movement handling --

    local dx = 0
    local dy = 0
    local v = c.speed
    local slowmod = -0.15 -- for later (vars update)
    self.slow = self.input_state.slow or self.slowlock
    if self.slow then
        v = c.slow_speed
        slowmod = 0.15
    end
    if self.input_state.up then
        dy = dy + 1
    end
    if self.input_state.down then
        dy = dy - 1
    end
    if self.input_state.left then
        dx = dx - 1
    end
    if self.input_state.right then
        dx = dx + 1
    end
    if dx * dy ~= 0 then
        v = v * math.sqrt2_d2
    end
    local vx = dx * v
    local vy = dy * v
    local b = Canvas.field.player_bound
    self.x = math.clamp(self.x + vx, b.l, b.r)
    self.y = math.clamp(self.y + vy, b.b, b.t)

    -- death handling --

    -- TODO: different death styles?

    if self.death > 90 or self.death <= 0 then -- not dead
    elseif self.death == 90 then -- register death
        self.protect = 360
        vars.player.life = vars.player.life - 1

        local bomb_stock = config.bomb_stock
        if config.character_bomb_stock and c.bomb_stock then
            bomb_stock = c.bomb_stock --[[@as integer]] -- clear warning
        end
        if config.lose_bombs_on_death then
            vars.player.bomb = bomb_stock
        else
            vars.player.bomb = math.max(vars.player.bomb, bomb_stock)
        end

        vars.boss.sc_bonus = 0

        if vars.player.power then
            vars.player.power = math.max(vars.player.power - config.power_loss_on_death, config.min_power)
        end

        M.DeathWeapon.new()
        M.DeathEff.new(self.x, self.y)
        M.DeathEff.new(self.x, self.y, true)
    elseif self.death > 75 then -- player death effect (grow and fade out)
        self._a = self._a - 255 / 15
        self.hscale = self.hscale + 1 / 15
        self.vscale = self.vscale + 1 / 15
    elseif self.death == 75 then -- hide player and reset scale/alpha
        self.hide = true
        self.hscale = 1
        self.vscale = 1
        self._a = 255
    elseif self.death > 50 then -- do nothing for these frames
    elseif self.death == 50 then -- move player and unhide
        self.x = 0
        self.y = Canvas.field.b - 12
        self.hide = false
        Bullet.BulletDeleter.new(self.x, self.y)
    else -- move player back to starting position
        self.y = -176 + (Canvas.field.b + 164) * (self.death - 1) / 50
    end

    -- update vars --

    self.slow_transition = math.clamp(self.slow_transition + slowmod, 0, 1)
    self.protect = math.max(self.protect - 1, 0)
    self.death = math.max(self.death - 1, 0)
    self.nextshoot = math.max(self.nextshoot - 1, 0)
    self.nextbomb = math.max(self.nextbomb - 1, 0)
    self.nextspecial = math.max(self.nextspecial - 1, 0)
    self.optx = self.x + (self.optx - self.x) * 0.69
    self.opty = self.y + (self.opty - self.y) * 0.69
    for act, val in pairs(self.nextaction) do
        self.nextaction[act] = math.max(val - 1, 0)
    end

    -- actions handling --

    if (not lstg.IsValid(instances.dialogue)) and (self.death > 90 or self.death <= 0) then
        if self.input_state.shoot and self.nextshoot <= 0 then
            self.nextshoot = c.shoot_time
            if c.shoot then c.shoot(self) end
        end
        if self.input_state.bomb and self.nextbomb <= 0 and vars.player.bomb > 0 then
            vars.player.bomb = vars.player.bomb - 1
            self.death = 0
            self.nextbomb = c.bomb_time
            self.protect = c.bomb_time + 40
            if c.bomb then c.bomb(self) end
        end
        if self.input_state.special and self.nextspecial <= 0 then
            self.nextspecial = c.special_time
            if c.special then c.special(self) end
        end

        if c.actions then
            for act, fn in pairs(c.actions) do
                if self.input_state[act] and self.nextaction[act] <= 0 then
                    fn(self)
                end
            end
        end
    end

    if self.wisys then self.wisys:frame(dx) end

    self.a = c.hitbox
    self.b = c.hitbox

    if c.frame then c.frame(self) end
end

---@param self game.player.Player.obj
function M.Player:render()
    if self.wisys then self.wisys:render() end

    if self.chardef.render then self.chardef.render(self) end
end

---@param self game.player.Player.obj
---@param other game.Enemy | game.Bullet
function M.Player:colli(other)
    if other.no_collide_player then return end

    if self.death == 0 and not lstg.IsValid(instances.dialogue) then
        if self.protect == 0 then
            lstg.PlaySound('pldead00', 0.5, self.x / 360)
            self.death = 90 + self.chardef.deathbomb
        end
        if other.group == GROUP.ENEMY_BULLET and not other.indes then
            lstg.Del(other)
        end
    end

    if self.chardef.colli then self.chardef.colli(self) end
end

--#endregion
--------------------------------------------------------------------------------
-- player bullet classes
--#region

---@class game.player.BulletStraight: foundation.object.class
M.BulletStraight = ObjLib.createClass()
M.BulletStraight.render_group = RDR_GROUP.FIELD

---@param img string
---@param x number
---@param y number
---@param v number
---@param angle number
---@param dmg number
---@param break_eff fun(self: game.player.BulletStraight.obj)?
---@return game.player.BulletStraight.obj
function M.BulletStraight.new(img, x, y, v, angle, dmg, break_eff)
    ---@class game.player.BulletStraight.obj: game.player.Weapon
    local self = ObjLib.newInst(M.BulletStraight)

    self.group = GROUP.PLAYER_BULLET
    self.layer = LAYER.PLAYER_BULLET
    self.img = img
    self.x = x
    self.y = y

    lstg.SetV(self, v, angle, true)

    self.dmg = dmg
    self.break_eff = break_eff

    return self
end

---@param self game.player.BulletStraight.obj
function M.BulletStraight:kill()
    if self.break_eff then self:break_eff() end
end

---@class game.player.BulletHoming: foundation.object.class
M.BulletHoming = ObjLib.createClass()
M.BulletHoming.render_group = RDR_GROUP.FIELD

---@param img string
---@param x number
---@param y number
---@param v number
---@param angle number
---@param dmg number
---@param trail number
---@param break_eff fun(self: game.player.BulletHoming.obj)?
---@return game.player.BulletHoming.obj
function M.BulletHoming.new(img, x, y, v, angle, dmg, trail, break_eff)
    ---@class game.player.BulletHoming.obj: game.player.Weapon
    local self = ObjLib.newInst(M.BulletHoming)

    self.group = GROUP.PLAYER_BULLET
    self.layer = LAYER.PLAYER_BULLET
    self.img = img
    self.x = x
    self.y = y
    self.v = v

    lstg.SetV(self, v, angle, true)

    self.dmg = dmg
    self.trail = trail
    self.break_eff = break_eff

    return self
end

---@param self game.player.BulletHoming.obj
function M.BulletHoming:frame()
    local target = M.findTarget(self)
    if not (lstg.IsValid(target) and target and target.colli) then return end
    local a = math.fmod(lstg.Angle(self, target) - self.rot + 720, 360)
    if a > 180 then a = a - 360 end
    local da = self.trail / (lstg.Dist(self, target) + 1)
    if da >= math.abs(a) then
        lstg.SetV(self, self.v, lstg.Angle(self, target), true)
    else
        lstg.SetV(self, self.v, self.rot + math.sign(a) * da, true)
    end
end

---@param self game.player.BulletHoming.obj
function M.BulletHoming:kill()
    if self.break_eff then self:break_eff() end
end

---@class game.player.BulletBreak: foundation.object.class
M.BulletBreak = ObjLib.createClass()
M.BulletBreak.render_group = RDR_GROUP.FIELD

---@param img string
---@param x number
---@param y number
---@param t integer
---@param dmg number?
---@return game.player.BulletBreak.obj
function M.BulletBreak.new(img, x, y, t, dmg)
    ---@class game.player.BulletBreak.obj: game.Object
    local self = ObjLib.newInst(M.BulletBreak)

    self.layer = LAYER.PLAYER_BULLET + 50
    self.img = img
    self.x = x
    self.y = y
    self.t = t

    if dmg then
        self.group = GROUP.PLAYER_BULLET
        self.no_kill_on_collide = true
    else
        self.group = GROUP.GHOST
    end
    self.dmg = dmg or 0

    return self
end

---@param self game.player.BulletBreak.obj
function M.BulletBreak:frame()
    if self.timer >= self.t then
        lstg.Del(self)
    end
end

--- Returns a function that spawns a bullet break effect object.
--- This function is safe to use as a class's kill/del method.
---@param img string
---@param t integer
---@param dmg number?
---@return fun(self: game.player.Weapon)
function M.createBulletBreakEff(img, t, dmg)
    return function(self)
        local bb = M.BulletBreak.new(img, self.x, self.y, t, dmg)

        bb.vx = self.vx * 0.4
        bb.vy = self.vy * 0.4
        bb.ax = -bb.vx / t
        bb.ay = -bb.vy / t
        bb.rot = self.rot
    end
end

--#endregion
--------------------------------------------------------------------------------
-- player options handling
--#region

--- Shot options/support/orbitals
---@class game.player.Option: foundation.object.class
M.Option = ObjLib.createClass(true)
M.Option.render_group = RDR_GROUP.FIELD

---@param player game.player.Player.obj
---@param img string
---@param relx number
---@param rely number
---@param focus_relx number?
---@param focus_rely number?
---@param shotangle number?
---@param omiga number?
---@return game.player.Option.obj
function M.Option.new(player, img, relx, rely, focus_relx, focus_rely, shotangle, omiga)
    ---@class game.player.Option.obj: game.RenderObject
    local self = ObjLib.newInst(M.Option)

    self.group = GROUP.GHOST
    self.layer = LAYER.PLAYER
    self.x = player.x + relx
    self.y = player.y + rely
    self.img = img
    self.bound = false

    self.relx = relx
    self.rely = rely
    self.focus_relx = focus_relx or relx
    self.focus_rely = focus_rely or rely
    self.shotangle = shotangle or 90
    self.omiga = omiga or 0

    self.player = player

    return self
end

---@param self game.player.Option.obj
function M.Option:frame()
    local p = self.player

    self.x = p.optx + math.lerp_acc_dec(p.slow_transition, self.relx, self.focus_relx)
    self.y = p.opty + math.lerp_acc_dec(p.slow_transition, self.rely, self.focus_rely)
end

---@param self game.player.Option.obj
---@param img string
---@param v number
---@param dmg number
---@param angle number?
---@return game.player.BulletStraight.obj
function M.Option:shootStraight(img, v, dmg, angle)
    angle = angle or self.shotangle
    return M.BulletStraight.new(img, self.x, self.y, v, angle, dmg)
end

---@param self game.player.Option.obj
---@param img string
---@param v number
---@param dmg number
---@param trail number
---@param angle number?
---@return game.player.BulletHoming.obj
function M.Option:shootHoming(img, v, dmg, trail, angle)
    angle = angle or self.shotangle
    return M.BulletHoming.new(img, self.x, self.y, v, angle, dmg, trail)
end

--#endregion
--------------------------------------------------------------------------------
-- miscellaneous player-related objects
--#region

---@class game.player.Grazer: foundation.object.class
M.Grazer = ObjLib.createClass()
M.Grazer.render_group = RDR_GROUP.FIELD

---@param player game.player.Player.obj
---@return game.player.Grazer.obj
function M.Grazer.new(player)
    ---@class game.player.Grazer.obj: game.Object
    local self = ObjLib.newInst(M.Grazer)

    self.group = GROUP.PLAYER
    self.layer = LAYER.ENEMY_BULLET_EF + 50
    self.img = 'player:graze'
    self.a = player.chardef.grazebox
    self.b = player.chardef.grazebox

    self.player = player
    self.grazed = false
    self.lastslow = false
    self.wait = 0
    self.aura_rot = 0
    self.aura_offs = 0

    return self
end

---@param self game.player.Grazer.obj
function M.Grazer:frame()
    local p = self.player
    local slow = p.slow

    if p.death < 10 or p.death >= 90 then
        self.x = p.x
        self.y = p.y
        self.hide = p.hide
        if self.lastslow ~= slow then
            self.lastslow = slow
            self.wait = 30
        end
    end
    if self.wait <= 0 then
        self.aura_rot = self.aura_rot + 1.5
    end
    self.wait = math.max(self.wait - 1, 0)
    self.aura_offs = 180 * lstg.cos(3 * (30 - self.wait)) ^ 2

    if self.grazed then
        Sound.playSfxRandPitch('graze', 0.1, 0.3, self.x / 250)
        self.grazed = false
        lstg.ParticleFire(self)
    else
        lstg.ParticleStop(self)
    end
end

---@param self game.player.Grazer.obj
function M.Grazer:render()
    local p = self.player
    lstg.DefaultRenderFunc(self)
    lstg.SetImageState('player:aura', '', lstg.Color(0xBBFFFFFF))
    lstg.Render('player:aura', self.x, self.y, -self.aura_rot + self.aura_offs, p.slow_transition)
    lstg.SetImageState('player:aura', '', lstg.Color(200 * p.slow_transition, 255, 255, 255))
    lstg.Render('player:aura', self.x, self.y, self.aura_rot, 2 - p.slow_transition)
end


---@param self game.player.Grazer.obj
---@param other game.Bullet
function M.Grazer:colli(other)
    if
        self.player.protect > 0 or
        other.group == GROUP.ENEMY or
        (other.grazed and not other.infinite_graze)
    then return end
    vars.stage.graze = vars.stage.graze + 1
    self.grazed = true
    if not other.infinite_graze then
        other.grazed = true
    end
end


---@class game.player.DeathWeapon: foundation.object.class
M.DeathWeapon = ObjLib.createClass()
M.DeathWeapon.render_group = RDR_GROUP.FIELD

---@return game.player.DeathWeapon.obj
function M.DeathWeapon.new()
    ---@class game.player.DeathWeapon.obj: game.player.Weapon
    local self = ObjLib.newInst(M.DeathWeapon)

    -- self.x = x
    -- self.y = y
    self.group = GROUP.PLAYER_BULLET
    self.a = 420
    self.b = 420
    self.hide = true

    self.noscore = true
    self.dmg = 0.75
    self.no_kill_on_collide = true

    return self
end

---@param self game.player.DeathWeapon.obj
function M.DeathWeapon:frame()
    if self.timer >= 60 then
        lstg.Del(self)
    end
end


---@class game.player.DeathEff: foundation.object.class
M.DeathEff = ObjLib.createClass()
M.DeathEff.render_group = RDR_GROUP.FIELD

---@param x number
---@param y number
---@param second boolean?
---@return game.player.DeathEff.obj
function M.DeathEff.new(x, y, second)
    ---@class game.player.DeathEff.obj: game.Object
    local self = ObjLib.newInst(M.DeathEff)

    self.x = x
    self.y = y
    self.group = GROUP.GHOST
    self.layer = LAYER.TOP

    self.size = 0
    self.second = second

    Task.new(self, function()
        if second then Task.wait(30) end

        for i = 1, 180 do
            self.size = i
            Task.wait()
        end
    end)

    return self
end

---@param self game.player.DeathEff.obj
function M.DeathEff:frame()
    Task.doFrame(self)
    if self.timer > 180 then
        lstg.Del(self)
    end
end

---@param self game.player.DeathEff.obj
function M.DeathEff:render()
    Shapes.renderCircleA(self.x, self.y, self.size * 12, 40)
    if self.second then return end
    Shapes.renderCircleA(self.x + 35, self.y + 35, self.size * 8, 40)
    Shapes.renderCircleA(self.x + 35, self.y - 35, self.size * 8, 40)
    Shapes.renderCircleA(self.x - 35, self.y + 35, self.size * 8, 40)
    Shapes.renderCircleA(self.x - 35, self.y - 35, self.size * 8, 40)
end

--#endregion

return M