block = require 'block'

local ground = make_new_block(-10,0,-10,10,1,10,3)
local b1 = make_new_block(0,1,3,3,2,5,6)
level = {
    ground,
    make_new_block(0,1,3,3,2,5,6),
    make_new_block(0,1,3,3,3,4,6),
    make_new_block(0,2,2,3,4,3,6),
    make_new_block(-4,3,1,3,5,2,6),
}

return level