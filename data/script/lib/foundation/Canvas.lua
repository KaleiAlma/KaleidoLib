--- KaleidoLib Game Canvas module
---@class foundation.canvas
local M = {}
local config = require('lib._config').canvas
-- local Screen = require('lib.foundation.Screen')
local Setting = require('lib.foundation.Setting')
-- local scr_set = setting.screen

--------------------------------------------------------------------------------
-- base fields

-- constants

---@enum foundation.canvas.view_modes
M.view_modes = {
    UNKNOWN = 0,
    UI = 1,
    FIELD = 2,
    BG3D = 3,
}

--- LuaSTG world-based render grouping
---@enum foundation.canvas.render_group
M.render_group = {
    UNKNOWN = 0,
    UI = bit.lshift(1, 20),
    FIELD = bit.lshift(1, 21),
}

-- module fields

M.width = config.width
M.height = config.height
M.scale = 1
M.dx = 0
M.dy = 0
M.default_field = config.field
M.field = {
    l = M.default_field.l, r = M.default_field.r,
    b = M.default_field.b, t = M.default_field.t,
    bound = {
        l = M.default_field.bound.l, r = M.default_field.bound.r,
        b = M.default_field.bound.b, t = M.default_field.bound.t,
    },
    player_bound = {
        l = M.default_field.player_bound.l, r = M.default_field.player_bound.r,
        b = M.default_field.player_bound.b, t = M.default_field.player_bound.t,
    },
    screen = {
        l = M.default_field.screen.l, r = M.default_field.screen.r,
        b = M.default_field.screen.b, t = M.default_field.screen.t,
    },
}
M.field_transform = {
    zoom_x = 1,   zoom_y = 1,       -- field zoom
    center_x = 0, center_y = 0,     -- field zoom center position
    offset_x = 0, offset_y = 0,     -- field offset
}
M.view_bg3d = {
    x = 0, y = 0, z = -1,
    atx = 0, aty = 0, atz = 0,
    upx = 0, upy = 1, upz = 0,
    fovy = math.pi / 2,
    z_near = 0, z_far  = 2,
    fog_near = 0, fog_far = 0,
    fog_color = lstg.Color(0x00000000),
}

-- module private locals

local current_view = 0

--------------------------------------------------------------------------------
-- initialization methods

function M.initCanvas()
    local scr_set = Setting.get().screen
    local hscale, vscale = scr_set.width / M.width, scr_set.height / M.height
    -- local scr_scale = scr_set.width / scr_set.height
    M.scale = math.min(hscale, vscale)
    if hscale > vscale then
        M.dx = (scr_set.width - M.scale * M.width) / 2
        M.dy = 0
    else
        M.dx = 0
        M.dy = (scr_set.height - M.scale * M.height) / 2
    end
end

function M.resetField()
    M.field.l = M.default_field.l
    M.field.r = M.default_field.r
    M.field.b = M.default_field.b
    M.field.t = M.default_field.t
    --
    M.field.bound.l = M.default_field.bound.l
    M.field.bound.r = M.default_field.bound.r
    M.field.bound.b = M.default_field.bound.b
    M.field.bound.t = M.default_field.bound.t
    --
    M.field.player_bound.l = M.default_field.player_bound.l
    M.field.player_bound.r = M.default_field.player_bound.r
    M.field.player_bound.b = M.default_field.player_bound.b
    M.field.player_bound.t = M.default_field.player_bound.t
    --
    M.field.canvas.l = M.default_field.canvas.l
    M.field.canvas.r = M.default_field.canvas.r
    M.field.canvas.b = M.default_field.canvas.b
    M.field.canvas.t = M.default_field.canvas.t
    --
    M.field_transform.zoom_x = 1
    M.field_transform.zoom_y = 1
    M.field_transform.center_x = 0
    M.field_transform.center_y = 0
    M.field_transform.offset_x = 0
    M.field_transform.offset_y = 0
end

--------------------------------------------------------------------------------
-- viewport / view modes

local function setViewportAndScissorRect(l, r, b, t)
    lstg.SetViewport(l, r, b, t)
    lstg.SetScissorRect(l, r, b, t)
end

--- Sets the 2D viewport.  
--- `scr` parameters outline the viewport on the screen (screen coordinates).  
--- `view` parameters set the bounds of the viewport's own coordinate system.
---@param scr_l number
---@param scr_r number
---@param scr_b number
---@param scr_t number
---@param view_l number
---@param view_r number
---@param view_b number
---@param view_t number
function M.setViewport2D(scr_l, scr_r, scr_b, scr_t, view_l, view_r, view_b, view_t)
    setViewportAndScissorRect(
        scr_l * M.scale + M.dx,
        scr_r * M.scale + M.dx,
        scr_b * M.scale + M.dy,
        scr_t * M.scale + M.dy
    )
    lstg.SetOrtho(view_l, view_r, view_b, view_t)
    lstg.SetFog()
    current_view = M.view_modes.UNKNOWN
