

---@class foundation.shapes
local M = {}

---@param x number
---@param y number
---@param r number
---@param p number
function M.renderCircleA(x, y, r, p)
    local a = 360 / p
    for i = 360 / p, 360, 360 / p do
        local x1 = x + r * lstg.cos(i)
        local y1 = y + r * lstg.sin(i)
        local x2 = x + r * lstg.cos(i + a)
        local y2 = y + r * lstg.sin(i + a)

        lstg.Render4V(
            'white',
            x, y, 0,
            x, y, 0,
            x1, y1, 0,
            x2, y2, 0
        )
    end
end

---@param x number
---@param y number
---@param r1 number
---@param r2 number
---@param p number
function M.renderCircleB(x, y, r1, r2, p)
    local a = 360 / p
    for i = 360 / p, 360, 360 / p do
        local x1 = x + r1 * lstg.cos(i)
        local y1 = y + r1 * lstg.sin(i)
        local x2 = x + r1 * lstg.cos(i + a)
        local y2 = y + r1 * lstg.sin(i + a)
        local x3 = x + r2 * lstg.cos(i + a)
        local y3 = y + r2 * lstg.sin(i + a)
        local x4 = x + r2 * lstg.cos(i)
        local y4 = y + r2 * lstg.sin(i)

        lstg.Render4V(
            'white',
            x1, y1, 0,
            x2, y2, 0,
            x3, y3, 0,
            x4, y4, 0
        )
    end
end

---@param x number
---@param y number
---@param r1 number
---@param r2 number
---@param p number
---@param rot number?
function M.renderStarA(x, y, r1, r2, p, rot)
    rot = rot or 0
    local a = 360 / p
    for i = 360 / p, 360, 360 / p do
        local i_ = i + rot
        local x1 = x + r1 * lstg.cos(i_)
        local y1 = y + r1 * lstg.sin(i_)
        local x2 = x + r2 * lstg.cos(i_ + a * 0.5)
        local y2 = y + r2 * lstg.sin(i_ + a * 0.5)
        local x3 = x + r2 * lstg.cos(i_ - a * 0.5)
        local y3 = y + r2 * lstg.sin(i_ - a * 0.5)

        lstg.Render4V(
            'white',
            x1, y1, 0,
            x2, y2, 0,
             x,  y, 0,
            x3, y3, 0
        )
    end
end

---@param x number
---@param y number
---@param r1 number
---@param r2 number
---@param w number
---@param p number
---@param rot number?
function M.renderStarB(x, y, r1, r2, w, p, rot)
    rot = rot or 0
    local a = 360 / p
    for i = 360 / p, 360, 360 / p do
        local i_ = i + rot
        local x1 = x + r1 * lstg.cos(i_)
        local y1 = y + r1 * lstg.sin(i_)
        local x2 = x + (r1 - w) * lstg.cos(i_)
        local y2 = y + (r1 - w) * lstg.sin(i_)
        local x3 = x + r2 * lstg.cos(i_ + a * 0.5)
        local y3 = y + r2 * lstg.sin(i_ + a * 0.5)
        local x4 = x + (r2 - w) * lstg.cos(i_ + a * 0.5)
        local y4 = y + (r2 - w) * lstg.sin(i_ + a * 0.5)
        local x5 = x + r2 * lstg.cos(i_ - a * 0.5)
        local y5 = y + r2 * lstg.sin(i_ - a * 0.5)
        local x6 = x + (r2 - w) * lstg.cos(i_ - a * 0.5)
        local y6 = y + (r2 - w) * lstg.sin(i_ - a * 0.5)

        lstg.Render4V(
            'white',
            x1, y1, 0,
            x3, y3, 0,
            x4, y4, 0,
            x2, y2, 0
        )

        lstg.Render4V(
            'white',
            x1, y1, 0,
            x5, y5, 0,
            x6, y6, 0,
            x2, y2, 0
        )
    end
end

return M