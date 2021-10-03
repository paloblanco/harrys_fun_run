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

function rnd(x)
    x=x or 1
    return x*lovr.math.random()
end

PRINTLINES=0
function print_gui(text, angle)
    set_color(7)
    lovr.graphics.setFont()
    lovr.graphics.print(text,p1.x,p1.y+1+PRINTLINES,p1.z,.25,angle,0,1,0)
    PRINTLINES = PRINTLINES + .5
end



-->8 Controls
function input_init()
    function lovr.keypressed(key)
        if key=='right' then RIGHTKEY = true end
        if key=='left' then LEFTKEY = true end
        if key=='up' then UPKEY = true end
        if key=='down' then DOWNKEY = true end
        if key=='z' then ZKEY = true end
        if key=='x' then XKEY = true end
        if key=='w' then CAMUP = true end
        if key=='a' then CAMLEFT = true end
        if key=='s' then CAMDOWN = true end
        if key=='d' then CAMRIGHT = true end
        if key=='return' then ENTER = true end
        if key=='r' then RESTART = true end
        if key=='j' then JJ = true end
    end
    function lovr.keyreleased(key)
        if key=='right' then RIGHTKEY = false end
        if key=='left' then LEFTKEY = false end
        if key=='up' then UPKEY = false end
        if key=='down' then DOWNKEY = false end
        if key=='z' then ZKEY = false end
        if key=='x' then XKEY = false end
        if key=='w' then CAMUP = false end
        if key=='a' then CAMLEFT = false end
        if key=='s' then CAMDOWN = false end
        if key=='d' then CAMRIGHT = false end
        if key=='return' then ENTER = false end
        if key=='r' then RESTART = false end
        if key=='j' then JJ = false end
    end
    ENTEROLD=false
    RESTARTOLD=false
    JJOLD = false
end

function input_process_keyboard(camera_angle)
    local zval = 0
    local xval = 0
    local mag = 0
    local angle = 0
    local runbutton = false
    local jumpbutton = false
    local pressenter = false
    local pressr = false
    pressj = false
    
    if UPKEY or CAMUP then
        zval =zval -1 * math.cos(-camera_angle)
        xval =xval -1 * math.sin(camera_angle)
        mag = 1
    elseif DOWNKEY or CAMDOWN then
        zval =zval+ 1 * math.cos(-camera_angle)
        xval =xval+ 1 * math.sin(camera_angle)
        mag = 1
    end
    if RIGHTKEY or CAMRIGHT then
        xval =xval+ 1 * math.cos(-camera_angle)
        zval =zval+ -1 * math.sin(camera_angle)
        mag = 1
    elseif LEFTKEY or CAMLEFT then
        xval =xval+ -1 * math.cos(-camera_angle)
        zval =zval+ 1 * math.sin(camera_angle)
        mag = 1
    end

    if XKEY then runbutton = true end
    if ZKEY or JJ then jumpbutton= true end

    angle = math.atan2(-zval,xval)

    
    if ENTER and not ENTEROLD then
        pressenter = true
    end
    ENTEROLD=ENTER

    if RESTART and not RESTARTOLD then
        pressr = true
    end
    RESTARTOLD=RESTART

    -- if JJ and not JJOLD then
    --     pressj = true
    -- end
    return xval, zval, mag, angle, runbutton, jumpbutton, pressenter, pressr
end

function input_process_keyboard_paused()
    if ENTER and not ENTEROLD then
        PAUSE = not PAUSE
    end
end

function sign(num)
    if num > 0 then return 1
    elseif num < 0 then return -1
    else return 0 end
end

function make_cloud(x,y,z,s)
    add(CLOUDLIST,{
        x=x,
        y=y,
        z=z,
        s=s,
        t=0})
end

function update_clouds(dt)
    for _,cc in pairs(CLOUDLIST) do
        cc.y = cc.y + 2*dt
        cc.t = cc.t+dt
        if cc.t > .25 then del(CLOUDLIST,cc) end
    end
end

function draw_clouds()
    set_color(6)
    for _,cc in pairs(CLOUDLIST) do
        -- lovr.graphics.sphere(cc.x,cc.y,cc.z,cc.s+cc.t/2)
        -- lovr.graphics.cube('fill',cc.x,cc.y,cc.z,cc.s+cc.t/2)
    end
end


        
