
local M = {}

M.resdesc = {}

for _, v in ipairs(lstg.FileManager.EnumFiles('data/res/sfx', 'wav')) do
    table.insert(M.resdesc, { name = string.sub(v[1], 14, -5), type = 'snd', args = {string.sub(v[1], 10, -1)}})
end

return M