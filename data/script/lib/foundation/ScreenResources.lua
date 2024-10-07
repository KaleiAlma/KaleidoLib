--- KaleidoLib Screen Resources module
---@class foundation.screen_resources
local M = {}
local Canvas = require('lib.foundation.Canvas')
local Shapes = require('lib.foundation.Shapes')

local loaded = false

function M.createScreenResources()
    lstg.SetResourceStatus("global")
    lstg.CreateRenderTarget('rt:white', 16, 16)
    lstg.LoadImage('white', 'rt:white', 0, 0, 16, 16)
    lstg.LoadImage('inv_white', 'rt:white', 0, 0, 16, 16)
    lstg.LoadImage('canvas:white', 'rt:white', 0, 0, 16, 16)

    lstg.SetImageState('inv_white', 'mul+sub')

    lstg.CreateRenderTarget('rt:misc', 512, 512)
    lstg.LoadImage('misc:solid_circle', 'rt:misc', 0, 0, 128, 128)
    lstg.LoadImage('misc:fuzzy_circle', 'rt:misc', 128, 0, 128, 128)
    lstg.LoadImage('misc:bubble', 'rt:misc', 256, 0, 128, 128)

    lstg.LoadImage('misc:star', 'rt:misc', 0, 128, 128, 128)

    lstg.SetImageScale('misc:solid_circle', 0.25)
    lstg.SetImageScale('misc:fuzzy_circle', 0.25)
    lstg.SetImageScale('misc:bubble', 0.25)
    lstg.SetImageScale('misc:star', 0.25)

    loaded = false
end

M.createScreenResources()


function M.updateScreenResources()
    if loaded then return end

    lstg.PushRenderTarget('rt:white')
    lstg.RenderClear(lstg.Color(0xFFFFFFFF))
    lstg.PopRenderTarget()

    lstg.SetImageState('white', '', lstg.Color(0xFFFFFFFF))
    lstg.PushRenderTarget('rt:misc')
    lstg.SetScissorRect(0, 512, 0, 512)
    lstg.SetViewport(0, 512, 0, 512)
    lstg.SetOrtho(0, 512, 512, 0)
    lstg.SetFog()
    lstg.RenderClear(lstg.Color(0))

    -- solid_circle
    Shapes.renderCircleA(64, 64, 63, 36)

    -- fuzzy_circle
    lstg.SetImageState('white', '', lstg.Color(0xFFFFFFFF), lstg.Color(0xFFFFFFFF), lstg.Color(0x00FFFFFF), lstg.Color(0x00FFFFFF))
    Shapes.renderCircleA(192, 64, 64, 36)
    lstg.SetImageState('white', '', lstg.Color(0xAAFFFFFF), lstg.Color(0xAAFFFFFF), lstg.Color(0x00FFFFFF), lstg.Color(0x00FFFFFF))
    Shapes.renderCircleA(192, 64, 64, 36)

    -- bubble
    lstg.SetImageState('white', '', lstg.Color(0x00FFFFFF), lstg.Color(0x00FFFFFF), lstg.Color(0xFFFFFFFF), lstg.Color(0xFFFFFFFF))
    Shapes.renderCircleB(320, 64, 16, 63, 36)
    Shapes.renderCircleB(320, 64, 50, 63, 36)

    -- fake anti-aliasing for solid_circle and bubble
    lstg.SetImageState('white', '', lstg.Color(0xFFFFFFFF), lstg.Color(0xFFFFFFFF), lstg.Color(0x00FFFFFF), lstg.Color(0x00FFFFFF))
    Shapes.renderCircleB(64, 64, 63, 64, 36)
    Shapes.renderCircleB(320, 64, 63, 64, 36)


    -- star
    lstg.SetImageState('white', '', lstg.Color(0xFFFFFFFF))
    Shapes.renderStarA(64, 192, 62, 34, 5)

    -- fake anti-aliasing for star
    lstg.SetImageState('white', '', lstg.Color(0x00FFFFFF), lstg.Color(0x00FFFFFF), lstg.Color(0xFFFFFFFF), lstg.Color(0xFFFFFFFF))
    Shapes.renderStarB(64, 192, 64, 36, 2, 5)


    lstg.PopRenderTarget()
    Canvas.viewModeUI()
    lstg.SetImageState('white', '', lstg.Color(0xFFFFFFFF))

    loaded = true
end

function M.refreshScreenResources()
    loaded = false
end

return M