#version 150
// ^ Change this to version 130 if you have compatibility issues

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform sampler2D u_Sampler;
uniform sampler2D u_NormalMap;
uniform sampler2D u_Grey;
uniform int u_Time;
uniform vec3 u_Eye;
// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_UVs;
in vec4 fs_Tan;
in vec4 fs_Pos;
out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

void main()
{
    // Material base color (before shading)
        vec4 diffuseColor = fs_Col;
        vec3 bitan=normalize(cross(fs_Tan.xyz,fs_Nor.xyz));
        mat3 TBN=mat3(fs_Tan.xyz,bitan,fs_Nor.xyz);
        vec2 uv=fs_UVs.xy;
        if(fs_UVs.w==1){
            uv.x=fs_UVs.x+(u_Time%250)*0.00025;
           // uv.y=fs_UVs.y+(u_Time%250)*0.00025;
        }
        diffuseColor=texture(u_Sampler,uv);
        if(fs_UVs.w==2){
            vec2 uv_mix=uv;
            uv_mix.x=fs_UVs.x+4*0.0625+(u_Time%500)*0.000125;
            uv_mix.y=fs_UVs.y+11*0.0625;

            float weight_fire=u_Time%900;
            diffuseColor=(100*texture(u_Sampler,uv)+texture(u_Sampler,uv_mix)*(weight_fire/3))/(100+weight_fire/3);
            diffuseColor.a=1;
        }
        else if(fs_UVs.w==3){
            diffuseColor=texture(u_Grey,uv);
            float x=(sin(fs_Pos.x)+1)/2.0;
            float z=(sin(fs_Pos.z)+1)/2.0;
            diffuseColor.rgb=diffuseColor.rgb+vec3(x,1,z);
           diffuseColor.rgb = clamp(diffuseColor.rgb, 0.0, 1.0);
        }
        vec4 mapnormal=texture(u_NormalMap,uv);

        float x=sin(u_Time/200.0f);
        vec4 LightVec=vec4(x,1,0,0);
        vec4 n=normalize(mapnormal*2.0-1.0);
        n=vec4(TBN*n.xyz,0);
        vec4 eye=vec4(u_Eye,0);
        vec4 V=normalize(eye-fs_Pos);
        //vec4 L=normalize(fs_LightVec);
        vec4 L=normalize(LightVec);
        vec4 H=normalize(V+L);
        float shininess=fs_UVs.z;
        //float S= max(pow(dot(H,n),fs_UVs.z),0);
         float S=pow(max(dot(n,H), 0.0),shininess);
          //
        //S = clamp(S, 0.0, 1.0);
        // Calculate the diffuse term for Lambert shading
       // float diffuseTerm = dot(normalize(fs_Nor), normalize(fs_LightVec));
       //float diffuseTerm = dot(normalize(n), normalize(fs_LightVec));
          float diffuseTerm = dot(normalize(n), normalize(LightVec))*(abs(sin(u_Time/300.0f)));
        // Avoid negative lighting values
        diffuseTerm = clamp(diffuseTerm, 0, 1);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm +S;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color

        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);

       // out_Col = vec4(diffuseColor.rgb * lightIntensity, 0.2);

}
