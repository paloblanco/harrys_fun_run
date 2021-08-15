thing = require 'thing'

-->8 Camera
camera = thing:new{
    x=0,
    y=2,
    z=3,
    angle=0,
    target=nil,
    dist=3
}

function camera:setup(target)
    self.target=target
    self.x=self.target.x
    self.y=self.target.y+2
    self.z=self.target.z+3
    self.dist = 3 -- floor distance from ahrry to cam
    self.angle=0    
end

function camera:reset()
    local camfrom = lovr.math.vec3(self.x,self.y,self.z)
    local camto = lovr.math.vec3(self.target.x, self.target.y+1, self.target.z)
    CAMUP = lovr.math.vec3(0,1,0)

    cammat = lovr.math.mat4()
    cammat:lookAt(camfrom,camto,CAMUP)
    lovr.graphics.setViewPose(1,cammat,true)
    shader:send('lovrLightDirection', camto - camfrom )
end

function camera:update(dt)
    local angt = (p1.angle - 0.5*math.pi) % (math.pi*2)

    if (CAMLEFT) then self.angle = self.angle + 1*dt end
    if (CAMRIGHT) then self.angle = self.angle - 1*dt end

    local angt1 = angt-self.angle
    local angbest

    if angt1 < math.pi and angt1 >= 0 then 
        angbest = angt1
    elseif angt1 >= math.pi then
        angbest = angt1-2*math.pi
    elseif angt1 < 0 and angt1 > -math.pi then
        angbest = angt1
    else
        angbest = 2*math.pi + angt1
    end
    
    if (DOWNKEY) then angbest = 0 end

    if (not CAMLEFT and not CAMRIGHT) then self.angle = self.angle + (angbest)*dt end
    self.angle = self.angle % (2*math.pi)

    self.x = self.target.x + 3*math.sin(self.angle)
    self.z = self.target.z + 3*math.cos(-self.angle)
    self.y = self.y + (self.target.y + 2 - self.y)/4

    self:reset()
end

function camera:draw()
end


return camera