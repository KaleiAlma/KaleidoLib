local SceneManager = require('lib.foundation.SceneManager')
local KeyInput = require('lib.foundation.KeyInput')
local Group = require('lib.foundation.collision_group')
local Canvas = require('lib.foundation.Canvas')
local Resources = require('lib.foundation.Resources')
local Screen    = require('lib.foundation.Screen')

local Hud = require('lib.game.Hud')
local Stage = require('lib.game.Stage')
local vars = require('lib.game.vars')

---@class game.GameScene: foundation.scenemanager.Scene
local GameScene = SceneManager.add('Game')

--#region resource loading

local assets = {
    hud = require('assets.game.hud'),
    bullet = require('assets.game.bullet'),
    enemy = require('assets.game.enemy'),
    player = require('assets.game.player'),
    sfx = require('assets.sfx'),
    bgm = require('assets.bgm'),
}

-- local base_resdesc = {}
local resdesc = {}

for _, tbl in pairs(assets) do
    for _, v in ipairs(tbl.resdesc) do
        table.insert(resdesc, v)
    end
end

local resmgr = Resources.newMgr(resdesc, function(_)
    for _, tbl in pairs(assets) do
        if tbl.postLoad then tbl.postLoad() end
    end

    -- Resource Manager Chaining, kinda hacky but works perfectly

    local player = require('assets.game.player.' .. vars.player.name)
    Resources.setCurrentMgr(Resources.newMgr(player.resdesc, function(_)
        if player.postLoad then player.postLoad() end
    end))
end)
--#endregion

function GameScene:onCreate()
    Hud.init()
    SceneManager.setNextLoader('Game')
    Resources.setCurrentMgr(resmgr)
    lstg.SetSplash(false)
    -- assets.player = require('assets.game.player.' .. vars.player.name)
end

function GameScene:onDestroy()
    lstg.SetWorldFlag(15) -- default worlds enable, just in case
    resmgr:reset()
end

local function doFrame()
    KeyInput.getInput()
    if Stage.nextStageExist() then
        Stage.change()
    end
    Stage.update()
    lstg.ObjFrame()
    Canvas.boundCheck()
    Group.doCollision()
    lstg.UpdateXY()
    lstg.AfterFrame()
    Hud.update()
end

function GameScene:onUpdate()
    -- TODO: replays
    doFrame()

    -- debug
    if KeyInput.keyPressed('pause') then
        SceneManager.setExitSignal(true)
    end
end

local f = Canvas.field
function GameScene:onRender()
    lstg.RenderClear(lstg.Color(0xFF000000))
    Canvas.viewModeUI()
    Hud.render()
    Canvas.viewModeField()
    Canvas.fillView(lstg.Color(0xFF000000))
    Stage.current_stage:render()
    Canvas.viewModeField()
    Canvas.objRender()
    Canvas.drawCollider() -- TODO: disable this on release
end

return GameScene