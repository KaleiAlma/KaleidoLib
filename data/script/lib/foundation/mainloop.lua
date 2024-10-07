local Debugger  = require('lib.foundation.Debugger')
local SceneMgr  = require('lib.foundation.SceneMgr')
local ObjectLib = require('lib.foundation.ObjLib')
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
    SceneMgr.update()
    Debugger.layout()
    lstg.SetTitle(string.format('%.2f' ,lstg.GetFPS()))
    return SceneMgr.getExitSignal()
end

function RenderFunc()
    lstg.BeginScene()
    ScreenResources.updateScreenResources()
    SceneMgr.render()
    Debugger.draw()
    lstg.EndScene()
    ---@diagnostic disable-next-line: deprecated
    -- if setting and setting.keysys and lstg.GetLastKey() == setting.keysys.snapshot then
    --     LocalFileStorage.snapshot()
    -- end
end

function FocusLoseFunc()
    SceneMgr.onDeactivated()
end

function FocusGainFunc()
    SceneMgr.onActivated()
end
