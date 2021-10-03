thing = require 'thing'

block = thing:new{
    x0=-1,
    y0=-1,
    z0=-1,
    x1=1,
    y1=1,
    z1=1,
    color=3,
    falling = false,
    vely=0,
    canfall=true
}

function block:init()
    self.xmid = (self.x0+self.x1)/2
    self.ymid = (self.y0+self.y1)/2
    self.zmid = (self.z0+self.z1)/2
    self.xmid0,self.ymid0,self.zmid0 = self.xmid,self.ymid,self.zmid
    self.dx = math.abs(self.x0-self.x1)
    self.dy = math.abs(self.y0-self.y1)
    self.dz = math.abs(self.z0-self.z1)
end

function block:draw()
    set_color(self.color)
    lovr.graphics.box('fill',self.xmid,self.ymid,self.zmid,self.dx,self.dy,self.dz,0,0,1,0)
    lovr.graphics.setColor(1,1,1,1)
    lovr.graphics.box('line',self.xmid,self.ymid,self.zmid,self.dx,self.dy,self.dz,0,0,1,0)
end

function block:start_fall()
    self.falling=true
    add(BLOCKS_UPDATE,self)
end

function block:kill_me()
    del(BLOCKS_UPDATE, self)
    del(LEVEL_BLOCKS, self)
end

function block:update(dt)
    self.vely = self.vely + -0.015*dt
    self.y0 = self.y0 + self.vely
    self.y1 = self.y1 + self.vely
    self.ymid0 = self.ymid0 + self.vely
    self.ymid = self.ymid0 - 0.05 + 0.1*rnd()
    if self.y1 < -10 then 
        self:kill_me() 
    end
end

function make_new_block(x0,y0,z0,x1,y1,z1,c,canfall)
    c = c or 3
    canfall = canfall or true
    local b = block:new{
        x0=x0,
        y0=y0,
        z0=z0,
        x1=x1,
        y1=y1,
        z1=z1,
        color=c,
        canfall=canfall
    }
    return b
end

return block