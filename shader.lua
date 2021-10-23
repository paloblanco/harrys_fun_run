-- shader = lovr.graphics.newShader('standard', {
--     flags = {
--         normalMap = false,
--         indirectLighting = true,
--         occlusion = true,
--         emissive = true,
--         skipTonemap = false,
--         ambience = true
--     }
-- })

-- -- shader:send('lovrLightDirection', { -1, -1, -1.5 })
-- shader:send('lovrLightColor', { 1, 1, 1, 1.0 })
-- shader:send('lovrExposure', 10)
-- -- shader:send('liteColor', {1.0, 1.0, 1.0, 1.0})
-- -- shader:send('lightPos', {2.0, 5.0, 0.0})
-- shader:send('lovrAmbience', {.2, .2, .2, 1})
-- shader:send('lovrSpecularStrength', 10)
-- shader:send('lovrMetallic', 128.0)
-- -- shader:send('viewPos', {0.0, 0.0, 0.0})

customVertex = [[
    vec4 position(mat4 projection, mat4 transform, vec4 vertex)
    {
        return projection * transform * vertex;
    }
]]

customFragment = [[
    vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
    {
        return graphicsColor * lovrDiffuseColor * vertexColor * texture(image, uv);
        }
]]

shader = lovr.graphics.newShader(customVertex, customFragment, {})

return shader

