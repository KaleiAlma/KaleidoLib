local vars = require('lib.game.vars')

--- Used for gameplay randomness, so that replays sync properly
local rand = require('random').pcg64_fast()
rand:seed(vars.stage.rng_seed)

return rand