-->8 imports
shader = require 'shader'
thing = require 'thing'
actor = require 'actor'
player = require 'player'
require 'objects'
block = require 'block'
camera = require 'camera'
require 'level_random'
sfx = require 'sfx'
music = require 'music'
require 'convenience'


-->8 creating instants for the game world


-->8 Level

function make_level_and_place_objects()
    LEVEL_BLOCKS, GOAL, START = make_level(LEVELIX)
    make_objects(GOAL, START)
    BLOCKS_UPDATE = {}
    CLOUDLIST = {}
end

function level_update(dt)
    for _,b in pairs(BLOCKS_UPDATE) do
        b:update(dt)
    end
    update_clouds(dt)
end

function level_draw()
    for i,b in pairs(LEVEL_BLOCKS) do
        b:draw()
    end
    set_color(6)
    lovr.graphics.sphere(0,-4006,0,4000)
    draw_clouds()
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
    minx = math.floor(minx - 2)
    maxx = math.floor(maxx + 2)
    minz = math.floor(minz - 2)
    maxz = math.floor(maxz + 2)
    chunktable={}
    for xx = minx,maxx+1,chunkdist do
        local chunkcol={}
        for zz = minz,maxz+1,chunkdist do
            local xx0=xx-2
            local xx1=xx+chunkdist+2
            local zz0=zz-2
            local zz1=zz+2+chunkdist
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
    PAUSE = false
    LOADING=false
    STARTING=false
    GAMEOVER=false
    GAMEWIN=false
    DEAD=false
    LEVELIX=1
    DEATHCOUNT=0
    SB = lovr.graphics.newTexture({
        left = 'resources/p1.png',
        right = 'resources/p1.png',
        top = 'resources/pup.png',
        bottom = 'resources/pdown.png',
        front = 'resources/p1.png',
        back = 'resources/p1.png',
      })
end

function init_level()
    -- level
    ACTOR_LIST={}
    LOADING=false
    LEVEL_TIME=0
    LEVEL_BLOCKS = {}
    make_level_and_place_objects()
    mus:play(2)
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

function next_level()
    LEVELIX = LEVELIX + 1
    if LEVELIX == 5 then GAMEWIN = true end
    LOAD_TIME=0
    LOADING=true
    -- mus:stop()
    snd:play(2)
    lovr.update = update_loading
end

function game_start()
    STARTING=true
    LOAD_TIME = 0
    mus:stop()
    mus:play(1)
    lovr.update = update_start
end

function jenry_died()
    DEATHCOUNT = DEATHCOUNT+1
    snd:play(4)
    mus:stop()
    if LEVELIX <= 4 then
        DEAD = true
        LOADING = true
        LOAD_TIME = 0
        lovr.update = update_loading
    else
        game_over()
    end
end

function game_over()
    GAMEOVER = true
    mus:stop()
    LOAD_TIME = 0
    lovr.update = update_gameover
end

function game_win()
    GAMEWIN = true
    LOAD_TIME = 0
    mus:stop()
    lovr.update = update_gamewin
end

function lovr.load()
    init_global_vars()
    input_init()
    snd = sfx:new()
    mus = music:new()
    -- p1 = player:new()  
    init_level() 
    game_start()
end

function update_gameplay(dt)
    level_chunk = get_chunk(p1.x,p1.z)
    WORLDTIME = WORLDTIME + dt
    
    xval, zval, mag, angle, runbutton, jumpbutton, pressenter, pressr = input_process_keyboard(CAM.angle)
    p1:update(dt, level_chunk[1], level_chunk[2],xval, zval, mag, angle, runbutton, jumpbutton)
    -- p1:update(dt, LEVEL_BLOCKS, ACTOR_LIST,xval, zval, mag, angle, runbutton, jumpbutton)

    for _,c in pairs(ACTOR_LIST) do
        c:update()
    end

    level_update(dt)
    CAM:update(dt)

    WORLDTIME = WORLDTIME + dt/2

    if pressenter then
        pause_game()
    end
    if pressr then
        mus:stop()
        lovr.load()
    end
    if pressj then
        next_level()
    end
    if p1.y < -10 then
        jenry_died()
    end
end

function update_pause(dt)
    xval, zval, mag, angle, runbutton, jumpbutton, pressenter, pressr = input_process_keyboard(CAM.angle)
    CAM:reset() -- need to still update matrix
    if pressenter then
        unpause_game()
    end
    if pressr then
        mus:stop()
        lovr.load()
    end
end

