local SequenceSystem = require('lib.foundation.SequenceSystem')
local Object = require('lib.foundation.Object')

---@class game.BossSequence
---@field seqsys foundation.SequenceSystem
local M = Object.createClass()

---@params cards boss.Card[]
function M.new(cards)
    local self = Object.newInst(M)
    self.seqsys = SequenceSystem.new()
    self.context = {}
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