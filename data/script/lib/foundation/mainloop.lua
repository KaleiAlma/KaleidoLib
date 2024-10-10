local Debugger  = require('lib.foundation.Debugger')
local SceneManager  = require('lib.foundation.SceneManager')
local ObjectLib = require('lib.foundation.Object')
local ScreenResources = require('lib.foundation.ScreenResources')
local Screen = require('lib.foundation.Screen')
local Canvas = require('lib.foundation.Canvas')
local Setting = require('lib.foundation.Setting')

Setting.load()
Setting.save()

function GameInit()
    ObjectLib.registerAllClass()

    for i, v in ipairs(lstg.ListMonitor()) do
        print('monitor ' .. i .. ':', v.width .. 'x' .. v.height)
    end
end

function GameExit()
end

function FrameFunc()
    Debugger.update()
    SceneManager.update()
    Debugger.layout()
    lstg.SetTitle(string.format('%.2f' ,lstg.GetFPS()))
    return SceneManager.getExitSignal()
end

function RenderFunc()
    lstg.BeginScene()
    ScreenResources.updateScreenResources()
    SceneManager.render()
    Debugger.draw()
    lstg.EndScene()
    ---@diagnostic disable-next-line: deprecated
    -- if setting and setting.keysys and lstg.GetLastKey() == setting.keysys.snapshot then
    --     LocalFileStorage.snapshot()
    -- end
end

function FocusLoseFunc()
    SceneManager.onDeactivated()
end

function FocusGainFunc()
    SceneManager.onActivated()
end
