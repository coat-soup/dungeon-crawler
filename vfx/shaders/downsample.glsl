#[compute]
#version 450

layout(set = 0, binding = 0, std430) readonly buffer Params {
    vec2 raster_size;
    vec2 reserved;
    float downsamples;
} params;

layout(rgba16f, set = 0, binding = 1) uniform image2D color_image;

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;


void main() {
    vec2 size = params.raster_size;
    ivec2 uv = ivec2(gl_GlobalInvocationID.xy);
    vec2 un_normalized = uv/size;

    if (uv.x >= size.x || uv.y >= size.y) return;

    ivec2 modified_uv = ivec2(uv.x / params.downsamples, uv.y / params.downsamples);
    modified_uv = ivec2(modified_uv.x * params.downsamples, modified_uv.y * params.downsamples);

    vec4 color = imageLoad(color_image, modified_uv);
    float brightness = (color.r + color.g + color.b) / 3.0;

    imageStore(color_image, uv, color);
}