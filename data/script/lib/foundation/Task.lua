
---@class foundation.task
local M = {}
-- local stack = {}
-- local co_stack = {}

---@return foundation.task.manager
function M.manager()
    ---@class foundation.task.manager
    ---@field [integer] thread
    ---@field self table
    local I = {}

    I.size = 0

    --- Note: "thread" in lua are actually coroutines
    ---@param f fun(self: table)
    ---@return thread
    function I:add(f)
        local co = coroutine.create(f)
        self.size = self.size + 1
        self[self.size] = co
        return co
    end

    --- resume all not "dead" coroutines
    function I:resume_all()
        local n = self.size
        for i = 1, n do
            if coroutine.status(self[i]) ~= "dead" then
                -- table.insert(stack, self)
                -- table.insert(co_stack, self[i])
                local s = self.self
                if s.taskself then
                    s = s.taskself
                end
                local _, errmsg = coroutine.resume(self[i], s)
                if errmsg then
                    error(tostring(errmsg) .. "\ncoroutine traceback: -------\n" .. debug.traceback(self[i]) .. "\nC traceback: -------")
                end
                -- stack[#stack] = nil
                -- co_stack[#co_stack] = nil
            end
        end
    end

    --- remove all "dead" coroutines
    function I:remove_dead()
        local j = 1
        local n = self.size
        for i = 1, n do
            if coroutine.status(self[i]) ~= "dead" then
                if i > j then
                    self[j] = self[i]
                end
                j = j + 1
            end
        end
        for k = j, n do
            self[k] = nil
        end
        self.size = j - 1
    end

    --- remove all coroutines
    function I:clear()
        local n = self.size
        for i = 1, n do
            self[i] = nil
        end
        self.size = 0
    end

    return I
end

---@param times number?
function M.wait(times)
    if times == nil then
        times = 1
    end
    for _ = 1, times do
        coroutine.yield()
    end
end

---@param target table
---@param f fun(self: table)
function M.new(target, f)
    if not target.task then
        target.task = M.manager()
        target.task.self = target
    end
    return target.task:add(f)
end

---@param target table
function M.doFrame(target)
    if not target.task then return end
    target.task:resume_all()
end

---@param target table
function M.clear(target)
    if not target.task then return end
    target.task:clear()
end

-- function M.getSelf()
--     if #stack < 1 then return end
--     local c = stack[#stack].self
--     if c.taskself then
--         return c.taskself
--     else
--         return c
--     end
-- end

return M