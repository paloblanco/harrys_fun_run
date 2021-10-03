thing = require 'thing'
require 'convenience'

-->8 Camera
camera = thing:new{
    x=0,
    y=2,
    z=3,
    angle=0,
    target=nil,
    dist=3
}

function camera:init()
    self.pixwidth = lovr.graphics.getWidth()   -- Window pixel width and height
    self.pixheight = lovr.graphics.getHeight()
    self.aspect = self.pixwidth/self.pixheight           -- Window aspect ratio
    self.height = 2                            -- Window width and height in screen coordinates
    self.width = self.aspect*2                      -- ( We will pick the coordinate system [[-1,1],[-aspect,aspect]] )
    self.margin = 0.1                       -- Space between top of screen and top of grid
    self.guidepth = 0.5
    
end

function camera:setup(target)
    self.target=target
    self.x=self.target.x
    self.y=self.target.y+2
    self.z=self.target.z+3
    self.dist = 3 -- floor distance from ahrry to cam
    self.angle=0
    self.matrix=0
    
end

function camera:reset()
    local camfrom = lovr.math.vec3(self.x,self.y,self.z)
    local camto = lovr.math.vec3(self.target.x, self.target.y+1, self.target.z)
    local camup = lovr.math.vec3(0,1,0)

    local cammat = lovr.math.mat4()
    cammat:lookAt(camfrom,camto,camup)  
    local camme = lovr.math.mat4()
    camme:target(camfrom,camto,camup)
    lovr.graphics.setViewPose(1,cammat,true)
    shader:send('lovrLightDirection', camto - camfrom )
    self.matrix = camme
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

    if self.target.dx==0 and self.target.dz==0 then
        -- self.angle = self.angle + (0.5*sign(angbest))*dt 
        damp = 0.25
    else
        damp=1
    end
    if (not CAMLEFT and not CAMRIGHT) then 
        self.angle = self.angle + (damp*angbest)*dt 
    end
    self.angle = self.angle % (2*math.pi)

    self.x = self.target.x + 3*math.sin(self.angle)
    self.z = self.target.z + 3*math.cos(-self.angle)
    self.y = self.y + (self.target.y + 2 - self.y)/4

    self:reset()
end

function camera:draw()
end

function camera:draw_text(text,x,y,size)
    set_color(7)
    lovr.graphics.setFont()
    lovr.graphics.transform(self.matrix)
    
    lovr.graphics.print(text,x,y,-self.guidepth,size,0,0,1,0)
    lovr.graphics.origin()
end

function camera:draw_bar(number)
    if number < 20 then
        set_color(8)
    else
        set_color(11)
    end
    lovr.graphics.transform(self.matrix)
    local length = .2*(number/100)
    local mid = length/2
    lovr.graphics.box('fill',0.3 + mid,.3,-self.guidepth,length,.05,.025)
    lovr.graphics.origin()
    lovr.graphics.setColor(1,1,1,1)
end


return camera