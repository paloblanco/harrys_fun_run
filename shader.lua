shader = lovr.graphics.newShader('standard', {
    flags = {
        normalMap = false,
        indirectLighting = true,
        occlusion = true,
        emissive = true,
        skipTonemap = false,
        ambience = true
    }
})

-- shader:send('lovrLightDirection', { -1, -1, -1.5 })
shader:send('lovrLightColor', { 1, 1, 1, 1.0 })
shader:send('lovrExposure', 10)
-- shader:send('liteColor', {1.0, 1.0, 1.0, 1.0})
-- shader:send('lightPos', {2.0, 5.0, 0.0})
shader:send('lovrAmbience', {1, 1, 1, .5})
shader:send('lovrSpecularStrength', 10)
shader:send('lovrMetallic', 128.0)
-- shader:send('viewPos', {0.0, 0.0, 0.0})

return shader

