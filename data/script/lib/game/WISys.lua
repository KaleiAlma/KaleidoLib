---@class game.wisys Walk Image Systems
local M = {}

---@class game.WalkImageSystem
---@field new fun(obj: game.Object, ...: any): game.WalkImageSystemInst

---@class game.WalkImageSystemInst
---@field frame fun(self, dx: number?)
---@field render fun(self)

---@class game.wisys.player: game.WalkImageSystem
M.player = {}

--- Assumes player images are loaded as `imggrp`.
---@class game.wisys.player.imgs
---@field prefix string
---@field idle_start integer
---@field idle_end integer
---@field toleft_start integer
---@field toleft_end integer
---@field left_start integer
---@field left_end integer
---@field toright_start integer
---@field toright_end integer
---@field right_start integer
---@field right_end integer

--- Prepares an images table for a standard 8x3 player sheet.
---@param prefix any
---@return game.wisys.player.imgs
function M.player.imgs8x3(prefix)
    ---@type game.wisys.player.imgs
    local imgs = {
        prefix = prefix,
        idle_start = 1,
        idle_end = 8,
        toleft_start = 9,
        toleft_end = 12,
        left_start = 13,
        left_end = 16,
        toright_start = 17,
        toright_end = 21,
        right_start = 22,
        right_end = 24,
    }

    return imgs
end

---@param obj game.player.Player.obj
---@param imgs game.wisys.player.imgs
---@param intv integer? defaults to 8
---@return game.wisys.player.inst
function M.player.new(obj, imgs, intv)
    ---@class game.wisys.player.inst: game.WalkImageSystemInst
    local self = {}

    self.obj = obj
    self.imgs = imgs
    self.intv = intv or 8
    self.lr = 1

    self.ani = 0
    self.nextani = self.intv

    ---@param dx number?
    function self:frame(dx)
        local obj = self.obj
        local imgs = self.imgs
        if dx == nil then
            dx = obj.dx
        end
        if dx > 0.5 then
            dx = 1
        elseif dx < -0.5 then
            dx = -1
        else
            dx = 0
        end
        self.lr = math.clamp(
            self.lr + dx,
            imgs.toleft_start - imgs.toleft_end - 3,
            imgs.toright_end - imgs.toright_start + 3
        )
        if self.lr == 0 then
            self.lr = self.lr + dx
        end
        if dx == 0 and math.abs(self.lr) > 1 then
            self.lr = self.lr - math.sign(self.lr)
        end

        self.nextani = self.nextani - 1
        if self.nextani == 0 then
            self.nextani = self.intv
            self.ani = self.ani + 1
        end

        local img = 1
        if self.lr == imgs.toleft_start - imgs.toleft_end - 3 then
            img = self.ani % (imgs.left_end - imgs.left_start + 1) + imgs.left_start
        elseif self.lr == imgs.toright_end - imgs.toright_start + 3 then
            img = self.ani % (imgs.right_end - imgs.right_start + 1) + imgs.right_start
        elseif self.lr < -1 then
            img = imgs.toleft_start - self.lr - 2
        elseif self.lr > 1 then
            img = imgs.toright_start + self.lr - 2
        else
            img = self.ani % (imgs.idle_end - imgs.idle_start + 1) + imgs.idle_start
        end
        obj.img = imgs.prefix .. img
    end

    function self:render()
        local obj = self.obj
        if obj.protect and obj.protect % 8 > 3 then
            local a = obj._a
            obj._a = obj._a / 2
            lstg.DefaultRenderFunc(obj)
            obj._a = a
            return
        end
        lstg.DefaultRenderFunc(obj)
    end

    return self
end


---@class game.wisys.fairy_anim.imgs
---@field [1] string head
---@field [2] string arm
---@field [3] string body
---@field [4] string wing
---@field [5] string legs

---@class game.wisys.fairy_anim: game.WalkImageSystem
M.fairy_anim = {}

