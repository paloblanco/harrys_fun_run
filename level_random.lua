block = require 'block'
require 'objects'
require 'convenience'


function make_level()
    local params = {
        xmin = 0,
        zmin = 0,
        ymin=-10,
        xmax = 32,
        zmax = 64,
        ymax = 10,
        endz=0
    }
    params.endx = (params.xmin+params.xmax)/2 -2 + rnd(5)
    params.maxd = math.abs(params.xmax-params.xmin) + math.abs(params.zmax-params.zmin)

    local level = {}

    local endblock = make_new_block(params.endx-1,params.ymin,params.endz,
                                    params.endx+1,params.ymax,params.endz+2)

    add(level,endblock)

    local goal =  {
        x=(endblock.x1+endblock.x0)/2,
        y=endblock.y1,
        z=(endblock.z1+endblock.z0)/2        
    }

    -- randomly make a level
    for xx=params.xmin,params.xmax,1 do
        for zz=params.zmin,params.zmax,1 do
            local proceed=true
            if rnd() < 0.97 then proceed = false end
            if proceed then
                local xw = 1 + (rnd(2))
                local zw = 1 + (rnd(2))
                local xwn = 1 + (rnd(2))
                local zwn = 1 + (rnd(2)) 

                -- NEED TO ADD CODE TO STOP BLOCKS FROM OVERLAPPING
                local distfromgoal = math.abs(goal.x-xx) + math.abs(goal.z-zz)
                local yh = params.ymax*(1-distfromgoal/params.maxd) - 4 + rnd(5)
                yh = math.max(yh,1)
                cchoice = {11,15,3}
                local c = cchoice[1+math.floor(rnd(3))]
                local thisblock = make_new_block(xx-xwn,-10,zz-zwn,xx+xw,yh,zz+zw,c)

                add(level,thisblock)
                
            end
        end
    end
    local start = {}
    start.x0 = params.xmin + 4
    start.x1 = params.xmax - 4
    start.z1 = params.zmax + 4
    start.z0 = params.zmax + 1
    start.y0 = -10
    start.y1 = 0.5
    local thisblock = make_new_block(start.x0,start.y0,start.z0,
                                    start.x1,start.y1,start.z1)
    add(level,thisblock)

    return level, goal, start
end

function make_objects(goal, start)
    -- make_coin(5,2,8)
    -- for aa=0,math.pi*2,.1 do
    --     make_coin(7*math.cos(aa),1,7*math.sin(aa))
    -- end
    make_flag(goal.x,goal.y,goal.z)
    p1 = player:new({
        x=(start.x0+start.x1)/2,
        z=(start.z0+start.z1)/2,
        y=start.y1
    })
end

return make_level, make_objects
-- return level