
---@class game.card
local M = {}

---@param name string? card name, if nil or '' the card is a nonspell
---@param t1 number invulnerability time (in seconds)
---@param t2 number resistance time (in seconds)
---@param t3 number total time (in seconds)
---@param hp number
---@param drops table
---@param bomb_immune boolean
---@return game.card.Card
function M.new(name, t1, t2, t3, hp, drops, bomb_immune)
    ---@class game.card.Card
    ---@field before    fun(self: game.boss.Boss.obj)?
    ---@field init      fun(self: game.boss.Boss.obj)?
    ---@field frame     fun(self: game.boss.Boss.obj)?
    ---@field render    fun(self: game.boss.Boss.obj)?
    ---@field beforedel fun(self: game.boss.Boss.obj)?
    ---@field del       fun(self: game.boss.Boss.obj)?
    ---@field after     fun(self: game.boss.Boss.obj)?
    local self = {}

    if not name then
        name = ''
    end
    self.name = name

    assert(
        t1 <= t2 and t2 <= t3,
        't1 <= t2 <= t3 must be true\n' ..
        't1 is invulnerability time, t2 is resistance time, and t3 is total time\n' ..
        'note that invulnerability/resistance times do not add to total time'
    )

    self.t1 = math.floor(t1 * 60)
    self.t2 = math.floor(t2 * 60)
    self.t3 = math.floor(t3 * 60)
    self.hp = hp
    self.is_sc = name ~= ''
    self.drops = drops
    self.bomb_immune = bomb_immune
    self.is_pattern = true

    return self
end


return M