#[compute]
#version 450

layout(set = 0, binding = 0, std430) readonly buffer Params {
    vec2 raster_size;
    vec2 reserved;
    float levels;
    float gamma;
} params;

layout(rgba16f, set = 0, binding = 1) uniform image2D color_image;

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;


vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


float posterise(in float val){
    val = pow(val, params.gamma);
    val = (floor(val * params.levels) / params.levels);
    return pow(val, 1.0 / params.gamma);
}


float posterise_dither(in float val, in float dither){
    val = pow(val, params.gamma);
    val = (floor(val * params.levels + dither) / params.levels);
    return pow(val, 1.0 / params.gamma);
}


void main() {
    vec2 size = params.raster_size;
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    vec2 un_normalized = uv/size;

    if (uv.x >= size.x || uv.y >= size.y) return;

    vec4 color = imageLoad(color_image, uv);
    vec3 color_hsv = rgb2hsv(color.rgb);
    

    color_hsv.z = posterise(color_hsv.z);
    float dither = fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453);
    //color_hsv.z = posterise_dither(color_hsv.z, dither);

    color = vec4(hsv2rgb(color_hsv), 1.0);

    //color = vec4(hsv2rgb(vec3(187.0/360.0, 61.0/100.0, 51.0/100.0)), 1.0);

    imageStore(color_image, uv, color);
}