local SequenceSystem = require('lib.foundation.SequenceSystem')
local Object = require('lib.foundation.Object')

local M = {}

---@params cards boss.Card[]
function M.new(cards)
    local self = {}
    self.seqsys = SequenceSystem.new()
    return self
end

return M