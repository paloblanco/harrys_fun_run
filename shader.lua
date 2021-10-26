customVertex = [[
    vec4 position(mat4 projection, mat4 transform, vec4 vertex)
    {
        return projection * transform * vertex;
    }
]]

defaultVertex = [[
    out vec3 FragmentPos;
    out vec3 Normal;

    vec4 position(mat4 projection, mat4 transform, vec4 vertex) 
    { 
        Normal = lovrNormalMatrix * lovrNormal;
        FragmentPos = vec3(lovrModel * vertex);
        
        return projection * transform * vertex; 
    }
]]

-- customFragment = [[
--     vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
--     {
--         return graphicsColor * lovrDiffuseColor * vertexColor * texture(image, uv);
--         }
-- ]]

customFragment = [[
    uniform vec4 ambience;
    vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
    {
        //object color
        vec4 baseColor = graphicsColor * texture(image, uv);
        return baseColor * ambience;
    }
]]

defaultFragment = [[
    uniform vec4 ambience;
    
    uniform vec4 liteColor;
    uniform vec3 lightPos;

    in vec3 Normal;
    in vec3 FragmentPos;
    
    vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
    {    
        //diffuse
        vec3 norm = normalize(Normal);
        vec3 lightDir = normalize(lightPos - FragmentPos);
        float diff = max(dot(norm, lightDir), 0.0);
        vec4 diffuse = diff * liteColor;
                        
        vec4 baseColor = graphicsColor * texture(image, uv);            
        return baseColor * (ambience + diffuse);
    }
]]

shader = lovr.graphics.newShader(defaultVertex, defaultFragment, {})

shader:send('ambience', { 0.2, 0.2, 0.2, 1.0 })
shader:send('liteColor', {1.0,1.0,1.0,1.0})
shader:send('lightPos', {2.0,5.0,0})


return shader

