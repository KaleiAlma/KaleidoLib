local random = require('random')


--- Auxillary randomness, useful for anything not gameplay-critical
local rand = random.xoroshiro128p()
local seedrand = random.splitmix64()
seedrand:seed(os.time())
rand:seed(seedrand:integer())

return rand