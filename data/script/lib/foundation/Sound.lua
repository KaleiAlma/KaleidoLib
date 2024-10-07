local sfx_rand = require('lib.foundation.rand')

---@class foundation.sound
local M = {}

---@param name string
---@param pitch_range number
---@param vol number
---@param pan number
function M.playSfxRandPitch(name, pitch_range, vol, pan)
    lstg.SetSESpeed(name, 2 ^ sfx_rand:number(-pitch_range, pitch_range))
    lstg.PlaySound(name, vol, pan)
end

---@param name string
---@param base_pitch number
---@param pitch_range number
---@param vol number
---@param pan number
function M.playSfxRandPitchShift(name, base_pitch, pitch_range, vol, pan)
    lstg.SetSESpeed(name, 2 ^ sfx_rand:number(-pitch_range, pitch_range) * base_pitch)
    lstg.PlaySound(name, vol, pan)
end


return M