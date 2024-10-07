
---@class foundation.plugin
local M = {}

M.loaded = {}

function M.require(name)
    if M.loaded[name] then
        return M.loaded[name]
    end
    lstg.FileManager.AddSearchPath('data/script/plugins/' .. name .. '/')
    M.loaded[name] = lstg.DoFile('init.lua')
    lstg.FileManager.RemoveSearchPath('data/script/plugins/' .. name .. '/')
    if not M.loaded[name] then
        M.loaded[name] = true
    end
    return M.loaded[name]
end

return M