thing = require 'thing'
require 'convenience'

sfx = thing:new()

function sfx:init()
    local file_list = {
        "resources/sfx_0.wav",
        "resources/sfx_win.wav",
        "resources/sfx_steps.wav",
        "resources/sfx_dead.wav",
        "resources/sfx_block.wav",
    }
    self.snd_list = {}
    for _,fn in pairs(file_list) do
        local source = lovr.audio.newSource(fn)
        source:setLooping(false)
        add(self.snd_list,source)
    end
    self.snd_playing={}
end

function sfx:play(ix)
    local new_snd = self.snd_list[ix]:clone()
    new_snd:play()
    add(self.snd_playing,new_snd)
end

function sfx:update()
    for _,snd in pairs(self.snd_playing) do
        if not snd:isPlaying() then
            del(self.snd_playing,snd)
        end
    end
end

return sfx