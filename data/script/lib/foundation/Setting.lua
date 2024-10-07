--- KaleidoLib Settings module
---@class foundation.setting
local M = {}
local _config = require('lib._config')
local config = _config.setting
local JsonUtil = require('lib.foundation.JsonUtil')

---@class foundation.setting.settings
M.default = {
    key = _config.key_input.default_keys,
    screen = _config.screen.default_setting,
}

local function safe_encode_json(t)
    local r, e = pcall(cjson.encode, t)
    if r then
        return e
    else
        lstg.Log(4, "failed to encode settings to json: " .. tostring(e))
        return cjson.encode(M.default)
    end
end

local function safe_decode_json(s)
    local r, e = pcall(cjson.decode, s)
    if r then
        return e
    else
        lstg.Log(4, "failed to decode settings from json: " .. tostring(e))
        return cjson.decode(cjson.encode(s)) -- copy
    end
end

---@type foundation.setting.settings
local setting = safe_decode_json(safe_encode_json(M.default))
-- M.setting = {}

function M.load()
    local f, msg = io.open(config.settings_file_location, 'r')
    if f == nil then
        setting = safe_decode_json(safe_encode_json(M.default))
    else
        setting = safe_decode_json(f:read('*a'))
        f:close()
    end
end

function M.save()
    local f, msg = io.open(config.settings_file_location, 'w')
    if f == nil then
        error(msg)
    else
        f:write(JsonUtil.format_json(safe_encode_json(setting)))
        f:close()
    end
end

--- Returns the settings table. You may set values in the returned table.
---@return foundation.setting.settings
function M.get()
    return setting
end

-- local function newindex(self, k, v)
--     local mt = getmetatable(self)
--     local t = M
--     for _, key in ipairs(mt.__ref) do
--         t = t[key]
--     end
--     -- t = t[k]

--     t[k] = v
-- end

-- local function newindex_deny()
--     lstg.Log(3, 'writing to default settings is disallowed!')
-- end

-- local function index_for_default(self, k)
--     local mt = getmetatable(self)
--     local v = M
--     for _, key in ipairs(mt.__ref) do
--         v = v[key]
--     end
--     v = v[k]
--     if type(v) == "table" then
--         return setmetatable({}, {
--             __ref = { unpack(mt.__ref), k },
--             __index = index_for_default,
--             __newindex = newindex_deny,
--         })
--     end
--     return v
-- end

-- local function index(self, k)
--     local mt = getmetatable(self)
--     local v = M
--     for _, key in ipairs(mt.__ref) do
--         v = v[key]
--     end
--     v = v[k]
--     if type(v) == "table" then
--         return setmetatable({}, {
--             __ref = { unpack(mt.__ref), k },
--             __index = index,
--             __newindex = newindex,
--         })
--     end
--     return v
-- end

-- return setmetatable({}, {
--     __ref = { 'setting' },
--     __index = function(self, k)
--         if k == 'default' then
--             local v = M.default[k]
--             if type(v) == "table" then
--                 return setmetatable({}, {
--                     __ref = { 'default' },
--                     __index = index_for_default,
--                     __newindex = newindex_deny,
--                 })
--             end
--             return v
--         elseif k ~= 'setting' and M[k] then
--             return M[k]
--         else
--             return index(self, k)
--         end
--     end,
--     __newindex = newindex
-- }) --[[@as foundation.setting]]

return M