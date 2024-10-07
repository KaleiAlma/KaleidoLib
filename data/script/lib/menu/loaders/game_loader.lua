local SceneMgr = require('lib.foundation.SceneMgr')
local Resources = require('lib.foundation.Resources')
local KeyInput = require('lib.foundation.KeyInput')
local Canvas = require('lib.foundation.Canvas')

--- A loading screen intended for starting gameplay.
---@class menu.loaders.GameLoader: foundation.scenemgr.Scene
local GameLoader = SceneMgr.addLoader('Game')

function GameLoader:onCreate()
    lstg.SetResourceStatus("global")
    lstg.LoadTexture('load:loading', 'loading/loading_game.png', true)
    lstg.LoadImage('load:loading', 'load:loading', 0, 0, lstg.GetTextureSize('load:loading'))
    Canvas.viewModeUI()
end

function GameLoader:onDestroy()
    lstg.RemoveResource('global', 1, 'load:loading')
    lstg.RemoveResource('global', 2, 'load:loading')
    lstg.SetResourceStatus("stage")
    Resources.setCurrentMgr()
end

function GameLoader:onUpdate()
    Resources.loadFrame()
    -- KeyInput.getInput()
    -- return Resources.getCurrentMgr():isDone() and KeyInput.keyDown('shoot')
    return Resources.getCurrentMgr():isDone()
end

function GameLoader:onRender()
    Canvas.viewModeUI()
    lstg.RenderClear(lstg.Color(0xFF000000))
    lstg.Render('load:loading', 1100, 80)
end

function GameLoader:onActivated()
end

function GameLoader:onDeactivated()
end

return GameLoader