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
function set_color(ix)
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
    wakltimer=0,
    grounded=0,
    onblocks={} -- table of all the blocks that your y axis is on top of
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

function player:collide_with_blocks(blocktable)
    for i,b in pairs(blocktable) do
        if self.dx > 0 then
            -- if true
        end
    end
end

function player:draw()
    --body and mouth
    set_color(12)
    lovr.graphics.cube('fill',self.x,self.y+.45+.05*math.sin(self.walktimer*12*math.pi),self.z,.5,self.angle,0,1,0)
    set_color(0)
    lovr.graphics.box('fill',self.x+.25*math.cos(self.angle),
                    self.y+.45+.05*math.sin(self.walktimer*12*math.pi), 
                    self.z-.25*math.sin(self.angle),
                    .05,.25,.35,self.angle,0,1,0)
    --legs
    set_color(7)
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

block = thing:new{
    x0=-1,
    y0=-1,
    z0=-1,
    x1=1,
    y1=1,
    z1=1,
    color=3
}

function block:init()
    self.xmid = (self.x0+self.x1)/2
    self.ymid = (self.y0+self.y1)/2
    self.zmid = (self.z0+self.z1)/2
    self.dx = math.abs(self.x0-self.x1)
    self.dy = math.abs(self.y0-self.y1)
    self.dz = math.abs(self.z0-self.z1)
end

function make_new_block(x0,y0,z0,x1,y1,z1,c)
    c = c or 3
    local b = block:new{
        x0=x0,
        y0=y0,
        z0=z0,
        x1=x1,
        y1=y1,
        z1=z1,
        color=c
    }
    return b
end

function level_init()
    ground = make_new_block(-10,0,-10,10,1,10,3)
    level_blocks = {
        ground
    }
end

function level_update()
end

function level_draw()
    for i,b in pairs(level_blocks) do
        set_color(b.color)
        lovr.graphics.box('fill',b.xmid,b.ymid,b.zmid,b.dx,b.dy,b.dz,0,0,1,0)
    end
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