
local M = {}

M.resdesc = {
    { name = 'player:aura', type = 'imgfile', args = {'player/aura.png'} },
    { name = 'player:graze', type = 'ps', args = {'player/graze.psi', 'white'}},
}

function M.postLoad()
    lstg.SetImageScale('player:aura', 0.5)
end

return M