local ObjLib = require('lib.foundation.ObjLib')

---@class game.laser
local M = {}

local laser_mt = {
    __index = function(t, k)
        if k == 'length' then
            return rawget(t, '_length')
        elseif k == 'tip_len' then
            return rawget(t, '_tip_len')
        elseif k == 'end_len' then
            return rawget(t, '_end_len')
        end
        return lstg.GetAttr(t, k)
    end,
    __newindex = function(t, k, v)
        if k == 'x' then
            rawset(t, '_x', v)
            lstg.SetAttr(t, 'x', v + (t._length + (t._tip_len + t._end_len) * 0.8) * 0.5 * lstg.cos(t.rot))
        elseif k == 'y' then
            rawset(t, '_y', v)
            lstg.SetAttr(t, 'y', v + (t._length + (t._tip_len + t._end_len) * 0.8) * 0.5 * lstg.sin(t.rot))
        elseif k == 'rot' then
            lstg.SetAttr(t, 'rot', v)
            lstg.SetAttr(t, 'x', t._x + (t._length + (t._tip_len + t._end_len) * 0.8) * 0.5 * lstg.cos(v))
            lstg.SetAttr(t, 'y', t._y + (t._length + (t._tip_len + t._end_len) * 0.8) * 0.5 * lstg.sin(v))
        elseif k == 'length' then
            rawset(t, '_length', v)
            lstg.SetAttr(t, 'x', t._x + (v + (t._tip_len + t._end_len) * 0.8) * 0.5 * lstg.cos(t.rot))
            lstg.SetAttr(t, 'y', t._y + (v + (t._tip_len + t._end_len) * 0.8) * 0.5 * lstg.sin(t.rot))
            lstg.SetAttr(t, 'a', v + (t._tip_len + t._end_len) * 0.8)
        elseif k == 'tip_len' then
            rawset(t, '_tip_len', v)
            lstg.SetAttr(t, 'x', t._x + (t._length + (v + t._end_len) * 0.8) * 0.5 * lstg.cos(t.rot))
            lstg.SetAttr(t, 'y', t._y + (t._length + (v + t._end_len) * 0.8) * 0.5 * lstg.sin(t.rot))
            lstg.SetAttr(t, 'a', t._length + (v + t._end_len) * 0.8)
        elseif k == 'end_len' then
            rawset(t, '_end_len', v)
            lstg.SetAttr(t, 'x', t._x + (t._length + (t._tip_len + v) * 0.8) * 0.5 * lstg.cos(t.rot))
            lstg.SetAttr(t, 'y', t._y + (t._length + (t._tip_len + v) * 0.8) * 0.5 * lstg.sin(t.rot))
            lstg.SetAttr(t, 'a', t._length + (t._tip_len + v) * 0.8)
        else
            lstg.SetAttr(t, k, v)
        end
    end,
}

local function other_colli(self, o)
    o.class.colli(o, self)
end

---@param self game.laser.HitscanLaser.obj
function M.Render(self)
    
end

---@class game.laser.HitscanLaser: foundation.object.class
M.HitscanLaser = ObjLib.createClass()
M.HitscanLaser.render_group = RDR_GROUP.FIELD

---@param group integer
---@param layer number
---@param x number
---@param y number
---@param angle number
---@param width number
---@param length number?
---@param img1 string?
---@param img2 string?
---@param img3 string?
---@param tip_len number?
---@param end_len number?
---@param head_size number?
---@param node_size number?
---@return game.laser.HitscanLaser.obj
function M.HitscanLaser.new(group, layer, x, y, angle, width, length, img1, img2, img3, tip_len, end_len, head_size, node_size)
    ---@class game.laser.HitscanLaser.obj: game.Object
    ---@field length number
    ---@field tip_len number
    ---@field end_len number
    local self = ObjLib.newInst(M.HitscanLaser)

    length = length or 600
    tip_len = tip_len or 0
    end_len = end_len or 0

    self.group = GROUP.GHOST
    self.layer = layer
    self.bound = false
    self.x = (length + (tip_len + end_len) * 0.8) * 0.5 * lstg.cos(angle) + x
    self.y = (length + (tip_len + end_len) * 0.8) * 0.5 * lstg.sin(angle) + y
    self.rot = angle
    self.a = length + (tip_len + end_len) * 0.8
    self.b = width * 0.5

    self._a = 255

    self.no_kill_on_collide = true

    self.img1 = img1
    self.img2 = img2
    self.img3 = img3
    self.head_size = head_size or 0
    self.node_size = node_size or 0
    self._x = x
    self._y = y
    self.max_length = length
    self._length = length
    self._tip_len = tip_len
    self._end_len = end_len
    self.width = width
    self.active = true
    if group == GROUP.PLAYER_BULLET then
        self.checkgroups = {GROUP.ENEMY}
        self.groupfuncs = {other_colli}
    elseif group == GROUP.ENEMY_BULLET then
        self.checkgroups = {GROUP.PLAYER}
        self.groupfuncs = {other_colli}
    elseif group == GROUP.SPELL then
        self.checkgroups = {GROUP.ENEMY_BULLET, GROUP.ENEMY}
        self.groupfuncs = {
            function(_, o)
                if not o.indes then
                    lstg.Kill(o)
                end
            end,
            other_colli
        }
    end

    setmetatable(self, laser_mt)

    return self
end

---@param self game.laser.HitscanLaser.obj
function M.HitscanLaser:frame()
    self.length = self.max_length

    if not self.checkgroups or not self.active then return end

    local target
    local dist = self.max_length
    local grpidx

    for i, grp in ipairs(self.checkgroups) do
        for _, o in lstg.ObjList(grp) do
            local curr_dist = lstg.Dist(self._x, self._y, o)
            if lstg.ColliCheck(self, o) and dist > curr_dist then
                dist = curr_dist
                target = o
                grpidx = i
            end
        end
    end

    if not lstg.IsValid(target) then
        return
    end
    self.length = math.max(0, dist - target.b)
    self.groupfuncs[grpidx](self, target)
end

return M