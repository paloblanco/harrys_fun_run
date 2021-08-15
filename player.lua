require 'convenience'
actor = require 'actor'

player = actor:new{
    x=0,
    y=1.5,
    z=9,
    angle = math.pi*.5,
    xold=0,
    yold=1.5,
    zold=9,
    angle=0,
    dx=0,
    dy=0,
    dz=0,
    size=.5,
    wakltimer=0,
    grounded=false,
    onblocks={} -- table of all the blocks that your y axis is on top of
}

function player:update(dt,blocks,others)
    self.dx=0
    self.dz=0
    self.xold=self.x
    self.yold=self.y
    self.zold=self.z
    self.speed = 0

    if UPKEY then
        self.dz =self.dz -1 * math.cos(-camangle)
        self.dx =self.dx -1 * math.sin(camangle)
        self.speed = 2*dt
    elseif DOWNKEY then
        self.dz =self.dz+ 1 * math.cos(-camangle)
        self.dx =self.dx+ 1 * math.sin(camangle)
        self.speed = 2*dt
    end

    if RIGHTKEY then
        self.dx =self.dx+ 1 * math.cos(-camangle)
        self.dz =self.dz+ -1 * math.sin(camangle)
        self.speed = 2*dt
    elseif LEFTKEY then
        self.dx =self.dx+ -1 * math.cos(-camangle)
        self.dz =self.dz+ 1 * math.sin(camangle)
        self.speed = 2*dt
    end

    if XKEY then self.speed = self.speed*1.75 end

    if (self.speed > 0) then self.angle = math.atan2(-self.dz,self.dx) end
    self.dz = -self.speed*math.sin(self.angle)
    self.dx = self.speed*math.cos(self.angle)

    if (UPKEY or DOWNKEY or RIGHTKEY or LEFTKEY) then
        if self.grounded then 
            self.walktimer = (self.walktimer + dt)%1 
            if XKEY then self.walktimer = (self.walktimer + .5*dt)%1 end
        end
        self.angle = math.atan2(-self.dz,self.dx) % (math.pi*2)
    else
        self.walktimer = 0
    end

    if (ZKEY and self.grounded) then
        self.dy = 7*(1/60) -- can't use time elapsed here
        self.grounded = false
    end

    if not self.grounded then
        self.walktimer = .25
    end


    -- move!
    self.z = self.z + self.dz
    self.x = self.x + self.dx
    
    self.grounded=false
    self.dy = self.dy - .3*dt
    self.y = self.y + self.dy

    --collide!
    self:collide_with_blocks(blocks)
    self:bump_others(others)
end


function player:draw()
    --set transforms
    lovr.graphics.translate(self.x,self.y,self.z)
    lovr.graphics.rotate(self.angle,0,1,0)
    
    --body and mouth
    set_color(12)
    lovr.graphics.cube('fill',0,0.45+.05*math.sin(self.walktimer*12*math.pi),0,.5,0,0,1,0)
    set_color(0)
    lovr.graphics.box('fill',0.25*1,
                    0.45+.05*math.sin(self.walktimer*12*math.pi), 
                    0,
                    .05,.25,.35,0,0,1,0)
    -- teeth
    set_color(7)
    lovr.graphics.cube('fill',0.27,
                0.45+0.125-.025+.05*math.sin(self.walktimer*12*math.pi), 
                0.1,
                0.05,0,0,1,0)
    lovr.graphics.cube('fill',0.27,
                0.45+0.125-.025+.05*math.sin(self.walktimer*12*math.pi), 
                -0.12,
                0.05,0,0,1,0)
    lovr.graphics.cube('fill',0.27,
                0.45+0.125-.025+.05*math.sin(self.walktimer*12*math.pi), 
                0.0,
                0.05,0,0,1,0)
    lovr.graphics.cube('fill',0.27,
                0.45-0.1-.0+.05*math.sin(self.walktimer*12*math.pi), 
                0.05,
                0.05,0,0,1,0)
    lovr.graphics.cube('fill',0.27,
                0.45-0.1-.0+.05*math.sin(self.walktimer*12*math.pi), 
                -0.1,
                0.05,0,0,1,0)
    --legs
    set_color(7)
    lovr.graphics.cube('fill',0.1*0 + .3*math.sin(self.walktimer*6*math.pi)*1,
                0.05 + .1*math.abs(math.sin(self.walktimer*6*math.pi)),
                0.1*1,
                .1,0,0,1,0)
    lovr.graphics.cube('fill',0-.1*0 + .3*math.sin(-self.walktimer*6*math.pi)*1,
                0+.05+ .1*math.abs(math.sin(self.walktimer*6*math.pi)),
                0-.1*1,
                .1,0,0,1,0)
    
    --arms
    lovr.graphics.cube('fill',0+.3*0,0+.45+.05*math.sin(self.walktimer*12*math.pi),
                0+.3,.1,0,0,1,0)
    lovr.graphics.cube('fill',0-.3*0,0+.45+.05*math.sin(self.walktimer*12*math.pi),
                0-.3,.1,0,0,1,0)

    --shadow
    -- lovr.graphics.pop()
    lovr.graphics.origin()
    self:draw_shadow()
end

return player
