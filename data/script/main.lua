require('lib.foundation.mainloop')
require('lib.foundation.globals')

local Plugin = require('lib.foundation.Plugin')
local SceneMgr = require('lib.foundation.SceneMgr')
local ObjLib = require('lib.foundation.ObjLib')
local Canvas = require('lib.foundation.Canvas')
local Screen = require('lib.foundation.Screen')
local Setting = require('lib.foundation.Setting')
local Sound = require('lib.foundation.Sound')
local Task = require('lib.foundation.Task')
local Tasker = require('lib.game.Tasker')
local Enemy = require('lib.game.Enemy')
local Stage = require('lib.game.Stage')
local Bullet = require('lib.game.Bullet')
local Player = require('lib.game.Player')
local WISys = require('lib.game.WISys')
local vars = require('lib.game.vars')

require('lib.game.scene')
require('lib.menu.loaders.game_loader')


SceneMgr.setNext('Game')

vars.player.name = 'marisa'

local p = require('assets.game.player.' .. vars.player.name).chardef

local test_stage = Stage.new('test')

local function recurse_table(pre, tbl)
    for k, v in pairs(tbl) do
        print(pre .. k)
        if type(v) == 'table' and v ~= tbl then
            recurse_table(pre .. k .. '.', v)
        end
    end
end

function test_stage:init()
    -- print("lstg Check initialized")
    -- recurse_table('lstg.', lstg)
    -- print("lstg Check is done")
    lstg.LoadMusic('boss', 'bgm/boss.ogg', 185.714, 114.285)
    lstg.PlayMusic('default:boss', 0.8, 0)

    Player.Player.new(p)
    -- for i, v in ipairs(lstg.ListMonitor()) do
    --     print(i, v.width, v.height)
    -- end
    -- Screen.updateVideoMode()
    -- local e = Enemy.Enemy.new(1200, false, WISys.fairy_anim, {
    --     'enemy:fairy_head_a3',
    --     'enemy:fairy_arm_b2',
    --     'enemy:fairy_body_a3',
    --     'enemy:fairy_wing_b',
    --     'enemy:fairy_legs6',
    -- })
    -- local e = Enemy.Enemy.new(1200, false, WISys.wheel_ghost, 5)
    local e = Enemy.Enemy.new(1200, false, WISys.undefined)
    e.y = 120
    e.hscale = 0.6
    e.vscale = 0.6
    e.a = 0.6 * e.a
    e.b = 0.6 * e.b
    e.protect = 60
    -- local e = Enemy.Enemy.new(1200, false, WISys.fairy_anim, {
    --     'enemy:fairy_head_a3',
    --     'enemy:fairy_arm_b2',
    --     'enemy:fairy_body_a3',
    --     'enemy:fairy_wing_b',
    --     'enemy:fairy_legs6',
    -- })
    -- e.y = 140
    -- e.hscale = 0.6
    -- e.vscale = 0.6
    -- e.a = 0.6 * e.a
    -- e.b = 0.6 * e.b
    -- e.protect = 60
    -- local e = Enemy.Enemy.new(1200, false, WISys.fairy_anim, {
    --     'enemy:fairy_head_a3',
    --     'enemy:fairy_arm_b2',
    --     'enemy:fairy_body_a3',
    --     'enemy:fairy_wing_b',
    --     'enemy:fairy_legs6',
    -- })
    -- e.y = 160
    -- e.hscale = 0.6
    -- e.vscale = 0.6
    -- e.a = 0.6 * e.a
    -- e.b = 0.6 * e.b
    -- e.protect = 60
    -- Task.new(e, function()
    --     while true do
    --         e.x = 100 * lstg.sin(e.timer * 1.5)
    --         coroutine.yield()
    --     end
    -- end)
    -- Task.new(e, function()
    --     Task.wait(40)
    --     while true do
    --         Bullet.fireGroup('arrow_big', Bullet.COLOR.BLUE, e.x, e.y, 3, 0, 5, 90, true)
    --         lstg.PlaySound('kira00', 0.4, 0)
    --         Task.wait(20)
    --         Bullet.fireGroup('ball_big', Bullet.COLOR.BLUE, e.x, e.y, 3, 0, 4, 90, true)
    --         lstg.PlaySound('kira00', 0.4, 0)
    --         Task.wait(40)
    --     end
    -- end)
    -- Task.new(self, function()
    --     Task.wait(120)
    --     Task.new(self, function()
    --         for i = 1, 80 do
    --             -- lstg.PlaySound('kira00', 0.6, -0.5)
    --             lstg.PlaySound('kira00', 0.4, 0)
    --             -- Sound.playSfxRandPitch('kira00', 0.01, 0.4, 0)
    --             Bullet.fireGroup('arrow_big', Bullet.COLOR.CYAN, -200, 200, 3, 0, 6, 90, true)
    --             Task.wait(3)
    --             -- lstg.PlaySound('kira00', 0.6, 0.5)
    --             Bullet.fireGroup('arrow_big', Bullet.COLOR.RED, 200, 200, 3, 0, 7, 90, true)
    --             Task.wait(6)
    --         end
    --         -- Setting.get().screen.width = 640
    --         -- Setting.get().screen.height = 360
    --         -- Screen.updateVideoMode()
    --         -- Canvas.initCanvas()
    --     end)
    -- end)
    -- Task.new(self, function()
    --     Task.wait(180)
    --     lstg.PlaySound('kira00', 0.6, -0.5)
    --     -- local b = ObjLib.newInst(Bullet.RGBBullet, 'arrow_big', lstg.Color(0xFF119999))
    --     -- local b = ObjLib.newInst(Bullet.Bullet, 'arrow_big', Bullet.COLOR.CHARTREUSE)
    --     -- local b = Bullet.fire('arrow_big', Bullet.COLOR.CYAN, -200, 200, 3, -45, false, false, 3)
    --     local l = Bullet.fireGroup('arrow_big', Bullet.COLOR.CYAN, -200, 200, 2.2, -45, 6, 90, false, false)

    --     -- b.x = -220
    --     -- b.y = 220
    --     -- lstg.SetV(b, 3, -45, true)
    --     -- b.omiga = 1
    --     Task.new(self, function()
    --         Task.wait(180)
    --         for _, b in ipairs(l) do
    --             if lstg.IsValid(b) then
    --                 lstg.Del(b)
    --             end
    --         end
    --         -- lstg.Del(b)
    --     end)
    --     -- Task.new(self, function()
    --     --     while lstg.IsValid(b) do
    --     --         -- b._color.h = (b._color.h + 0.3) % 100
    --     --         b._color = lstg.HSVColor(b._color.a * 255 / 100, (b._color.h + 0.3) % 100, b._color.s, b._color.v)
    --     --         -- print(b._color.h)
    --     --         Task.wait()
    --     --     end
    --     -- end)
    -- end)
end

Stage.set('test')
