local instances = require('lib.game.instances')
local rand = require('lib.game.rand')

---@class game.move
local M = {}

--- Sets acceleration for a single object.
---@param self lstg.GameObject
---@param accel number
---@param ang number
---@param aim boolean?
---@param navi boolean?
---@param maxv number?
---@return lstg.GameObject
function M.setA(self, accel, ang, aim, navi, maxv)
    if aim and lstg.IsValid(instances.player) then
        ang = ang + lstg.Angle(self, instances.player)
    end
    self.ax = accel * lstg.cos(ang)
    self.ay = accel * lstg.sin(ang)
    self.navi = not not navi
    if maxv ~= nil then
        self.maxv = maxv
    end
    return self
end

lstg.SetA = M.setA

---@enum game.move.lerp_mode
M.LERP_MODE = {
    LINEAR = 0,
    ACCEL = 1,
    DECEL = 2,
    ACC_DEC = 3,
}

---@enum game.move.dir_mode
M.DIR_MODE = {
    TOWARDS_PLAYER_XY = 0,
    TOWARDS_PLAYER_X = 1,
    TOWARDS_PLAYER_Y = 2,
    RANDOM = 3,
}

--- Moves the provided object to the specified position
--- in the given amount of frames.  
--- Please use within a task.
---@param self lstg.GameObject
---@param x number
---@param y number
---@param time integer
---@param lerp_mode game.move.lerp_mode
function M.to(self, x, y, time, lerp_mode)
    time = math.max(1, math.floor(time))
    local dx = x - self.x
    local dy = y - self.y
    local orig_x = self.x
    local orig_y = self.y
    if lerp_mode == M.LERP_MODE.ACCEL then
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            local s = i * i
            self.x = orig_x + s * dx
            self.y = orig_y + s * dy
            coroutine.yield()
        end
    elseif lerp_mode == M.LERP_MODE.DECEL then
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            local s = i * 2 - i * i
            self.x = orig_x + s * dx
            self.y = orig_y + s * dy
            coroutine.yield()
        end
    elseif lerp_mode == M.LERP_MODE.ACC_DEC then
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            local s
            if i < 0.5 then
                s = i * i * 2
            else
                s = i * 4 - i * i * 2 - 1
            end
            self.x = orig_x + s * dx
            self.y = orig_y + s * dy
            coroutine.yield()
        end
    else
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            self.x = orig_x + i * dx
            self.y = orig_y + i * dy
            coroutine.yield()
        end
    end
end

--- Moves the provided object by the specified amount of units
--- in the given amount of frames.  
--- Please use within a task.
---@param self lstg.GameObject
---@param x number
---@param y number
---@param time integer
---@param lerp_mode game.move.lerp_mode
function M.by(self, x, y, time, lerp_mode)
    time = math.max(1, math.floor(time))
    local dx = x
    local dy = y
    local orig_x = self.x
    local orig_y = self.y
    if lerp_mode == M.LERP_MODE.ACCEL then
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            local s = i * i
            self.x = orig_x + s * dx
            self.y = orig_y + s * dy
            coroutine.yield()
        end
    elseif lerp_mode == M.LERP_MODE.DECEL then
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            local s = i * 2 - i * i
            self.x = orig_x + s * dx
            self.y = orig_y + s * dy
            coroutine.yield()
        end
    elseif lerp_mode == M.LERP_MODE.ACC_DEC then
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            local s
            if i < 0.5 then
                s = i * i
            else
                s = i * 4 - i * i * 2 - 1
            end
            self.x = orig_x + s * dx
            self.y = orig_y + s * dy
            coroutine.yield()
        end
    else
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            self.x = orig_x + i * dx
            self.y = orig_y + i * dy
            coroutine.yield()
        end
    end
end

--- Moves the provided object randomly in a given area.  
--- Please use within a task.
---@param self lstg.GameObject
---@param time integer
---@param l number left x coordinate
---@param r number right x coordinate
---@param b number bottom y coordinate
---@param t number top y coordinate
---@param dxmin number minimum x movement
---@param dxmax number maximum x movement
---@param dymin number minimum y movement
---@param dymax number maximum y movement
---@param lerp_mode game.move.lerp_mode
---@param dir_mode game.move.dir_mode
function M.wander(self, time, l, r, b, t, dxmin, dxmax, dymin, dymax, lerp_mode, dir_mode)
    local dirx = rand:sign()
    local diry = rand:sign()
    local p = instances.player
    local DMODE = M.DIR_MODE
    if p and lstg.IsValid(p) then
        if dir_mode == DMODE.TOWARDS_PLAYER_XY or dir_mode == DMODE.TOWARDS_PLAYER_X then
            if self.x > p.x then dirx = -1 else dirx = 1 end
        end
        if dir_mode == DMODE.TOWARDS_PLAYER_XY or dir_mode == DMODE.TOWARDS_PLAYER_Y then
            if self.y > p.y then diry = -1 else diry = 1 end
        end
    end
    local dx = rand:number(dxmin, dxmax)
    local dy = rand:number(dymin, dymax)
    if self.x + dx * dirx < l then
        dirx = 1
    end
    if self.x + dx * dirx > r then
        dirx = -1
    end
    if self.y + dy * diry < b then
        diry = 1
    end
    if self.y + dy * diry > t then
        diry = -1
    end
    M.by(self, dx * dirx, dy * diry, time, lerp_mode)
end

--- Moves the provided object along the specified bezier curve
--- in the given amount of frames.  
--- Please use within a task.
---@param self lstg.GameObject
---@param time integer
---@param lerp_mode game.move.lerp_mode
---@param ... number
function M.toBezier(self, time, lerp_mode, ...)
    time = math.max(1, math.floor(time))
    local count = select("#", ...) / 2
    local x = {}
    local y = {}
    x[1] = self.x
    y[1] = self.y
    for i = 1, count do
        x[i + 1] = select(i * 2 - 1, ...)
        y[i + 1] = select(i * 2, ...)
    end
    local com_num = {}
    for i = 0, count do
        com_num[i + 1] = math.combin(i, count)
    end

    if lerp_mode == M.LERP_MODE.ACCEL then
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            local s = i * i
            local _x = 0
            local _y = 0
            for j = 0, count do
                _x = _x + x[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
                _y = _y + y[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
            end
            self.x = _x
            self.y = _y
            coroutine.yield()
        end
    elseif lerp_mode == M.LERP_MODE.DECEL then
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            local s = i * 2 - i * i
            local _x = 0
            local _y = 0
            for j = 0, count do
                _x = _x + x[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
                _y = _y + y[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
            end
            self.x = _x
            self.y = _y
            coroutine.yield()
        end
    elseif lerp_mode == M.LERP_MODE.ACC_DEC then
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            local s
            if i < 0.5 then
                s = i * i * 2
            else
                s = i * 4 - i * i * 2 - 1
            end
            local _x = 0
            local _y = 0
            for j = 0, count do
                _x = _x + x[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
                _y = _y + y[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
            end
            self.x = _x
            self.y = _y
            coroutine.yield()
        end
    else
        for i = 1 / time, 1 + 0.5 / time, 1 / time do
            local _x = 0
            local _y = 0
            for j = 0, count do
                _x = _x + x[j + 1] * com_num[j + 1] * (1 - i) ^ (count - j) * i ^ j
                _y = _y + y[j + 1] * com_num[j + 1] * (1 - i) ^ (count - j) * i ^ j
            end
            self.x = _x
            self.y = _y
            coroutine.yield()
        end
    end
end

return M