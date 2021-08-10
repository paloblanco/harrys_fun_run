-->8 imports
shader = require 'shader'
thing = require 'thing'

-->8 Convenience functions
color_table = {
    0x000000,-- (0, 0, 0) black
    0x1d2b53,-- (29, 43, 83) dark-blue
    0x7e2553,-- (126, 37, 83) dark-purple
    0x008751,-- (0, 135, 81) dark-green
    0xab5236,-- (171, 82, 54) brown
    0x5f574f,-- (95, 87, 79) dark-gray
    0xc2c3c7,-- (194, 195, 199) light-gray
    0xfff1e8,-- (255, 241, 232) white
    0xff004d,-- (255, 0, 77) red
    0xffa300,-- (255, 163, 0) orange
    0xffec27,-- (255, 236, 39) yellow
    0x00e436,-- (0, 228, 54) green
    0x29adff,-- (41, 173, 255) blue
    0x83769c,-- (131, 118, 156) indigo
    0xff77a8,-- (255, 119, 168) pink
    0xffccaa,-- (255, 204, 170) peach
}
function setColor(ix)
    -- sets color, pico8 style
    lovr.graphics.setColor(color_table[ix+1])
end

function draw_cam_info()
    lovr.graphics.print('Hello World',0,1.7,-3,.25)
    for ix,val in pairs({lovr.graphics.getViewPose(1)}) do
        lovr.graphics.print(val,0,1.7-.5*ix,-3,.5)    
    end
end

-->8 Player
function input_init()
    function lovr.keypressed(key)
        if key=='right' then rightkey = true end
        if key=='left' then leftkey = true end
        if key=='up' then upkey = true end
        if key=='down' then downkey = true end
    end
    function lovr.keyreleased(key)
        if key=='right' then rightkey = false end
        if key=='left' then leftkey = false end
        if key=='up' then upkey = false end
        if key=='down' then downkey = false end
    end
end

function input_update()
end

player = thing:new{
    x=0,
    y=1,
    z=9,
    angle=0,
    dx=0,
    dy=0,
    dz=0,
    wakltimer=0
}

function player:update(dt)
    self.dx=0
    self.dz=0

    if upkey then
        self.dz = -2*dt
    elseif downkey then
        self.dz = 2*dt
    end

    if rightkey then
        self.dx = 2*dt
    elseif leftkey then
        self.dx = -2*dt
    end

    if ((self.dx ~= 0) and (self.dz ~= 0)) then
        self.dx = self.dx * 0.707
        self.dz = self.dz * 0.707
    end

    if (upkey or downkey or rightkey or leftkey) then
        self.walktimer = (self.walktimer + dt)%1
        self.angle = math.atan2(-self.dz/dt,self.dx/dt)
    else
        self.walktimer = 0
    end

    self.z = self.z + self.dz
    self.x = self.x + self.dx
end

function player:draw()
    --body and mouth
    setColor(12)
    lovr.graphics.cube('fill',self.x,self.y+.45+.05*math.sin(self.walktimer*12*math.pi),self.z,.5,self.angle,0,1,0)
    setColor(0)
    lovr.graphics.box('fill',self.x+.25*math.cos(self.angle),
                    self.y+.45+.05*math.sin(self.walktimer*12*math.pi), 
                    self.z-.25*math.sin(self.angle),
                    .05,.25,.35,self.angle,0,1,0)
    --legs
    setColor(7)
    lovr.graphics.cube('fill',self.x+.1*math.sin(self.angle) + .3*math.sin(self.walktimer*6*math.pi)*math.cos(self.angle),
                self.y+.05 + .1*math.abs(math.sin(self.walktimer*6*math.pi)),
                self.z+.1*math.cos(self.angle) -.3*math.sin(self.walktimer*6*math.pi)*math.sin(self.angle),
                .1,self.angle,0,1,0)
    lovr.graphics.cube('fill',self.x-.1*math.sin(self.angle) + .3*math.sin(-self.walktimer*6*math.pi)*math.cos(self.angle),
                self.y+.05+ .1*math.abs(math.sin(self.walktimer*6*math.pi)),
                self.z-.1*math.cos(self.angle) -.3*math.sin(-self.walktimer*6*math.pi)*math.sin(self.angle),
                .1,self.angle,0,1,0)
    
    --arms
    lovr.graphics.cube('fill',self.x+.3*math.sin(self.angle),self.y+.45+.05*math.sin(self.walktimer*12*math.pi),
                self.z+.3*math.cos(self.angle),.1,self.angle,0,1,0)
    lovr.graphics.cube('fill',self.x-.3*math.sin(self.angle),self.y+.45+.05*math.sin(self.walktimer*12*math.pi),
                self.z-.3*math.cos(self.angle),.1,self.angle,0,1,0)
end

-->8 Level
function level_init()
    ground={}
    ground.x0=-10
    ground.y0=0
    ground.z0=-10
    ground.x1=10
    ground.y1=1
    ground.z1=10

    ground.xmid = (ground.x0+ground.x1)/2
    ground.ymid = (ground.y0+ground.y1)/2
    ground.zmid = (ground.z0+ground.z1)/2
    ground.dx = math.abs(ground.x0-ground.x1)
    ground.dy = math.abs(ground.y0-ground.y1)
    ground.dz = math.abs(ground.z0-ground.z1)
end

function level_update()
end

function level_draw()
    setColor(3)
    lovr.graphics.box('fill',ground.xmid,ground.ymid,ground.zmid,ground.dx,ground.dy,ground.dz,0,0,1,0)
end

-->8 Camera
function cam_init(target)
    cam_target=target
    camx=cam_target.x
    camy=cam_target.y+2
    camz=cam_target.z+3
    camangle=-math.pi*0.125
    function resetCam()
        lovr.graphics.setViewPose(1,camx,camy,camz,camangle,1,0,0)
    end
    resetCam()
end

function cam_update()
    camx = camx + (cam_target.x-camx)/5
    camy = camy + (cam_target.y+2-camy)/5
    camz = camz + (cam_target.z+3-camz)/5

    resetCam()
end

function cam_draw()
end

-->8 Game Loop
function lovr.load()
    input_init()
    p1 = player:new()
    level_init()
    cam_init(p1)
    lovr.graphics.setShader(shader)
end

function lovr.update(dt)
    input_update()
    -- player_update(dt)
    p1:update(dt)
    level_update(dt)
    cam_update(dt)
end

function lovr.draw()
    lovr.graphics.setBackgroundColor(color_table[2])
    -- player_draw()
    p1:draw()
    level_draw()
    cam_draw()
end