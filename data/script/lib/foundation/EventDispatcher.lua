---@class foundation.EventDispatcher
local M = {}
---@class foundation.EventDispatcher.Event 
M.Event = {}

function M.new()
    local self = {}
    self.events = {}

    function self:add(event)
        table.insert(event.dispatchers,self) --add a reference of the dispatcher 
        if #self.events == 0 then --if there are no events
            table.insert(self.events,event)
            return
        end
        for k, value in ipairs(self.events) do --check all the events to see where it should land
            if value.priority > event.priority then
                table.insert(self.events,k,event)
                return
            end
        end
        table.insert(self.events,event) --add at the end if it shoud be last
    end

    function self:remove(event)
        for k, value in ipairs(self.events) do
            if value == event or (type(event == "string") and value.name == event) then
                table.remove(self.events,k)
                return
            end
        end
    end

    function self:call(...)
        for k, event in self.events do
            event(...)
        end
    end

    setmetatable(self,{
        __call = self.call,
        __add = self.add,
        __sub = self.remove
    })
    return self
end

function M.Event.new(name, fun, priority)
    local self = {}
    self.name = name
    self.fun = fun
    self.priority = priority
    self.dispatchers = {}

    function self:remove()
        for k, dispatcher in ipairs(self.dispatchers) do
            dispatcher:remove(self)
        end
    end

    setmetatable(self,{
        __call = function(self,...)
            return self.fun(...)
        end
    })
    return self
end

setmetatable(M, {
    __call = function(self)
        return M.new()
    end
})
setmetatable(M.Event, {
    __call = function(self,...)
        return M.Event.new(...)
    end
})
return M