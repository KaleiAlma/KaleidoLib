local SequenceSystem = require('lib.foundation.SequenceSystem')
local Object = require('lib.foundation.Object')
local GameManager = require "game.GameManager"
local EventDispatcher = require "lib.foundation.EventDispatcher"

---@class game.BossSequence
---@field seqsys foundation.SequenceSystem
local M = Object.createClass()

GameManager.sysevents.onCardPrepare = EventDispatcher.new()
GameManager.sysevents.onCardStart = EventDispatcher.new()
GameManager.sysevents.onCardEnd = EventDispatcher.new()

---@params cards boss.Card[]
function M.new(cards)
    local self = Object.newInst(M)
    self.context = {}
    self.seqsys = SequenceSystem.new(function(seqsys)
    
    end)
    for k, card in ipairs(cards) do
        self.seqsys:add(card.sequence)
    end
    return self
end

---@param self game.BossSequence
function M:frame()
    self.seqsys:update(self)
end

return M