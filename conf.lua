function lovr.conf(t)
    -- taken from: https://lovr.org/docs/lovr.conf
    -- Set the project version and identity
    t.version = '0.15.0'
    t.identity = 'default'
  
    -- Set save directory precedence
    t.saveprecedence = true
  
    -- Enable or disable different modules
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.headset = false
    t.modules.math = true
    t.modules.physics = true
    t.modules.system = true
    t.modules.thread = true
    t.modules.timer = true
  
    -- Audio
    t.audio.spatializer = nil
    t.audio.start = true
  
    -- Graphics
    t.graphics.debug = false
  
    -- Headset settings
    -- t.headset.drivers = { 'openxr', 'oculus', 'vrapi', 'pico', 'openvr', 'webxr', 'desktop' }
    -- t.headset.supersample = false
    -- t.headset.offset = 1.7
    -- t.headset.msaa = 4
  
    -- Math settings
    t.math.globals = true
  
    -- Configure the desktop window
    t.window.width = 1080
    t.window.height = 600
    t.window.fullscreen = false
    t.window.msaa = 0
    t.window.vsync = 1
    t.window.title = 'LÖVR'
    t.window.icon = nil
end