---@param obj game.Enemy
---@param imgs game.wisys.fairy_anim.imgs
---@return game.wisys.fairy_anim.inst
function M.fairy_anim.new(obj, imgs)
    ---@class game.wisys.fairy_anim.inst: game.WalkImageSystemInst
    local self = {}

    self.obj = obj
    self.imgs = imgs

    obj.a = 30
    obj.b = 30

    self.head_rot = 0
    self.arml_rot = 0
    self.armr_rot = 0
    self.wingl_rot = 0
    self.wingr_rot = 0
    self.legs_rot = 0

    ---@param dx number?
    function self:frame(dx)
        -- local obj = self.obj
        if dx == nil then
            dx = obj.dx
        end
        obj.rot = math.lerp_decel(0.1, obj.rot, -math.clamp(dx, -1.2, 1.2) * 10)
        self.head_rot = math.lerp_decel(0.1, self.head_rot, math.clamp(dx, -1, 1) * 2)
        self.arml_rot = math.lerp_decel(0.1, self.arml_rot, -math.clamp(dx, -1, 1) * 2 * (2 - math.sign(dx)))
        self.armr_rot = math.lerp_decel(0.1, self.armr_rot, -math.clamp(dx, -1, 1) * 2 * (2 + math.sign(dx)))
        self.wingl_rot = math.lerp_decel(0.1, self.wingl_rot, -math.clamp(dx, -1, 1) * 0.5 * (3 - math.sign(dx)))
        self.wingr_rot = math.lerp_decel(0.1, self.wingr_rot, -math.clamp(dx, -1, 1) * 0.5 * (3 + math.sign(dx)))
        self.legs_rot = math.lerp_decel(0.1, self.legs_rot, -math.clamp(dx, -1, 1) * 5)
    end

    function self:render()
        -- local obj = self.obj
        -- local imgs = self.imgs
        local col = lstg.Color(0xFFFFFFFF)
        if obj.protect and obj.protect % 8 > 3 then
            col = lstg.Color(0xFF999999)
        end
        if obj.dmgt and obj.dmgt > 0 and obj.timer % 8 > 3 then
            col = lstg.Color(0xFFFF9999)
        end

        for _, img in ipairs(imgs) do
            lstg.SetImageState(img, '', col)
        end

        local x, y, rot = obj.x, obj.y, obj.rot
        local cos, sin = lstg.cos(rot), lstg.sin(rot)
        local timer = obj.timer
        local h, v = obj.hscale, obj.vscale

        lstg.Render( -- left wing
            imgs[4],
            x - (cos * 8 - sin * 3.5) * h,
            y + (cos * 3.5 - sin * 8) * v,
            rot + self.wingl_rot - lstg.sin(timer * 10) * 24,
            -h, v
        )
        lstg.Render( -- right wing
            imgs[4],
            x + (cos * 8 - sin * 3.5) * h,
            y + (cos * 3.5 + sin * 8) * v,
            rot + self.wingr_rot + lstg.sin(timer * 10) * 24,
            h, v
        )
        lstg.Render( -- legs
            imgs[5],
            x + sin * 13 * h,
            y - cos * 13 * v,
            rot + self.legs_rot - lstg.sin(timer * 3) * 2,
            h, v
        )
        lstg.Render( -- left arm
            imgs[2],
            x - (cos * 3.4 + sin * 3.6) * h,
            y + (cos * 3.6 + sin * 3.4) * v,
            rot + self.arml_rot - lstg.sin(timer * 4) * 8 - 7,
            -h, v
        )
        lstg.Render( -- right arm
            imgs[2],
            x + (cos * 3.4 - sin * 3.6) * h,
            y + (cos * 3.6 + sin * 3.4) * v,
            rot + self.armr_rot + lstg.sin(timer * 4) * 8 + 7,
            h, v
        )
        lstg.Render( -- body
            imgs[3],
            x, y,
            rot - lstg.sin(timer * 2) * 2,
            h, v
        )
        lstg.Render( -- head
            imgs[1],
            x - sin * 3 * h,
            y + cos * 3 * v,
            rot + self.head_rot,
            h, v
        )
    end

    return self
end

---@class game.wisys.wheel_ghost: game.WalkImageSystem
M.wheel_ghost = {}

---@param obj game.Enemy
---@param type integer
---@return game.wisys.wheel_ghost.inst
function M.wheel_ghost.new(obj, type)
    ---@class game.wisys.wheel_ghost.inst: game.WalkImageSystemInst
    local self = {}

    self.obj = obj
    self.type = type

    obj.omiga = 1
    obj.a = 24
    obj.b = 24

    ---@param dx number?
    function self:frame(dx)
    end

    function self:render()
        -- local obj = self.obj
        -- local imgs = self.imgs
        local col = lstg.Color(0xFFFFFFFF)
        if obj.protect and obj.protect % 8 > 3 then
            col = lstg.Color(0xFF999999)
        end
        if obj.dmgt and obj.dmgt > 0 and obj.timer % 8 > 3 then
            col = lstg.Color(0xFFFF9999)
        end

        local img1 = 'enemy:yinyang' .. self.type
        local img2 = 'enemy:yinyang_aura' .. self.type

        lstg.SetImageState(img1, '', col)
        lstg.SetImageState(img2, 'mul+add', col * lstg.Color(0x99FFFFFF))

        local x, y, rot = obj.x, obj.y, obj.rot
        local cos, sin = lstg.cos(rot), lstg.sin(rot)
        local timer = obj.timer
        local h, v = obj.hscale, obj.vscale

        lstg.Render( -- background aura
            img2, x, y, -rot, h, v
        )

        lstg.SetImageState(img2, '', col)

        lstg.Render( -- foreground aura
            img2, x, y, rot, h * 0.7, v * 0.7
        )
        lstg.Render( -- yinyang
            img1, x, y, 0, h * 0.7, v * 0.7
        )
    end

    return self
end

---@class game.wisys.undefined: game.WalkImageSystem
M.undefined = {}

---@param obj game.Enemy
---@return game.wisys.undefined.inst
function M.undefined.new(obj)
    ---@class game.wisys.undefined.inst: game.WalkImageSystemInst
    local self = {}

    self.obj = obj

    obj.omiga = 0.8

    ---@param dx number?
    function self:frame(dx)
    end

    function self:render()
        -- local obj = self.obj
        -- local imgs = self.imgs
        local col = lstg.Color(0x90FFFFFF)
        if obj.protect and obj.protect % 8 > 3 then
            col = lstg.Color(0x90999999)
        end
        if obj.dmgt and obj.dmgt > 0 and obj.timer % 8 > 3 then
            col = lstg.Color(0x90FF9999)
        end

        local img = 'enemy:undefined'

        lstg.SetImageState(img, 'mul+add', col)

        local x, y, rot = obj.x, obj.y, obj.rot
        local cos, sin = lstg.cos(rot), lstg.sin(rot)
        local timer = obj.timer
        local h, v = obj.hscale, obj.vscale

        lstg.Render(
            img, x, y, -rot, h * 0.96
        )
        lstg.Render(
            img, x, y, rot, h, v
        )
    end

    return self
end

return M