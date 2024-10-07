
---@enum foundation.collision_group
local M = {
    GHOST = 0,
    ENEMY_BULLET = 1,
    ENEMY = 2,
    PLAYER_BULLET = 5,
    PLAYER = 4,
    -- INDES = 5,
    ITEM = 6,
    -- NONTJT = 7,
    SPELL = 8,

    NUM_OF_GROUP = 16,
}

function M.doCollision()
    lstg.CollisionCheck(M.PLAYER, M.ENEMY_BULLET)
    lstg.CollisionCheck(M.PLAYER, M.ENEMY)
    -- lstg.CollisionCheck(M.PLAYER, M.INDES)
    lstg.CollisionCheck(M.ENEMY,  M.PLAYER_BULLET)
    -- lstg.CollisionCheck(M.NONTJT, M.PLAYER_BULLET)
    lstg.CollisionCheck(M.ITEM,   M.PLAYER)
    lstg.CollisionCheck(M.ENEMY, M.SPELL)
    -- lstg.CollisionCheck(M.SPELL,  M.NONTJT)
    lstg.CollisionCheck(M.SPELL,  M.ENEMY_BULLET)
    -- lstg.CollisionCheck(M.SPELL,  M.INDES)
end

return M