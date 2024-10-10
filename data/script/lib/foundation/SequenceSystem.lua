---@class foundation.SequenceSystem
---@field queue table<integer, foundation.SequenceSystem.Sequence>
---@field stack table<integer, foundation.SequenceSystem.Sequence>
---@field current_sequence foundation.SequenceSystem.Sequence
---@field coroutine thread
---@field add fun(self:foundation.SequenceSystem, sequence:foundation.SequenceSystem.Sequence)
---@field next fun(self:foundation.SequenceSystem, sequence?:foundation.SequenceSystem.Sequence)
---@field back fun(self:foundation.SequenceSystem)
local M = {}

---@class foundation.SequenceSystem.Sequence
---@field fun fun(system:foundation.SequenceSystem)
---@field out fun(system:foundation.SequenceSystem)
---@field init fun(system:foundation.SequenceSystem)
---@field update fun(system:foundation.SequenceSystem)
M.Sequence = {}

local passthrough = function () end

---@return foundation.SequenceSystem
function M.new()
    ---@class foundation.SequenceSystem
    local self = {}

    self.queue = {}
    self.stack = {}
    self.current_sequence = nil
    self.coroutine = nil

    function self:add(sequence) --adds the sequence to the queue
        if self.current_sequence == nil then
            self.current_sequence = sequence
            self.coroutine = nil
            table.insert(self.stack,sequence)
        else
            table.insert(self.queue,sequence)
        end
    end
    function self:next(sequence) --if the sequence is nil, pop the queue, else, execute the sequence
        self.current_sequence.out(self)
        if sequence then
            self.current_sequence = sequence
        else
            self.current_sequence = table.remove(self.queue, 1)
        end
        table.insert(self.stack,self.current_sequence)
        self.coroutine = nil
    end
    function self:back()
        self.current_sequence.out(self)
        self.current_sequence = table.remove(self.stack)
        self.coroutine = nil
    end
    function self:update()
        local sequence = self.current_sequence
        if self.coroutine == nil then
            sequence.init(self)
            self.coroutine = coroutine.create(sequence.fun)
        end
        sequence.update(self)
        local ok, ret = coroutine.resume(self.coroutine,self)
        if not ok then
            error(ret)
        end
    end
    return self
end

---@param fun fun(system:foundation.SequenceSystem)
---@param out? fun(system:foundation.SequenceSystem)
---@param init? fun(system:foundation.SequenceSystem)
---@param update? fun(system:foundation.SequenceSystem)
---@return foundation.SequenceSystem.Sequence
function M.Sequence.new(fun, out, init, update)
    ---@class foundation.SequenceSystem.Sequence
    local self = {}
    self.fun = fun
    self.out = out or passthrough
    self.init = init or passthrough
    self.update = update or passthrough
    return self
end


---
--[[
function task.ClearTask(obj,task)
    for k, _task in ipairs(obj._task) do
        if task == _task then
            table.remove(obj._task, k)
            return
        end
    end
end
]]
---
--[[nextmethods are tables with the following functions:
    self:next() to move on to the next one

    function menumanager.new()
        local self = {}
        local seqsys = SequenceSystem()
        seqsys:add(menu)
    end 

    function menu.new()
        local self = {}
        --initialize data here
        local sequence = SequenceSystem.Sequence(function()
            --use the menu around here
            self:moveto(next)
        end)
        
        function self:moveto(next_menu)
            sequence:next(menu2)
        end
    end

    function menu2.new()
        local self = {}
        --initialize data here
        local sequence = SequenceSystem.Sequence(self.task)
        function self:task()
            --use the menu around here
            self:moveto(next)
        end
        function self:moveto(next_menu)
            sequence:next()
        end
    end
]]


--[[

boss.cards = {
    card.new(),
    branchingcard.new(card2a, card2b)
}

function spell1:decideNext()    
    if boss1.died then
        return 1
    end
    return 2
end
]]


return M