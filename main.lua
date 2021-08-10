-->8 imports
shader = require 'shader'

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

function player_init()
    p1={}
    p1.x=0
    p1.y=1
    p1.z=9
    p1.angle=0
    p1.dx,p1.dy,p1.dz=0,0,0
    p1.wakltimer=0
end

function player_update(dt)
    p1.dx=0
    p1.dz=0

    if upkey then
        p1.dz = -2*dt
    elseif downkey then
        p1.dz = 2*dt
    end

    if rightkey then
        p1.dx = 2*dt
    elseif leftkey then
        p1.dx = -2*dt
    end

    if ((p1.dx ~= 0) and (p1.dz ~= 0)) then
        p1.dx = p1.dx * 0.707
        p1.dz = p1.dz * 0.707
    end

    if (upkey or downkey or rightkey or leftkey) then
        p1.walktimer = (p1.walktimer + dt)%1
        p1.angle = math.atan2(-p1.dz/dt,p1.dx/dt)
    else
        p1.walktimer = 0
    end

    p1.z = p1.z + p1.dz
    p1.x = p1.x + p1.dx
end

function player_draw()
    --body and mouth
    setColor(12)
    lovr.graphics.cube('fill',p1.x,p1.y+.45+.05*math.sin(p1.walktimer*12*math.pi),p1.z,.5,p1.angle,0,1,0)
    setColor(0)
    lovr.graphics.box('fill',p1.x+.25*math.cos(p1.angle),
                    p1.y+.45+.05*math.sin(p1.walktimer*12*math.pi), 
                    p1.z-.25*math.sin(p1.angle),
                    .05,.25,.35,p1.angle,0,1,0)
    --legs
    setColor(7)
    lovr.graphics.cube('fill',p1.x+.1*math.sin(p1.angle) + .3*math.sin(p1.walktimer*6*math.pi)*math.cos(p1.angle),
                p1.y+.05 + .1*math.abs(math.sin(p1.walktimer*6*math.pi)),
                p1.z+.1*math.cos(p1.angle) -.3*math.sin(p1.walktimer*6*math.pi)*math.sin(p1.angle),
                .1,p1.angle,0,1,0)
    lovr.graphics.cube('fill',p1.x-.1*math.sin(p1.angle) + .3*math.sin(-p1.walktimer*6*math.pi)*math.cos(p1.angle),
                p1.y+.05+ .1*math.abs(math.sin(p1.walktimer*6*math.pi)),
                p1.z-.1*math.cos(p1.angle) -.3*math.sin(-p1.walktimer*6*math.pi)*math.sin(p1.angle),
                .1,p1.angle,0,1,0)
    
    --arms
    lovr.graphics.cube('fill',p1.x+.3*math.sin(p1.angle),p1.y+.45+.05*math.sin(p1.walktimer*12*math.pi),
                p1.z+.3*math.cos(p1.angle),.1,p1.angle,0,1,0)
    lovr.graphics.cube('fill',p1.x-.3*math.sin(p1.angle),p1.y+.45+.05*math.sin(p1.walktimer*12*math.pi),
                p1.z-.3*math.cos(p1.angle),.1,p1.angle,0,1,0)
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
function cam_init()
    camx=p1.x
    camy=p1.y+2
    camz=p1.z+3
    camangle=-math.pi*0.125
    function resetCam()
        lovr.graphics.setViewPose(1,camx,camy,camz,camangle,1,0,0)
    end
    resetCam()
end

function cam_update()
    camx = camx + (p1.x-camx)/5
    camy = camy + (p1.y+2-camy)/5
    camz = camz + (p1.z+3-camz)/5

    resetCam()
end

function cam_draw()
end

-->8 Game Loop
function lovr.load()
    input_init()
    player_init()
    level_init()
    cam_init()
    lovr.graphics.setShader(shader)
end

function lovr.update(dt)
    input_update()
    player_update(dt)
    level_update(dt)
    cam_update(dt)
end

function lovr.draw()
    lovr.graphics.setBackgroundColor(color_table[2])
    player_draw()
    level_draw()
    cam_draw()
end