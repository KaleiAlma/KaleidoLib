---@class foundation.Path
local M = {}
---sample = get position in a path
---sampleDerivative = get the derivative of the position at a spot
M.types = {}

function M.new(type,data)
    local self = {}
    self.data = data or {}
    self.type = type
    self.transform = math.identity_matrix()
    function self:sample(t)
        return M.types[self.type].sample(self,t)
    end
    function self:sampleDerivative(t)
        if M.types[self.type].sampleDerivative[self.type] then
            return M.types[self.type].sampleDerivative(self,t)
        else
            return self:sample(t) - self:sample(t-0.001)
        end
    end
    function self:approximate(resolution)
        local ret = {}
        for i=0, resolution do
            local t = i/resolution
            ret.insert(self:sample(t))
        end
        return self
    end
    function self:transform(other)
        self.transform = self.transform * other
        return M.types[self.type].transform(self,other)
    end
    return self
end



--[[
    local p = Path("bezier", {pointset = {Vector(1,2), Vector(3,4), Vector(5,6)}})

    local s = Path("star", {shape="star", side=5, indent = 0.25, angle = 0})

    s.sample(0.3)

    local test = p.Approximate(1500)
]]

M.types.cubic_bezier = {}
function M.types.cubic_bezier:sample(t)
    local t1 = t * #self.data.pointset/3
    local nt = t1 - math.floor(t1)
    local it = math.floor(t1)
    return 3 * (1-nt)^3 * (self.data.pointset[it+1] - self.data.pointset[it]) + 
           6 * (1-nt) * nt * (self.data.pointset[it+2]-self.data.pointset[it+1]) + 
           3 * t^2 * (self.data.pointset[it+3] - self.data.pointset[it+2])
end
function M.types.cubic_bezier:transform(other)
    for k, v in ipairs(self.data.pointset) do
        self.data.pointset[k] = v * other 
    end
end

setmetatable(M, {
    __call = function(self,...)
        return M.new(...)
    end
})
return M