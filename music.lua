thing = require 'thing'
require 'convenience'

music = thing:new()

function music:init()
    self.on = true
    local file_list = {
        "resources/IntroJJ.ogg",
        "resources/leveljj2.ogg",
    }
    self.snd_list = {}
    for _,fn in pairs(file_list) do
        local source = lovr.audio.newSource(fn)
        source:setLooping(true)
        source:setVolume(0.5)
        add(self.snd_list,source)
    end
    self.snd_playing={}
end

function music:play(ix)
    for _,m in pairs(self.snd_list) do
        m:stop()
    end
    if self.on then self.snd_list[ix]:play() end
end

function music:stop()
    for _,m in pairs(self.snd_list) do
        m:stop()
    end
end

function music:toggle()
    self.on = not self.on
end

return music