function update_loading(dt)
    LOAD_TIME = LOAD_TIME + dt
    xval, zval, mag, angle, runbutton, jumpbutton, pressenter, pressr = input_process_keyboard(CAM.angle)
    CAM:reset() -- need to still update matrix
    if DEAD then
        if LOAD_TIME > 1 and jumpbutton then
            init_level()
            DEAD = false
        end
    elseif LOAD_TIME > 2 and not GAMEWIN then
        init_level()
    end
    if LOAD_TIME > 1 and GAMEWIN and jumpbutton then
        init_level()
        GAMEWIN = false
    end
end

function update_start(dt)
    LOAD_TIME = LOAD_TIME + dt
    xval, zval, mag, angle, runbutton, jumpbutton, pressenter, pressr = input_process_keyboard(CAM.angle)
    CAM:reset() -- need to still update matrix
    if jumpbutton and LOAD_TIME > .5 then
        lovr.update = update_gameplay
        STARTING=false
        mus:play(2)
    end
end

function update_gameover(dt)
    LOAD_TIME = LOAD_TIME + dt
    xval, zval, mag, angle, runbutton, jumpbutton, pressenter, pressr = input_process_keyboard(CAM.angle)
    CAM:reset() -- need to still update matrix
    if jumpbutton and LOAD_TIME > .5 then
        lovr.load()
    end
end

function draw_gameplay()
    lovr.graphics.setShader()
    -- lovr.graphics.setBackgroundColor(color_table[13])
    lovr.graphics.skybox(SB)
    lovr.graphics.setShader(shader)
    -- player_draw()
    
    for _,c in pairs(ACTOR_LIST) do
        c:draw()
    end
    p1:draw()
    -- lovr.graphics.setShader(shader)

    level_draw()
    CAM:draw()
    
    -- GUI
    lovr.graphics.setShader()
    
    if LEVELIX <= 4 then
        CAM:draw_text("level: "..LEVELIX.."/4    Time: "..math.floor(WORLDTIME).."    STAMINA: "..math.floor(p1.stamina),-0.1,0.3,.05)
    else
        CAM:draw_text("level: "..LEVELIX.."    Time: "..math.floor(WORLDTIME).."      STAMINA: "..math.floor(p1.stamina),-0.1,0.3,.05)
    end
    -- CAM:draw_bar(p1.stamina)
    -- CAM:draw_text("hi",-0.5,0.2,.15)
    if PAUSE then 
        CAM:draw_text("Paused",0,0.2,.1)
        CAM:draw_text("Press Enter to unpause",0,0.1,.075)
        CAM:draw_text("Press R to reset game",0,0.05,.075)
    end

    if GAMEWIN then
        CAM:draw_text("You beat the game, Jenry!",0,0.2,.1)
        CAM:draw_text("Total Deaths: "..DEATHCOUNT,0,.1,.055)
        CAM:draw_text("Thanks for playing!!",-0.25,-0.05,.075)
        CAM:draw_text("--Rocco, aka Palo Blanco",0.25,-0.1,.055)
        if LOAD_TIME > 1 then CAM:draw_text("Press Z or J to keep playing endless mode!",0,-0.2,.075) end
    elseif DEAD then
        CAM:draw_text("Oh no, Jenry!",0,0.2,.1)
        CAM:draw_text("try again...",0,-0.05,.075)
        if LOAD_TIME > .5 then CAM:draw_text("Press Z or J to try this level again",0,-0.1,.075) end
    elseif LOADING then 
        CAM:draw_text("Good job Jenry!",0,0.2,.1)
        CAM:draw_text("You beat level "..(LEVELIX-1),0,0.1,.075)
        CAM:draw_text("Moving on to level "..LEVELIX,0,0.05,.075)
    end

    if STARTING then
        CAM:draw_text("Jenry Javelina!",0,0.2,.1)
        CAM:draw_text("Made by Palo Blanco for LD49",0,-0.05,.075)
        if LOAD_TIME > .5 then CAM:draw_text("Press Z or J to start",0,-0.1,.075) end
    end
    
    if GAMEOVER then
        CAM:draw_text("Oh no, Jenry!",0,0.2,.1)
        CAM:draw_text("Thanks for playing!",0,-0.05,.075)
        if LOAD_TIME > .5 then CAM:draw_text("Press Z or J to restart",0,-0.1,.075) end
    end
    -- debug
    PRINTLINES = 0

    -- print_gui("col: "..col,CAM.angle)
    -- print_gui("row: "..row,CAM.angle)
end

function pause_game()
    lovr.update = update_pause
    PAUSE = true
end

function unpause_game()
    lovr.update = update_gameplay
    PAUSE = false
end