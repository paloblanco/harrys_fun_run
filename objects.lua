thing = require 'thing'

--> objects
coin = actor:new()

function coin:init()
    self:collide_with_blocks(LEVEL_BLOCKS)
end

function coin:bump_me()
    self.killme=true
    self:kill_me()
    COINCOUNT = COINCOUNT+1
    snd:play(2)
end

function coin:draw()
    set_color(9)
    lovr.graphics.translate(self.x,self.y+.5,self.z)
    lovr.graphics.rotate(math.pi/2,0,0,1)
    lovr.graphics.cylinder(0,0,0,0.05,2*math.pi*WORLDTIME,1,0,0,.25,.25,true,6)
    lovr.graphics.origin()
    self:draw_shadow()
end

function make_coin(x,y,z)
    add(ACTOR_LIST,coin:new{x=x,y=y,z=z})
end



return coin