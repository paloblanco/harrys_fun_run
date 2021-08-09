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
    p1.y=1.7
    p1.z=-1
    p1.angle=0
    p1.dx,p1.dy,p1.dz=0,0,0
end

function player_update(dt)
    p1.dx=0
    p1.dz=0

    if upkey then
        p1.dz = -1*dt
    elseif downkey then
        p1.dz = 1*dt
    end

    if rightkey then
        p1.dx = 1*dt
    elseif leftkey then
        p1.dx = -1*dt
    end

    p1.z = p1.z + p1.dz
    p1.x = p1.x + p1.dx
end

function player_draw()
    lovr.graphics.setColor(.3,.8,1)
    lovr.graphics.cube('fill',p1.x,p1.y,p1.z,.5,p1.angle,0,1,0)
end

-->8 Level
function level_init()
end

function level_update()
end

function level_draw()
end

-->8 Camera
function cam_init()
    lovr.graphics.setViewPose(1,0,2,4,0,0,1,0)
end

function cam_update()
end

function cam_draw()
end

-->8 Game Loop
function lovr.load()
    input_init()
    player_init()
    level_init()
    cam_init()
end

function lovr.update(dt)
    input_update()
    player_update(dt)
    level_update(dt)
    cam_update(dt)
end

function lovr.draw()
    lovr.graphics.setColor()
    player_draw()
    level_draw()
    cam_draw()
end