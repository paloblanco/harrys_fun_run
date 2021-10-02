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
    onblocks={}, -- table of all the blocks that your y axis is on top of
    canjump=false,
    canwalljump=false,
}

function player:init()
    self.model = lovr.graphics.newModel('resources/javelina.obj')
    self:collide_with_blocks(LEVEL_BLOCKS)
end

function player:update(dt,blocks,others,xval, zval, mag, angle, runbutton, jumpbutton)
    self.dx=0
    self.dz=0
    self.xold=self.x
    self.yold=self.y
    self.zold=self.z
    if self.grounded then self.canjump=true end


    self.speed = 2*dt*mag
    runbutton=true
    if runbutton then self.speed = self.speed*1.75 end
    

    -- if (mag > 0) then self.angle = angle end

    self.dz = self.speed*zval
    self.dx = self.speed*xval

    if (mag > 0) then
        if self.grounded then 
            self.walktimer = (self.walktimer + dt)%1 
            if runbutton then self.walktimer = (self.walktimer + .5*dt)%1 end
        end
        self.angle = angle % (math.pi*2)
    else
        self.walktimer = 0
    end

    if (jumpbutton and self.canjump) then
        self.dy = 7*(1/60) -- can't use time elapsed here
        self.grounded = false
        self.canjump=false
        snd:play(1)
    elseif (jumpbutton and self.canwalljump) then
        self.dy = 5*(1/60) -- can't use time elapsed here
        self.grounded = false
        self.canwalljump=false
        snd:play(1)
    end

    self.canwalljump = false

    if not self.grounded then
        self.walktimer = .25
        if self.canjump==true then
            if self.dy < -.3*.25 then self.canjump = false end
        end
        if #self.walls > 0 and self.dy < 0 then
            self.canwalljump=true
            self.dx = self.dx*.5
            self.dz = self.dz*.5
            self.dy = math.max(self.dy,-3*dt)
        end
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
    -- set_color()
    lovr.graphics.translate(self.x,self.y,self.z)
    lovr.graphics.rotate(self.angle,0,1,0)
    
    --body and mouth
    lovr.graphics.setColor(1,1,1,1)
    self.model:draw(0,0.45+.04*math.sin(self.walktimer*12*math.pi),0,.75*1.25,0,0,1,0,1)
    --legs
    set_color(7)
    lovr.graphics.cube('fill',0.1*0 + .2*math.sin(self.walktimer*6*math.pi)*1,
                0.05 + .1*math.abs(math.sin(self.walktimer*6*math.pi)),
                0.1*1,
                .1,0,0,1,0)
    lovr.graphics.cube('fill',0-.1*0 + .2*math.sin(-self.walktimer*6*math.pi)*1,
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
