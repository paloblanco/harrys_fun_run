thing = require 'thing'

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
    del(ACTOR_LIST,self)
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

return actor