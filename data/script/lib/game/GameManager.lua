local EventDispatcher = require "lib.foundation.EventDispatcher"
local SerializedTable = require "lib.foundation.SerializedTable"
local M = {}

M.sysevents = {} -- those are not cleared!!

function M.init()

    M.events = {}

    M.events.onFrame = EventDispatcher.new()
    M.events.onRender = EventDispatcher.new()
    M.events.onInit = EventDispatcher.new()

    M.instances = {}

    M.vars = SerializedTable.new(false, false)

end

M.init()

return M