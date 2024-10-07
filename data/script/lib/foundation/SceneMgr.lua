-- Originally from THlib, modified somewhat

local Screen = require('lib.foundation.Screen')
local Canvas = require('lib.foundation.Canvas')
local ScreenResources = require('lib.foundation.ScreenResources')
local Resources       = require('lib.foundation.Resources')

---@class foundation.scenemgr
local M = {}

---@class foundation.scenemgr.Scene
local Scene = {}

function Scene:getName()
    return "__default__"
end

function Scene:onCreate()
end

function Scene:onDestroy()
end

function Scene:onUpdate()
end

function Scene:onRender()
end

function Scene:onActivated()
end

function Scene:onDeactivated()
end

local function makeInstance(scene)
    return {
        onCreate = scene.onCreate,
        onDestroy = scene.onDestroy,
        onUpdate = scene.onUpdate,
        onRender = scene.onRender,
        onActivated = scene.onActivated,
        onDeactivated = scene.onDeactivated,
    }
end

local exit_signal = false

local load_flag = false

---@type foundation.scenemgr.Scene
local current_scene = makeInstance(Scene)

---@type foundation.scenemgr.Scene?
local current_loader = nil

---@type string
local current_scene_name = "__default__"

---@type string?
local next_scene_name = nil

---@type string?
local next_loader_name = nil

---@type table<string, foundation.scenemgr.Scene>
local scene_set = {
    ["__default__"] = Scene,
}

---@type table<string, foundation.scenemgr.Scene>
local loader_set = {}

---@param scene_name string
function M.setNext(scene_name)
    assert(type(scene_name) == "string")
    -- assert(string.len(scene_name) > 0)
    assert(scene_set[scene_name], string.format("scene '%s' not found", scene_name))
    if next_scene_name then
        lstg.Log(3, "next scene is updated to: " .. scene_name)
    else
        lstg.Log(2, "next scene: " .. scene_name)
    end
    next_scene_name = scene_name
end

---@param loader_name string
function M.setNextLoader(loader_name)
    assert(type(loader_name) == "string")
    -- assert(string.len(loader_name) > 0)
    assert(loader_set[loader_name], string.format("loader '%s' not found", loader_name))
    if next_loader_name then
        lstg.Log(3, "next loader is updated to: " .. loader_name)
    else
        lstg.Log(2, "next loader: " .. loader_name)
    end
    next_loader_name = loader_name
end

---@return foundation.scenemgr.Scene
function M.getCurrent()
    return current_scene
end

-- local screen_set = false

function M.update()
    if next_scene_name then
        if current_scene then
            current_scene:onDestroy()
        end
        current_scene_name = next_scene_name
        -- lstg.RemoveResource("global")
        -- lstg.RemoveResource("stage")
        Resources.clearPool("global")
        Resources.clearPool("stage")
        lstg.ResetPool()

        Screen.updateVideoMode()
        Canvas.initCanvas()

        ScreenResources.createScreenResources()

        current_scene = makeInstance(scene_set[next_scene_name])
        ---@diagnostic disable-next-line: duplicate-set-field
        function current_scene:getName()
            return current_scene_name
        end
        next_scene_name = nil
        current_scene:onCreate()
        if next_loader_name then
            current_loader = makeInstance(loader_set[next_loader_name])
            next_loader_name = nil
            current_loader:onCreate()
            return
        end
    end
    -- assert(current_scene_name == current_scene:getName(), "DO NOT DO STUPID THINGS")
    if current_loader then
        if current_loader:onUpdate() then
            current_loader:onDestroy()
            current_loader = nil
            -- screen_set = false
        end
    else
        -- if not screen_set then
        --     Screen.updateVideoMode()
        --     screen_set = true
        -- end
        current_scene:onUpdate()
    end
end

function M.render()
    if current_loader then
        current_loader:onRender()
    else
        current_scene:onRender()
    end
end

---@param v boolean
function M.setExitSignal(v)
    exit_signal = not (not v)
end

---@return boolean
function M.getExitSignal()
    return exit_signal
end

function M.onActivated()
    current_scene:onActivated()
end

function M.onDeactivated()
    current_scene:onDeactivated()
end

---@param scene_name string
---@param scene_type foundation.scenemgr.Scene?
---@return foundation.scenemgr.Scene
function M.add(scene_name, scene_type)
    assert(type(scene_name) == "string")
    -- assert(string.len(scene_name) > 0)
    if scene_set[scene_name] then
        lstg.Log(3, string.format("scene '%s' already exists, replacing", scene_name))
    end
    if scene_type then
        assert(type(scene_type) == "table")
    else
        scene_type = {}
        scene_type.onCreate = Scene.onCreate
        scene_type.onDestroy = Scene.onDestroy
        scene_type.onUpdate = Scene.onUpdate
        scene_type.onRender = Scene.onRender
        scene_type.onActivated = Scene.onActivated
        scene_type.onDeactivated = Scene.onDeactivated
    end
    lstg.Log(2, string.format("add scene '%s' to scene manager", scene_name))
    scene_set[scene_name] = scene_type
    return scene_type
end

---@param loader_name string
---@param loader_type? foundation.scenemgr.Scene
---@return foundation.scenemgr.Scene
function M.addLoader(loader_name, loader_type)
    assert(type(loader_name) == "string")
    -- assert(string.len(loader_name) > 0)
    if loader_set[loader_name] then
        lstg.Log(3, string.format("loader '%s' already exists, replacing", loader_name))
    end
    if loader_type then
        assert(type(loader_type) == "table")
    else
        loader_type = {}
        loader_type.onCreate = Scene.onCreate
        loader_type.onDestroy = Scene.onDestroy
        loader_type.onUpdate = Scene.onUpdate
        loader_type.onRender = Scene.onRender
        loader_type.onActivated = Scene.onActivated
        loader_type.onDeactivated = Scene.onDeactivated
    end
    lstg.Log(2, string.format("add loader '%s' to scene manager", loader_name))
    loader_set[loader_name] = loader_type
    return loader_type
end

return M
