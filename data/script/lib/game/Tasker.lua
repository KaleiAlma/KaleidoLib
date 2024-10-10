local Object = require('lib.foundation.Object')
local Task = require('lib.foundation.Task')

---@class game.Tasker: foundation.object.class
local Tasker = Object.createClass()

---@param f function
function Tasker.new(f)
    ---@class game.Tasker.obj: lstg.GameObject
    ---@field task foundation.task.manager
    local self = Object.newInst(Tasker)
    self.group = GROUP.GHOST
    Task.new(self, f)
end

---@param self game.Tasker.obj
function Tasker:frame()
    Task.doFrame(self)
    if coroutine.status(self.task[1]) == 'dead' then
        lstg.Del(self)
    end
end

return Tasker