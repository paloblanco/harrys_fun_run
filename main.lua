-->8 imports
shader = require 'shader'
thing = require 'thing'
actor = require 'actor'
player = require 'player'
coin = require 'objects'
block = require 'block'
camera = require 'camera'
require 'convenience'


-->8 creating instants for the game world


-->8 Level

function level_init()
    ground = make_new_block(-10,0,-10,10,1,10,3)
    b1 = make_new_block(0,1,3,3,2,5,6)
    LEVEL_BLOCKS = {
        ground,
        make_new_block(0,1,3,3,2,5,6),
        make_new_block(0,1,3,3,3,4,6),
        make_new_block(0,2,2,3,4,3,6),
        make_new_block(-4,3,1,3,5,2,6),
    }
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
end

function lovr.load()
    init_global_vars()
    input_init()
    p1 = player:new()
    level_init()

    CAM = camera:new()
    CAM:setup(p1)

    make_coin(5,2,8)
    for aa=0,math.pi*2,.1 do
        make_coin(7*math.cos(aa),1,7*math.sin(aa))
    end

    get_chunk = level_chunk_init(CHUNKDIST)

    lovr.graphics.setShader(shader)
    lovr.graphics.setCullingEnabled(true) -- my camera stinks so this helps :)
end

function lovr.update(dt)

    level_chunk = get_chunk(p1.x,p1.z)
    p1:update(dt, level_chunk[1], level_chunk[2])

    for _,c in pairs(ACTOR_LIST) do
        c:update()
    end

    level_update(dt)
    CAM:update(dt)

    WORLDTIME = WORLDTIME + dt
end

function lovr.draw()
    lovr.graphics.setShader(shader)
    lovr.graphics.setBackgroundColor(color_table[2])
    -- player_draw()
    p1:draw()
    for _,c in pairs(ACTOR_LIST) do
        c:draw()
    end

    level_draw()
    CAM:draw()
    
    -- debug stuff
    lovr.graphics.setShader()
    PRINTLINES = 0
    -- print_gui("Hero dx: "..p1.dx)
    --print_gui("P angle: "..math.floor(p1.angle*180/math.pi))
    --print_gui("cam ang: "..math.floor(camangle*180/math.pi))
    print_gui("col: "..col,CAM.angle)
    print_gui("row: "..row,CAM.angle)
end