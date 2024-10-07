--- KaleidoLib Screen module
---@class foundation.screen
local M = {}
local config = require('lib._config').screen
local Setting = require('lib.foundation.Setting')

M.modes = {
    WINDOWED = 1,
    FS_BORDERLESS = 2,
    FS_EXCLUSIVE = 3,
}
local mode = M.modes

-- debug
-- function lstg.VideoModeWindowed(width, height, vsync)
--     lstg.ChangeVideoMode(width, height, true, vsync)
-- end
-- function lstg.VideoModeFSBorderless(width, height, vsync)
--     lstg.ChangeVideoMode(width, height, false, vsync)
-- end
-- lstg.VideoModeFSExclusive = lstg.VideoModeFSBorderless

---@type fun(width:integer, height:integer, vsync:integer, monitor:integer)[]
local func_for_mode = {
    lstg.VideoModeWindowed,
    lstg.VideoModeFSBorderless,
    lstg.VideoModeFSExclusive,
}

-- local s = config.default_setting -- or setting.screen
-- local s = setting.screen or config.default_setting
-- M.settings = s

function M.updateVideoMode()
    local s = Setting.get().screen or config.default_setting
    func_for_mode[s.mode](s.width, s.height, s.vsync, s.monitor)
end

return M