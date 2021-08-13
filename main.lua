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

function del(t,v)
    ix=nil
    for i,vv in pairs(t) do
        if v==vv then
            ix=i
        end
    end
    if ix then table.remove(t,ix) end
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
    lovr.graphics.print(text,p1.x,p1.y+1+print_lines,p1.z,.25,camangle,0,1,0)
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
    dx=0,
    dy=0,
    dz=0,
    killme=false,
    walktimer=0,
    mychunks={}
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

function actor:bump_me(other)
end

function actor:kill_me()
    del(actor_list,self)
    for _,c in pairs(self.mychunks) do
        del(c,self)
    end
end

function actor:bump_others(others)
    for _,other in pairs(others) do
        if math.abs(self.x-other.x)<other.size and 
        math.abs(self.z-other.z)<other.size and 
        math.abs(self.y-other.y)<other.size
        then
            other:bump_me(self)
        end
    end
end

function actor:collide_with_blocks(blocktable)
    self.onblocks = {}
    for i,b in pairs(blocktable) do
        if self.dx < 0 then
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
        if self.dx > 0 then
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
        if self.dz > 0 then
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
        if self.dz < 0 then
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
        if key=='x' then xkey = true end
        if key=='w' then camup = true end
        if key=='a' then camleft = true end
        if key=='s' then camdown = true end
        if key=='d' then camright = true end
    end
    function lovr.keyreleased(key)
        if key=='right' then rightkey = false end
        if key=='left' then leftkey = false end
        if key=='up' then upkey = false end
        if key=='down' then downkey = false end
        if key=='z' then zkey = false end
        if key=='x' then xkey = false end
        if key=='w' then camup = false end
        if key=='a' then camleft = false end
        if key=='s' then camdown = false end
        if key=='d' then camright = false end
    end
end

function input_update()
end

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

    if upkey then
        self.dz =self.dz -1 * math.cos(-camangle)
        self.dx =self.dx -1 * math.sin(camangle)
        self.speed = 2*dt
    elseif downkey then
        self.dz =self.dz+ 1 * math.cos(-camangle)
        self.dx =self.dx+ 1 * math.sin(camangle)
        self.speed = 2*dt
    end

    if rightkey then
        self.dx =self.dx+ 1 * math.cos(-camangle)
        self.dz =self.dz+ -1 * math.sin(camangle)
        self.speed = 2*dt
    elseif leftkey then
        self.dx =self.dx+ -1 * math.cos(-camangle)
        self.dz =self.dz+ 1 * math.sin(camangle)
        self.speed = 2*dt
    end

    if xkey then self.speed = self.speed*1.75 end

    if (self.speed > 0) then self.angle = math.atan2(-self.dz,self.dx) end
    self.dz = -self.speed*math.sin(self.angle)
    self.dx = self.speed*math.cos(self.angle)

    -- if ((self.dx ~= 0) and (self.dz ~= 0)) then
    --     self.dx = self.dx * 0.707
    --     self.dz = self.dz * 0.707
    -- end

    if (upkey or downkey or rightkey or leftkey) then
        if self.grounded then 
            self.walktimer = (self.walktimer + dt)%1 
            if xkey then self.walktimer = (self.walktimer + .5*dt)%1 end
        end
        self.angle = math.atan2(-self.dz,self.dx) % (math.pi*2)
    else
        self.walktimer = 0
    end

    if (zkey and self.grounded) then
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

--> objects
coin = actor:new()

function coin:init()
    self:collide_with_blocks(level_blocks)
end

function coin:bump_me()
    self.killme=true
    self:kill_me()
    coincount = coincount+1
end

function coin:draw()
    set_color(9)
    lovr.graphics.translate(self.x,self.y+.5,self.z)
    lovr.graphics.rotate(math.pi/2,0,0,1)
    lovr.graphics.cylinder(0,0,0,0.05,2*math.pi*worldtime,1,0,0,.25,.25,true,6)
    lovr.graphics.origin()
    self:draw_shadow()
end

actor_list = {}

function make_coin(x,y,z)
    add(actor_list,coin:new{x=x,y=y,z=z})
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

