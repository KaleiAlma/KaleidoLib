---@class boss.Card
local M = {}
local SequenceSystem = require('lib.foundation.SequenceSystem')
local Task = require "lib.foundation.Task"
local passthrough = function() end

M.exit_codes = {
    NOT_FINISHED = 0,
    KILLED = 1,
    TIMED_OUT = 2
}

-- for the coroutine function in the sequence:
-- function (sequence_system,boss, card_context)
-- this is how the parameters are passed
-- boss is a TABLE of bosses
-- card_context is where you'll store any variables pertaining to the current spell
--  example: time passed

---@return boss.Card
---this is for creating a naked card
function M.new(cofunc, out, init, update)
    local self = {}
    self.sequence = SequenceSystem.Sequence.new(cofunc, out, init, update)
    return self
end

function M.newPattern(name,time,hp,is_survival)
    local self = {}
    self.name = name
    self.time = time
    self.hp = hp
    self.is_survival = is_survival
    ---@type fun(seqsys?:foundation.SequenceSystem, boss?:game.boss, context?:table)
    self.before = passthrough
    ---@type fun(seqsys?:foundation.SequenceSystem, boss?:game.boss, context?:table)
    self.init = passthrough
    ---@type fun(seqsys?:foundation.SequenceSystem, boss?:game.boss, context?:table)
    self.frame = passthrough
    ---@type fun(self:boss.Card,seqsys?:foundation.SequenceSystem, boss?:game.boss[], context?:table)
    self.kill = passthrough
    function self:exit_condition (seqsys,boss,context) --redefine this if you need
        if context.timer >= context.time*60 then
            return M.exit_codes.TIMED_OUT
        end
        for k, obj in ipairs(boss) do
            if obj.hp <= 0 and not self.is_survival then
                context.boss_killed = k
                return M.exit_codes.KILLED --return non 0 to end the spell 
            end
        end
        return M.exit_codes.NOT_FINISHED
    end
    --context is for storing variables such as how much time is left and has passed
    --storing what happened for the spell to end
    --as well as storing the next spell (if its null, its going to the next one as normal, but if it's not, it's going to replace the next card with this one)
    self.sequence = SequenceSystem.Sequence.new(function (seqsys,boss,context)
        for k, obj in ipairs(boss) do
            obj.timer = 0
            Task.clear(obj)
            boss:setBaseHP(self.hp)
        end
        context.time = self.time --copying time value so it can be changed
        context.timer = 0 --this is how much time has passed
        self:before(boss, context)
        --here call both systems to track a spell starting, and the visual effects
        for k, obj in ipairs(boss) do
            obj.timer = 0
        end
        self:init(boss, context)
        context.exit_con = M.exit_codes.NOT_FINISHED
        while context.exit_con ~= M.exit_codes.NOT_FINISHED do
            context.exit_con = self:exit_condition(seqsys,boss,context)
            self:frame(boss, context)
            coroutine.yield()
        end
        context.next_pattern = self:kill(boss, context)
        ---boss explode and everything
    
    end)
    return self
end

return M