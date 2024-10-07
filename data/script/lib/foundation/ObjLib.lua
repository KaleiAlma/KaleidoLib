local config = require('lib._config').object

---@class foundation.object
local M = {}

--[[
-- type checking for generic class is currently unimplemented by lua language
-- server. however, there is no real better way to get the type checking i'd
-- like, so this part will remain commented until proper support is added to luacats

---@class foundation.object.class<O>: lstg.Class
---@field init   fun(self:O, ...)
---@field del    fun(self:O)
---@field frame  fun(self:O)
---@field render fun(self:O)
---@field colli  fun(self:O, other:lstg.GameObject)
---@field kill   fun(self:O)
---
---@field render_group foundation.canvas.render_group
]]

---@class foundation.object.class: lstg.Class
---@field init   fun(self:lstg.GameObject, ...)
---@field del    fun(self:lstg.GameObject)
---@field frame  fun(self:lstg.GameObject)
---@field render fun(self:lstg.GameObject)
---@field colli  fun(self:lstg.GameObject, other:lstg.GameObject)
---@field kill   fun(self:lstg.GameObject)
---
---@field render_group foundation.canvas.render_group

---@type table<foundation.object.class, boolean>
local all_class = {}
setmetatable(all_class, {
    __mode = "k",
})

-- For optimization purposes
local function empty_callback()
end

local DEFAULT_MASK_INIT = 2
local DEFAULT_MASK_DEL = 4
local DEFAULT_MASK_FRAME = 8
local DEFAULT_MASK_RENDER = 16
local DEFAULT_MASK_COLLI = 32
local DEFAULT_MASK_KILL = 64

--- Checks whether the specified (unregistered) class has any default callbacks.
---@param c foundation.object.class
local function hasDefaultCallback(c)
    ---@diagnostic disable-next-line: undefined-field
    return c.init == empty_callback or c.del == empty_callback or c.frame == empty_callback or c.render == lstg.DefaultRenderFunc or c.colli == empty_callback or c.kill == empty_callback
end

--- Creates an empty game object class.
---@param render boolean?
---@return foundation.object.class
function M.createClass(render)
    local c = {
        empty_callback, -- init
        empty_callback, -- del
        empty_callback, -- frame
        lstg.DefaultRenderFunc, -- render
        empty_callback, -- colli
        empty_callback; -- kill
        is_class = true,
        ['.render'] = render,
    }
    c.init = empty_callback
    c.del = empty_callback
    c.frame = empty_callback
    c.render = lstg.DefaultRenderFunc
    c.colli = empty_callback
    c.kill = empty_callback

    c.render_group = 0 -- UNKNOWN

    all_class[c] = false
    return c
end

--- Registers a game object class.
---@param c foundation.object.class
function M.registerClass(c)
    -- sanity check
    assert(type(c) == "table")
    assert(c.is_class)
    local init_t = type(c.init)
    local del_t = type(c.del)
    local frame_t = type(c.frame)
    local render_t = type(c.render)
    local colli_t = type(c.colli)
    local kill_t = type(c.kill)
    assert(init_t == "function" or init_t == "nil")
    assert(del_t == "function" or del_t == "nil")
    assert(frame_t == "function" or frame_t == "nil")
    assert(render_t == "function" or render_t == "nil")
    assert(colli_t == "function" or colli_t == "nil")
    assert(kill_t == "function" or kill_t == "nil")
    -- register callbacks
    c[1] = c.init
    c[2] = c.del
    c[3] = c.frame
    c[4] = c.render
    c[5] = c.colli
    c[6] = c.kill
    -- performance optimization
    if hasDefaultCallback(c) then
        c.default_function = 0
        if c.init == empty_callback then
            c.default_function = c.default_function + DEFAULT_MASK_INIT
        end
        if c.del == empty_callback then
            c.default_function = c.default_function + DEFAULT_MASK_DEL
        end
        if c.frame == empty_callback then
            c.default_function = c.default_function + DEFAULT_MASK_FRAME
        end
        if c.render == lstg.DefaultRenderFunc then
            c.default_function = c.default_function + DEFAULT_MASK_RENDER
        end
        if c.colli == empty_callback then
            c.default_function = c.default_function + DEFAULT_MASK_COLLI
        end
        if c.kill == empty_callback then
            c.default_function = c.default_function + DEFAULT_MASK_KILL
        end
    end
    -- sets this class's entry to `true` so it doesn't have to be re-registered
    all_class[c] = true
end

--- Registers all game object classes.
function M.registerAllClass()
    for k, v in pairs(all_class) do
        if not v then
            M.registerClass(k)
        end
    end
end

local lstg_new = lstg.New

--- Creates a new object. Please use this instead of lstg.New().
---@see _config for an option to alias lstg.New() to this method.
---@param c foundation.object.class
---@param ... any
---@return lstg.GameObject
function M.newInst(c, ...)
    local o = lstg_new(c, ...)
    o.world = bit.bor(c.render_group, o.world)
    return o
end

if config.alias_lstg_new then
    lstg.OldNew = lstg.New
    lstg.New = M.newInst
end

return M