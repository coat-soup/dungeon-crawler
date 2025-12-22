shader_type spatial;

#include "res://vfx/shaders/flowmaps.gdshaderinc"

uniform sampler2D noise_tex;
uniform float flow_speed;
uniform vec3 water_color : source_color;

render_mode cull_disabled, depth_prepass_alpha;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 flow = vec2(0.0,-1.0) * flow_speed;
	flow *= (1.0 + sin(PI * UV.x))/2.0;
	ALBEDO = sample_flowmap(UV * vec2(0.1, 1.0), noise_tex, flow).rgb;
	
	float transition = sin(PI * UV.x) * ALBEDO.r;
	
	ALBEDO = mix(water_color, vec3(1.0), clamp(ALBEDO.r - 1.0 + transition * 2.0, 0.0, 1.0));
	ALPHA = mix(0.2, 1.0, clamp(ALBEDO.r - 1.0 + transition * 2.0, 0.0, 1.0));
}