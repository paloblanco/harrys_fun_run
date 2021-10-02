-->8 imports
shader = require 'shader'
thing = require 'thing'
actor = require 'actor'
player = require 'player'
-- coin = require 'objects'
require 'objects'
block = require 'block'
camera = require 'camera'
-- level = require 'level'
require 'level_random'
sfx = require 'sfx'
require 'convenience'


-->8 creating instants for the game world


-->8 Level

function level_init()
    LEVEL_BLOCKS, GOAL, START = make_level()
    make_objects(GOAL, START)
end

function level_update(dt)
end

function level_draw()
    for i,b in pairs(LEVEL_BLOCKS) do
        set_color(b.color)
        lovr.graphics.box('fill',b.xmid,b.ymid,b.zmid,b.dx,b.dy,b.dz,0,0,1,0)
    end
end

function level_chunk_init(chunkdist)
    -- cut the level into smaller chunks to reduce collision calculations with harry
    local minx=0
    local maxx=0
    local minz=0
    local maxz=0
    -- chunkdist=5
    for _,b in pairs(LEVEL_BLOCKS) do
        minx = math.min(minx,b.x0)
        minz = math.min(minz,b.z0)
        maxx = math.max(maxx,b.x1)
        maxz = math.max(maxz,b.z1)
    end
    chunktable={}
    for xx = minx,maxx+1,chunkdist do
        local chunkcol={}
        for zz = minz,maxz+1,chunkdist do
            local xx0=xx-1
            local xx1=xx+chunkdist+1
            local zz0=zz-1
            local zz1=zz+1+chunkdist
            local chunk={}
            local chunk_act={}
            for _,b in pairs(LEVEL_BLOCKS) do
                if b.x0<xx1 and b.x1>xx0 and b.z0<zz1 and b.z1>zz0 then 
                    add(chunk,b)
                end
            end
            for _,a in pairs(ACTOR_LIST) do
                if a.x > xx0 and a.x < xx1 and a.z > zz0 and a.z < zz1 then
                    add(chunk_act,a)
                    add(a.mychunks,chunk_act)
                end
            end
            add(chunkcol,{chunk,chunk_act})
        end
        add(chunktable,chunkcol)
    end
    local function return_blocks_from_chunk(x,z)
        if x < minx or x > maxx or z < minz or z > maxz then return {{},{}} end
        col = math.floor((x-minx)/chunkdist) + 1
        row = math.floor((z-minz)/chunkdist) + 1
        thischunk = chunktable[col][row]
        return thischunk
    end
    return return_blocks_from_chunk
end

-->8 Game Loop

function init_global_vars()
    WORLDTIME=0
    COINCOUNT=0
    CHUNKDIST=5
    ACTOR_LIST = {}
    PAUSE = false
end


function lovr.load()
    init_global_vars()
    input_init()
    snd = sfx:new()
    -- p1 = player:new()
    
    -- level
    level_init()
    CAM = camera:new()
    CAM:setup(p1)

    
    get_chunk = level_chunk_init(CHUNKDIST)

    -- graphics
    lovr.graphics.setShader(shader)
    lovr.graphics.setCullingEnabled(true) -- my camera stinks so this helps :)

    -- kick off the game
    lovr.update = update_gameplay
    lovr.draw = draw_gameplay
end

function update_gameplay(dt)
    level_chunk = get_chunk(p1.x,p1.z)
    
    xval, zval, mag, angle, runbutton, jumpbutton, pressenter = input_process_keyboard(CAM.angle)
    p1:update(dt, level_chunk[1], level_chunk[2],xval, zval, mag, angle, runbutton, jumpbutton)
    -- p1:update(dt, LEVEL_BLOCKS, ACTOR_LIST,xval, zval, mag, angle, runbutton, jumpbutton)

    for _,c in pairs(ACTOR_LIST) do
        c:update()
    end

    level_update(dt)
    CAM:update(dt)

    WORLDTIME = WORLDTIME + dt

    if pressenter then
        pause_game()
    end
end

function update_pause(dt)
    xval, zval, mag, angle, runbutton, jumpbutton, pressenter = input_process_keyboard(CAM.angle)
    CAM:reset() -- need to still update matrix
    if pressenter then
        unpause_game()
    end
end


function draw_gameplay()
    lovr.graphics.setShader(shader)
    lovr.graphics.setBackgroundColor(color_table[2])
    -- player_draw()
    p1:draw()
    for _,c in pairs(ACTOR_LIST) do
        c:draw()
    end

    level_draw()
    CAM:draw()
    
    -- GUI
    lovr.graphics.setShader()
    
    CAM:draw_text("hi",-0.5,0.3,.05)
    CAM:draw_text("hi",-0.5,0.2,.15)
    
    -- debug
    PRINTLINES = 0

    -- print_gui("col: "..col,CAM.angle)
    -- print_gui("row: "..row,CAM.angle)
end

function pause_game()
    lovr.update = update_pause
end

function unpause_game()
    lovr.update = update_gameplay
end