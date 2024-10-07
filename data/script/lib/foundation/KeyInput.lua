--- KaleidoLib Keyboard Input module
---@class foundation.key_input
local M = {}
local Setting = require('lib.foundation.Setting')
local config = require('lib._config').key_input

local KEY = lstg.Input.Keyboard

local default_keys = config.default_keys

local keyState = {}
local keyStatePrev = {}

function M.getInput()
    local keys = Setting.get().key or default_keys

    for k, v in pairs(keys) do
        keyStatePrev[k] = keyState[k]
        keyState[k] = KEY.GetKeyState(v)
    end
end

---@param key string
---@return boolean
function M.keyDown(key)
    return keyState[key]
end

---@param key string
---@return boolean
function M.keyPressed(key)
    return keyState[key] and (not keyStatePrev[key])
end

---@param key string
---@return boolean
function M.keyUp(key)
    return keyStatePrev[key] and (not keyState[key])
end

---@type table<integer, string>
M.keynames = {}

for k, v in pairs(KEY) do
    if type(v) == "number" then
        M.keynames[v] = k
    end
end
-- key placeholder names
for i = 0, 255 do
    M.keynames[i] = M.keynames[i] or string.format("Key 0x%X", i)
end

return M
