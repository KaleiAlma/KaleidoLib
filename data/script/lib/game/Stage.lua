local Task = require('lib.foundation.Task')

---@class game.stage
local M = {}

---@class game.stage.Stage
---@field init fun(self:game.stage.Stage.inst)
---@field del fun(self:game.stage.Stage.inst)
---@field frame fun(self:game.stage.Stage.inst)
---@field render fun(self:game.stage.Stage.inst)
local Stage = {}

---@type string
Stage.stage_name = "__default__"

local function empty_callback() end

---@param stage game.stage.Stage
---@return game.stage.Stage.inst
local function makeInstance(stage)
    ---@class game.stage.Stage.inst
    local ret = {
        init = stage.init or empty_callback,
        del = stage.del or empty_callback,
        frame = stage.frame or empty_callback,
        render = stage.render or empty_callback,
        timer = 0,
    }
    return ret
end

M.stages = {}

---@type game.stage.Stage.inst
M.current_stage = makeInstance(Stage)

---@type game.stage.Stage
M.next_stage = Stage

M.preserve_res = false

---@param stage_name string
---@return game.stage.Stage
---@overload fun(stage_name:string): game.stage.Stage
function M.new(stage_name)
    assert(type(stage_name) == "string")
    ---@type game.stage.Stage
    local result = {
        init = empty_callback,
        del = empty_callback,
        render = empty_callback,
        frame = empty_callback,
        stage_name = stage_name,
    }
    M.stages[stage_name] = result
    return result
end

---@param stage_name string
function M.set(stage_name)
    assert(type(stage_name) == "string")
    M.next_stage = M.stages[stage_name]
    assert(M.next_stage, "stage does not exist")
end

function M.nextStageExist()
    return (not (not M.next_stage))
end

function M.change()
    M.destroyCurrentStage()
    M.createNextStage()
end

function M.destroyCurrentStage()
    M.current_stage:del()
    lstg.ResetPool()
    if M.preserve_res then
        M.preserve_res = false
    else
        lstg.RemoveResource("stage")
    end
end

function M.createNextStage()
    local next_stage = M.next_stage
    M.next_stage = nil
    assert(next_stage, "next stage is nil")
    M.current_stage = makeInstance(next_stage)
    -- M.current_stage.timer = 0
    M.current_stage:init()
end

function M.update()
    Task.doFrame(M.current_stage)
    M.current_stage:frame()
    M.current_stage.timer = M.current_stage.timer + 1
end

M.stages[Stage.stage_name] = Stage
M.set(Stage.stage_name)
M.change()

return M