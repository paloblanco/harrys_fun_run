-->8 imports
shader = require 'shader'
thing = require 'thing'

-->8 Convenience functions
color_table = {
    0x000000,-- 0 black
    0x1d2b53,-- 1 dark-blue
    0x7e2553,-- 2 dark-purple
    0x008751,-- 3 dark-green
    0xab5236,-- 4 brown
    0x5f574f,-- 5 dark-gray
    0xc2c3c7,-- 6 light-gray
    0xfff1e8,-- 7 white
    0xff004d,-- 8 red
    0xffa300,-- 9 orange
    0xffec27,-- 10 yellow
    0x00e436,-- 11 green
    0x29adff,-- 12 blue
    0x83769c,-- 13 indigo
    0xff77a8,-- 14 pink
    0xffccaa,-- 15 peach
}
function set_color(ix)
    -- sets color, pico8 style
    lovr.graphics.setColor(color_table[ix+1])
end

function add(t,v)
    table.insert(t,v)
end

function draw_cam_info()
    lovr.graphics.print('Hello World',0,1.7,-3,.25)
    for ix,val in pairs({lovr.graphics.getViewPose(1)}) do
        lovr.graphics.print(val,0,1.7-.5*ix,-3,.5)    
    end
end

print_lines=0
function print_gui(text)
    set_color(7)
    lovr.graphics.setFont()
    lovr.graphics.print(text,p1.x,p1.y+1+print_lines,p1.z,.25)
    print_lines = print_lines + .5
end

-->8 Actor class
actor = thing:new{
    shadow = true,
    onblocks = {},
    size=0.5,
    angle=0,
    x=0,
    y=0,
    z=0,
    xold=0,
    yold=0,
    zold=0,
    killme=false
}

function actor:draw_shadow()
    for _,b in pairs(self.onblocks) do
        set_color(0)
        lovr.graphics.box('fill',self.x,b.y1,
            self.z,self.size,.05,self.size,self.angle,0,1,0)
    end
end

function actor:update()
end

function actor:draw()
end

function actor:collide_with_blocks(blocktable)
    self.onblocks = {}
    for i,b in pairs(blocktable) do
        if self.dx <= 0 then
            if (self.xold - self.size*.5 >= b.x1) and
            (self.x - self.size*.5 < b.x1) and
            (self.z + self.size*.5 > b.z0) and 
            (self.z - self.size*.5 < b.z1) then
                if (self.y < b.y1) and
                (self.y+self.size > b.y0) then
                    -- bump to the right
                    self.x = b.x1+self.size*0.5
                    self.dx=0
                    goto continue
                end
            end
        end
        if self.dx >= 0 then
            if (self.xold + (self.size*.5) <= b.x0) and
            (self.x + self.size*.5 >= b.x0) and
            (self.z + self.size*.5 > b.z0) and
            (self.z - self.size*.5 < b.z1) then
                if (self.y < b.y1) and
                (self.y+self.size > b.y0) then
                    -- bump to the left
                    self.x = b.x0-self.size*0.5
                    self.dx=0
                    goto continue
                end
            end
        end
        if self.dz >= 0 then
            if (self.x + self.size*.5 > b.x0) and
            (self.x - self.size*.5 < b.x1) and
            (self.z + self.size*.5 > b.z0) and
            (self.zold + self.size*.5 <= b.z0) then
                if (self.y < b.y1) and
                (self.y+self.size > b.y0) then
                    -- bump up
                    self.z = b.z0-self.size*0.5
                    self.dz=0
                    goto continue
                end
            end
        end
        if self.dz <= 0 then
            if (self.x + self.size*.5 > b.x0) and
            (self.x - self.size*.5 < b.x1) and
            (self.zold - self.size*.5 >= b.z1) and
            (self.z - self.size*.5 < b.z1) then
                if (self.y < b.y1) and
                (self.y+self.size > b.y0) then
                    -- bump down
                    self.z = b.z1+self.size*0.5
                    self.dz=0
                    goto continue
                end
            end
        end
        if ((self.x + self.size*0.5 > b.x0) and (self.x - self.size*0.5 < b.x1) and
        (self.z + self.size*0.5>b.z0) and (self.z - self.size*0.5 < b.z1)) then
            add(self.onblocks,b)
        end
        ::continue::
    end
    for i,b in pairs(self.onblocks) do
        if (self.x + self.size*.5 > b.x0) and
            (self.x - self.size*.5 < b.x1) and
            (self.z + self.size*.5 > b.z0) and
            (self.z - self.size*.5 < b.z1) then
            if self.dy < 0 then
                if (self.y < b.y1) and
                (self.y+self.size > b.y0) then
                    self.grounded=true
                    self.y = b.y1
                    self.dy=0
                end
            elseif self.dy > 0 then
                if (self.y < b.y0) and
                (self.y+self.size > b.y0) then
                    self.y = b.y0 - self.size
                    self.dy=0
                end
            end
        end
    end
end


-->8 Player
function input_init()
    function lovr.keypressed(key)
        if key=='right' then rightkey = true end
        if key=='left' then leftkey = true end
        if key=='up' then upkey = true end
        if key=='down' then downkey = true end
        if key=='z' then zkey = true end
    end
    function lovr.keyreleased(key)
        if key=='right' then rightkey = false end
        if key=='left' then leftkey = false end
        if key=='up' then upkey = false end
        if key=='down' then downkey = false end
        if key=='z' then zkey = false end
    end
end

function input_update()
end

player = actor:new{
    x=0,
    y=1.5,
    z=9,
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

function player:update(dt,blocks)
    self.dx=0
    self.dz=0
    self.xold=self.x
    self.yold=self.y
    self.zold=self.z

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
        self.angle = math.atan2(-self.dz,self.dx)
    else
        self.walktimer = 0
    end

    if (zkey and self.grounded) then
        self.dy = 7*dt
        self.grounded = false
    end


    -- move!
    self.z = self.z + self.dz
    self.x = self.x + self.dx
    
    self.grounded=false
    self.dy = self.dy - .3*dt
    self.y = self.y + self.dy

    --collide!
    self:collide_with_blocks(blocks)
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
                    0-.25*0,
                    .05,.25,.35,0,0,1,0)
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
    b1 = make_new_block(0,1,3,3,2,5,6)
    level_blocks = {
        ground,
        make_new_block(0,1,3,3,2,5,6),
        make_new_block(0,1,3,3,3,4,6),
        make_new_block(0,2,2,3,4,3,6),
        make_new_block(-4,3,1,3,5,2,6),
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
    p1:update(dt, level_blocks)
    level_update(dt)
    cam_update(dt)
end

function lovr.draw()
    lovr.graphics.setShader(shader)
    lovr.graphics.setBackgroundColor(color_table[2])
    -- player_draw()
    p1:draw()
    level_draw()
    cam_draw()
    
    -- debug stuff
    lovr.graphics.setShader()
    print_lines = 0
    print_gui("Hero dx: "..p1.dx)
end