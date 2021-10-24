require 'convenience'
actor = require 'actor'

player = actor:new{
    x=0,
    y=1.5,
    z=9,
    angle = math.pi*.5,
    xold=0,
    yold=1.5,
    zold=9,
    angle=math.pi/2,
    dx=0,
    dy=0,
    dz=0,
    size=.5,
    wakltimer=0,
    grounded=false,
    onblocks={}, -- table of all the blocks that your y axis is on top of
    canjump=false,
    canwalljump=false,
    stamina = 100,
    walktimerold=0,
    walldir=-1,
    dt0=0,
}

function player:init()
    self.model = lovr.graphics.newModel('resources/javelina.obj')
    self:collide_with_blocks(LEVEL_BLOCKS)
end

function player:update(dt,blocks,others,xval, zval, mag, angle, runbutton, jumpbutton)
    self.dx=0
    self.dz=0
    self.xold=self.x
    self.yold=self.y
    self.zold=self.z
    if self.grounded then self.canjump=true end


    self.speed = 2*dt*mag
    runbutton=true
    if runbutton then self.speed = self.speed*1.75 end
    

    -- if (mag > 0) then self.angle = angle end

    self.dz = self.speed*zval
    self.dx = self.speed*xval

    if (mag > 0) then
        -- if self.grounded then 
        if self.canjump then 
            self.walktimer = (self.walktimer + 1.5*dt )%1 
            -- if runbutton then self.walktimer = (self.walktimer + .5*dt)%1 end
            if self.walktimerold%.125 < .0625 and self.walktimer%.125 > .0625 then
                make_cloud(self.x,self.y,self.z,0.1)
                snd:play(3)
            end
            self.walktimerold = self.walktimer
        end
        self.angle = angle % (math.pi*2)
    else
        self.walktimer = 0
    end

    if (jumpbutton and self.canjump) then
        self.dy = 7.5*(1/60)*.25 -- can't use time elapsed here
        -- self.dy = 7*dt
        self.grounded = false
        self.canjump=false
        snd:play(1)
        make_cloud(self.x+.5,self.y,self.z,0.1)
        make_cloud(self.x-.5,self.y,self.z,0.1)
        make_cloud(self.x,self.y,self.z+.5,0.1)
        make_cloud(self.x,self.y,self.z- .5,0.1)
    elseif (jumpbutton and self.canwalljump) then
        if self.stamina > 20 then
            self.dy = 5.5*(1/60)*.25 -- can't use time elapsed here
            -- self.dy = 5*dt
            for _,b in pairs(self.walls) do
                if ((not b.falling) and (b.canfall)) then b:start_fall() end
            end
            self.grounded = false
            self.canwalljump=false
            snd:play(1)
            make_cloud(self.x+.5,self.y+.5,self.z,0.1)
            make_cloud(self.x-.5,self.y+.5,self.z,0.1)
            make_cloud(self.x,self.y+.5,self.z+.5,0.1)
            make_cloud(self.x,self.y+.5,self.z-.5,0.1)
            self.stamina = math.max(self.stamina - 30, 0)
        else
        end
    end

    self.canwalljump = false

    if not self.grounded then
        if not self.canjump then self.walktimer = .25 end
        if self.canjump==true then
            if self.dy < -.3*.25 then self.canjump = false end
        end
        if #self.walls > 0 and self.dy < 0 then
            self.canwalljump=true
            self.dx = self.dx*.5
            self.dz = self.dz*.5
            self.dy = math.max(self.dy,-3*dt)
            if math.floor((self.y*10)%3) == 0 then make_cloud(self.x,self.y+.5,self.z,0.1) end
        end
    end

    for _,b in pairs(self.killblocks) do
        if ((not b.falling) and (b.canfall)) then b:start_fall() end
    end


    -- move!
    self.z = self.z + self.dz
    self.x = self.x + self.dx
    
    self.grounded=false
    -- gravity calc
    self.dt0 = dt+self.dt0
    while self.dt0 >= (1/240) do
        self.dy = self.dy - .3*.25*(1/240)
        self.y = self.y + self.dy
        self.dt0 = self.dt0 - (1/240)
    end
    -- self.dy = self.dy - .3*self.dt0
    -- self.y = self.y + self.dy
    -- self.dt0=0

    self.stamina = math.min(self.stamina + 30*dt,100)

    --collide!
    self:collide_with_blocks(blocks)
    self:bump_others(others)
end


function player:draw()
    --set transforms
    -- set_color()
    -- lovr.graphics.translate(self.x,self.y,self.z)
    angler = self.angle
    armsup=0
    if self.walldir > -1 then
        if self.walldir == 0 then angler = math.pi
        elseif self.walldir == 1 then angler = 0
        elseif self.walldir == 2 then angler = math.pi/2
        elseif self.walldir == 3 then angler = -math.pi/2
        end
        armsup=0.1
    end
    -- lovr.graphics.rotate(angler,0,1,0)
    
    --body and mouth
    lovr.graphics.setColor(1,1,1,1)
    lovr.graphics.cube('fill',
                        self.x,
                        0.45+.04*math.sin(self.walktimer*12*math.pi) + self.y,
                        self.z,
                        1,
                        0,0,1,0)

    -- self.model:draw(0,0.45+.04*math.sin(self.walktimer*12*math.pi),0,.75*1.25,0,0,1,0,1)
    -- --legs
    -- set_color(7)
    -- lovr.graphics.cube('fill',0.1*0 + .2*math.sin(self.walktimer*6*math.pi)*1,
    --             0.05 + .1*math.abs(math.sin(self.walktimer*6*math.pi)),
    --             0.1*1,
    --             .1,0,0,1,0)
    -- lovr.graphics.cube('fill',0-.1*0 + .2*math.sin(-self.walktimer*6*math.pi)*1,
    --             0+.05+ .1*math.abs(math.sin(self.walktimer*6*math.pi)),
    --             0-.1*1,
    --             .1,0,0,1,0)
    
    -- --arms
    -- lovr.graphics.cube('fill',0+.3*0,0+.45+.05*math.sin(self.walktimer*12*math.pi) + armsup,
    --             0+.3,.1,0,0,1,0)
    -- lovr.graphics.cube('fill',0-.3*0,0+.45+.05*math.sin(self.walktimer*12*math.pi) + armsup,
    --             0-.3,.1,0,0,1,0)

    --shadow
    -- lovr.graphics.pop()
    lovr.graphics.origin()
    self:draw_shadow()

    --bar
    if self.stamina < 100 then
        -- lovr.graphics.setShader()
        if self.stamina < 20 then
            set_color(8)
        else
            set_color(16)
        end
        local length = 1*(self.stamina/100)
        local mid = length/2
        lovr.graphics.translate(self.x,self.y,self.z)
        lovr.graphics.box('fill',0,1,0,length,.2,.2,CAM.angle,0,1,0)
        lovr.graphics.origin()
        lovr.graphics.setColor(1,1,1,1)
        -- lovr.graphics.setShader(shader)
    end
end

return player
