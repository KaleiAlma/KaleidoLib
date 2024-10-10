local SceneManager = require('lib.foundation.SceneManager')
local Resources = require('lib.foundation.Resources')

--- A blank loading screen.
---@class menu.loaders.DefaultLoader: foundation.scenemanager.Scene
local DefaultLoader = SceneManager.addLoader('Default')

function DefaultLoader:onCreate()
end

function DefaultLoader:onDestroy()
end

function DefaultLoader:onUpdate()
    Resources.loadFrame()
    return Resources.getCurrentMgr():isDone()
end

function DefaultLoader:onRender()
end

function DefaultLoader:onActivated()
end

function DefaultLoader:onDeactivated()
end

return DefaultLoader