function level_chunk_init()
    -- cut the level into smaller chunks to reduce collision calculations with harry
    minx=0
    maxx=0
    minz=0
    maxz=0
    chunkdist=5
    for _,b in pairs(level_blocks) do
        minx = math.min(minx,b.x0)
        minz = math.min(minz,b.z0)
        maxx = math.max(maxx,b.x1)
        maxz = math.max(maxz,b.z1)
    end
    chunktable={}
    for xx = minx,maxx+1,chunkdist do
        local chunkcol={}
        for zz = minz,maxz+1,chunkdist do
            xx0=xx-1
            xx1=xx+chunkdist+1
            zz0=zz-1
            zz1=zz+1+chunkdist
            local chunk={}
            local chunk_act={}
            for _,b in pairs(level_blocks) do
                if b.x0<xx1 and b.x1>xx0 and b.z0<zz1 and b.z1>zz0 then 
                    add(chunk,b)
                end
            end
            for _,a in pairs(actor_list) do
                if a.x > xx0 and a.x < xx1 and a.z > zz0 and a.z < zz1 then
                    add(chunk_act,a)
                    add(a.mychunks,chunk_act)
                end
            end
            add(chunkcol,{chunk,chunk_act})
        end
        add(chunktable,chunkcol)
    end
end

function return_blocks_from_chunk(x,z)
    if x < minx or x > maxx or z < minz or z > maxz then return {} end
    col = math.floor((x-minx)/chunkdist) + 1
    row = math.floor((z-minz)/chunkdist) + 1
    thischunk = chunktable[col][row]
    return thischunk
end

-->8 Camera
function cam_init(target)
    cam_target=target
    camx=cam_target.x
    camy=cam_target.y+2
    camz=cam_target.z+3
    camdist = 3 -- floor distance from ahrry to cam
    downangle=-math.pi*0.125
    camangle=0
    
    function resetCam()
        camfrom = lovr.math.vec3(camx,camy,camz)
        camto = lovr.math.vec3(cam_target.x, cam_target.y+1, cam_target.z)
        camup = lovr.math.vec3(0,1,0)

        cammat = lovr.math.mat4()
        cammat:lookAt(camfrom,camto,camup)
        lovr.graphics.setViewPose(1,cammat,true)
        shader:send('lovrLightDirection', camto - camfrom )
    end
    
end

function cam_update(dt)
    angt = (p1.angle - 0.5*math.pi) % (math.pi*2)

    if (camleft) then camangle = camangle + 1*dt end
    if (camright) then camangle = camangle - 1*dt end

    angt1 = angt-camangle

    if angt1 < math.pi and angt1 >= 0 then 
        angbest = angt1
    elseif angt1 >= math.pi then
        angbest = angt1-2*math.pi
    elseif angt1 < 0 and angt1 > -math.pi then
        angbest = angt1
    else
        angbest = 2*math.pi + angt1
    end
    
    if (downkey) then angbest = 0 end

    if (not camleft and not camright) then camangle = camangle + (angbest)*dt end
    camangle = camangle % (2*math.pi)

    camx = cam_target.x + 3*math.sin(camangle)
    camz = cam_target.z + 3*math.cos(-camangle)
    camy = camy + (cam_target.y + 2 - camy)/4

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

    make_coin(5,2,8)
    for aa=0,math.pi*2,.1 do
        make_coin(7*math.cos(aa),1,7*math.sin(aa))
    end

    level_chunk_init()

    lovr.graphics.setShader(shader)
    lovr.graphics.setCullingEnabled(true) -- my camera stinks so this helps :)
    
    worldtime = 0
    coincount=0
end

function lovr.update(dt)
    input_update()
    -- player_update(dt)

    level_chunk = return_blocks_from_chunk(p1.x,p1.z)
    p1:update(dt, level_chunk[1], level_chunk[2])

    for _,c in pairs(actor_list) do
        c:update()
    end

    level_update(dt)
    cam_update(dt)

    worldtime = worldtime + dt
end

function lovr.draw()
    lovr.graphics.setShader(shader)
    lovr.graphics.setBackgroundColor(color_table[2])
    -- player_draw()
    p1:draw()
    for _,c in pairs(actor_list) do
        c:draw()
    end

    level_draw()
    cam_draw()
    
    -- debug stuff
    lovr.graphics.setShader()
    print_lines = 0
    -- print_gui("Hero dx: "..p1.dx)
    --print_gui("P angle: "..math.floor(p1.angle*180/math.pi))
    --print_gui("cam ang: "..math.floor(camangle*180/math.pi))
    print_gui("col: "..col)
    print_gui("row: "..row)
end