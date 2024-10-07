---@class _config KaleidoLib Configuration
local M = {}

local KEY = lstg.Input.Keyboard

--------------------------------------------------------------------------------
-- foundation
--#region

---@type _config.key_input key_input.lua
M.key_input = {}
do
    ---@class _config.key_input
    local C = M.key_input
    C.default_keys = {
        shoot = KEY.Z,
        bomb = KEY.X,
        special = KEY.C,
        slow = KEY.LeftShift,
        --
        up = KEY.Up,
        down = KEY.Down,
        left = KEY.Left,
        right = KEY.Right,
        --
        pause = KEY.Escape,
        system = KEY.LeftControl,
    }
end

---@type _config.screen screen.lua
M.screen = {}
do
    ---@class _config.screen
    local C = M.screen
    C.default_setting = {
        width = 1600,
        height = 900,
        vsync = false,
        monitor = 0,
        mode = 1, -- mode.WINDOWED; see screen.lua
    }
end

---@type _config.canvas canvas.lua
M.canvas = {}
do
    ---@class _config.canvas
    local C = M.canvas
    C.width = 1600
    C.height = 900
    C.field = {
        l = -224, r = 224, b = -224, t = 224,
        bound = {
            l = -256, r = 256, b = -256, t = 256,
        },
        player_bound = {
            l = -216, r = 216, b = -208, t = 192,
        },
        screen = {
            l = 380, r = 1220, b = 50, t = 890,
        },
    }
    C.alias_lstg_boundcheck = false
end

---@type _config.object object.lua
M.object = {}
do
    ---@class _config.object
    local C = M.object
    C.alias_lstg_new = false
end

---@type _config.setting setting.lua
M.setting = {}
do
    ---@class _config.setting
    local C = M.setting
    C.settings_file_location = 'userdata/setting.json'
end

--#endregion
--------------------------------------------------------------------------------
-- game
--#region

---@type _config.hud hud.lua
M.hud = {}
do
    ---@class _config.hud
    local C = M.hud
    ---@type "'new'"|"'th'"
    C.type = 'new'
    C.setting = {
        new = {},
        th = {},
    }
end

---@type _config.vars vars.lua
M.vars = {}
do
    ---@class _config.vars
    local C = M.vars
    C.enable_power = false
end

---@type _config.player player.lua
M.player = {}
do
    ---@class _config.player
    local C = M.player
    --- Extra key actions
    C.actions = {}

    C.power_loss_on_death = 50
    C.min_power = 100

    C.lose_bombs_on_death = true
    C.character_bomb_stock = false
    C.bomb_stock = 3
end

--#endregion

return M