end

--- Sets the viewport to UI mode.
function M.viewModeUI()
    M.setViewport2D(0, M.width, 0, M.height, 0, M.width, 0, M.height)
    lstg.SetImageScale(1)
    current_view = M.view_modes.UI
end

--- Sets the viewport to play field mode.
function M.viewModeField()
    local t = M.field_transform
    local f = M.field
    local width, height = f.r - f.l, f.t - f.b

    -- because we are setting the rendered bounds of the play area rather than
    -- the total dimensions of the zoomed play area, we divide instead of multiply.
    local z_w, z_h = width / t.zoom_x, height / t.zoom_y
    local z_offx, z_offy = t.offset_x / t.zoom_x, t.offset_y / t.zoom_y

    local view_l = t.center_x - z_w / 2 + z_offx
    local view_r = t.center_x + z_w / 2 + z_offx
    local view_b = t.center_y - z_h / 2 + z_offy
    local view_t = t.center_y + z_h / 2 + z_offy

    M.setViewport2D(
        f.screen.l, f.screen.r, f.screen.b, f.screen.t,
        view_l, view_r, view_b, view_t
    )
    lstg.SetImageScale(1)
    current_view = M.view_modes.FIELD
end

--- Sets the viewport to 3D background (on playfield) mode.
function M.viewModeBackground3D()
    -- this hack lets us set the frame without repeating code
    M.viewModeField()

    current_view = M.view_modes.BG3D

    local v3d = M.view_bg3d

    lstg.SetPerspective(
        v3d.x, v3d.y, v3d.z,
        v3d.atx, v3d.aty, v3d.atz,
        v3d.upx, v3d.upy, v3d.upz,
        v3d.fovy,
        (M.field.r - M.field.l) / (M.field.t - M.field.b),
        v3d.z_near, v3d.z_far
    )
    lstg.SetFog(v3d.fog_near, v3d.fog_far, v3d.fog_color)
    lstg.SetImageScale(0.01)
end

--- Returns the current view mode ID.
function M.getViewMode()
    return current_view
end

function M.getViewModeStr()
    if current_view == M.view_modes.UI then
        return 'UI'
    elseif current_view == M.view_modes.FIELD then
        return 'FIELD'
    elseif current_view == M.view_modes.BG3D then
        return 'BG3D'
    else
        return 'UNKNOWN'
    end
end

--------------------------------------------------------------------------------
-- drawing helper functions

--- Renders objects in view modes with respect to their render groups.
---
--- Please exercise care when deciding when to use this method!  
--- This method should be called in gameplay situations. Otherwise,
--- `lstg.ObjRender()` should suffice!
function M.objRender()
    lstg.SetWorldFlag(M.render_group.FIELD)
    M.viewModeField()
    lstg.ObjRender()
    lstg.SetWorldFlag(M.render_group.UI)
    M.viewModeUI()
    lstg.ObjRender()
end

--- Renders the colliders of playfield objects in groups 1, 2, 4, and 5 (toggle with F8).
function M.drawCollider()
    lstg.SetWorldFlag(M.render_group.FIELD)
    M.viewModeField()
    lstg.DrawCollider()
end

-- module-specific white image
-- lstg.LoadImage('canvas:white', 'rt:white', 0, 0, 16, 16)

--- Fills the current view with a color (analogous to `lstg.RenderClear()`)
---@param color lstg.Color
function M.fillView(color)
    lstg.SetImageState('canvas:white', "", color)
    if current_view == M.view_modes.UI then
        lstg.RenderRect('canvas:white', 0, M.width, 0, M.height)
    elseif current_view == M.view_modes.FIELD then
        lstg.RenderRect('canvas:white', M.field.l, M.field.r, M.field.b, M.field.t)
    elseif current_view == M.view_modes.BG3D then
        M.viewModeField()
        lstg.RenderRect('canvas:white', M.field.l, M.field.r, M.field.b, M.field.t)
        M.viewModeBackground3D()
    else
        lstg.Log(3, 'foundation.canvas.fillView called on unknown view mode')
    end
end

--------------------------------------------------------------------------------
-- bounds helper functions

local lstg_boundcheck = lstg.BoundCheck

--- Ensures the correct world when calling `lstg.BoundCheck()`.
---@see _config for an option to alias `lstg.BoundCheck()` to this method.
function M.boundCheck()
    -- only the field should be bound-checked anyway
    lstg.SetWorldFlag(M.render_group.FIELD)
    lstg_boundcheck()
end

if config.alias_lstg_boundcheck then
    lstg.OldBoundCheck = lstg.BoundCheck
    lstg.BoundCheck = M.boundCheck
end

--- Please call this whenever you update the play area's bounds.
function M.updateBounds()
    lstg.SetBound(
        M.field.bound.l, M.field.bound.r,
        M.field.bound.b, M.field.bound.t
    )
end

--------------------------------------------------------------------------------
-- initialize on require

M.initCanvas()
M.updateBounds()

return M