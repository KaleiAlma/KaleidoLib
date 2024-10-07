--- KaleidoLib Resource Management module
---@class foundation.resources
local M = {}

---@type foundation.resources.manager?
local current_mgr = nil

--- Loads a texture from a file, then loads an image from that texture.  
--- Both the texture and image will be named the same, so if you want to
--- make a copy of the image, you can do `lstg.LoadImage(newname, oldname)`
---@param name string
---@param path string
local function loadImageFromFile(name, path)
    lstg.LoadTexture(name, path)
    local w, h = lstg.GetTextureSize(name)
    lstg.LoadImage(name, name, 0, 0, w, h)
end

local function loadImageGroup(name, texname, x, y, w, h, cols, rows, a, b, rect)
    for i = 0, cols * rows - 1 do
        lstg.LoadImage(name .. (i + 1), texname, x + w * (i % cols), y + h * (math.floor(i / cols)), w, h, a or 0, b or 0, rect or false)
    end
end

M.loaders = {
    tex = lstg.LoadTexture,
    img = lstg.LoadImage,
    imgfile = loadImageFromFile,
    imggrp = loadImageGroup,
    ani = lstg.LoadAnimation,
    bgm = lstg.LoadMusic,
    snd = lstg.LoadSound,
    ps = lstg.LoadPS,
    fnt = lstg.LoadFont,
    ttf = lstg.LoadTTF,
    fx = lstg.LoadFX,
    mdl = lstg.LoadModel,
}

--- Descriptor for a single resource.
---@class foundation.resources.resdesc
---
--- The name of the resource.
---@field name string
---
--- The resource's type.  
--- Usually will be one of the LuaSTG built-in resource types
--- (`tex, img, ani, bgm, snd, ps, fnt, ttf, fx, mdl`),
--- as well as `imgfile` for loading images directly from a file,
--- and `imggrp` for loading multiple sequential images.  
--- However, custom types are allowed, as long as a loader function is
--- registered with the resource manager.
---@field type string
---
--- Extra arguments to the resource loader function
--- (usually starts with a file path or a texture name).
---@field args table

---@type { [string]: fun(respool: lstg.ResourcePoolType) }
local custom_resource_clear_handlers = {}

--- Adds a function to handle pool clearing for custom resources.
---@param restype string
---@param f fun(respool: lstg.ResourcePoolType)
function M.addClearPoolHandler(restype, f)
    custom_resource_clear_handlers[restype] = f
end

--- Resets pool clearing for the given custom resource.
function M.removeClearPoolHandler(restype)
    custom_resource_clear_handlers[restype] = nil
end

--- Clears the specified resource pool.
---@param respool lstg.ResourcePoolType
function M.clearPool(respool)
    for _, v in pairs(custom_resource_clear_handlers) do
        v(respool)
    end
    lstg.RemoveResource(respool)
end


------------------------------------------------------------

--- Loads a single resource from the associated resource description table.
---@param self foundation.resources.manager
---@return boolean
local function resmgr_load(self)
    if self.done then return false end
    if self.idx > #self.resdesc then
        if self.postLoad then self:postLoad() end
        self.done = true
        return false
    end
    local res = self.resdesc[self.idx]
    M.loaders[res.type](res.name, unpack(res.args))
    self.idx = self.idx + 1
    return true
end

---@param self foundation.resources.manager
local function resmgr_reset(self)
    self.idx = 1
end

---@param self foundation.resources.manager
---@return boolean
local function resmgr_isDone(self)
    return self.done
end

--- Creates a new resource manager which will load resources specified
--- by the provided table and can be called asynchronously.
--- @param resdesc foundation.resources.resdesc[]
--- @param post_load fun(self: foundation.resources.manager)?
--- @return foundation.resources.manager
function M.newMgr(resdesc, post_load)
    ---@class foundation.resources.manager
    local resmgr = {}
    resmgr.resdesc = resdesc
    resmgr.idx = 1
    resmgr.done = false
    resmgr.load = resmgr_load
    resmgr.reset = resmgr_reset
    resmgr.isDone = resmgr_isDone
    resmgr.postLoad = post_load

    return resmgr
end

--- Sets the current resource manager in order to load from it.
---@param mgr foundation.resources.manager?
function M.setCurrentMgr(mgr)
    current_mgr = mgr
end

--- Gets the current resource manager in order to load from it.
---@return foundation.resources.manager?
function M.getCurrentMgr()
    return current_mgr
end

--- Performs one frame's worth of resource loading.  
--- You are encouraged to write your own loading code should you need
--- more specific behavior.
function M.loadFrame()
    if not current_mgr or not current_mgr:load() then
        return
    end
    --- unrolled loops are faster, right?
    current_mgr:load()
    current_mgr:load()
    current_mgr:load()
    current_mgr:load()
    current_mgr:load()
    current_mgr:load()
    current_mgr:load()
    current_mgr:load()
    current_mgr:load()
end

return M