-- from the lovr docs

-- return lovr.graphics.newShader([[
-- // All of these are in view-space.
-- out vec3 lightDirection; // A vector from the vertex to the light
-- out vec3 normalDirection;
-- out vec3 vertexPosition;
-- vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
--   vec3 lightPosition = vec3(4., 10., 3.);
--   vec4 vVertex = transform * vec4(lovrPosition, 1.);
--   vec4 vLight = lovrView * vec4(lightPosition, 1.);
--   lightDirection = normalize(vec3(vLight - vVertex));
--   normalDirection = normalize(lovrNormalMatrix * lovrNormal);
--   vertexPosition = vVertex.xyz;
--   return projection * transform * vertex;
-- }
-- ]], [[
-- in vec3 lightDirection;
-- in vec3 normalDirection;
-- in vec3 vertexPosition;
-- vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
--   vec3 cAmbient = vec3(.25);
--   vec3 cDiffuse = vec3(1.);
--   vec3 cSpecular = vec3(.35);
--   float diffuse = max(dot(normalDirection, lightDirection), 0.);
--   float specular = 0.;
--   if (diffuse > 0.) {
--     vec3 r = reflect(lightDirection, normalDirection);
--     vec3 viewDirection = normalize(-vertexPosition);
--     float specularAngle = max(dot(r, viewDirection), 0.);
--     specular = pow(specularAngle, 5.);
--   }
--   vec3 cFinal = pow(clamp(vec3(diffuse) * cDiffuse + vec3(specular) * cSpecular, cAmbient, vec3(1.)), vec3(.4545));
--   return vec4(cFinal, 1.) * graphicsColor * texture(image, uv);
-- }
-- ]])



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
shader:send('lovrExposure', 5)
-- shader:send('liteColor', {1.0, 1.0, 1.0, 1.0})
-- shader:send('lightPos', {2.0, 5.0, 0.0})
shader:send('lovrAmbience', {.5, .5, .5, 1})
shader:send('lovrSpecularStrength', 100)
shader:send('lovrMetallic', 128.0)
-- shader:send('viewPos', {0.0, 0.0, 0.0})




return shader

