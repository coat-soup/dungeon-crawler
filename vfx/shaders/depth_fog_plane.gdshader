shader_type spatial;

uniform vec4 primary_color : source_color;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

instance uniform bool invert_y = false;

uniform float depth_distance : hint_range(0.0, 20.0, 0.1) = 5.0;

render_mode shadows_disabled, depth_draw_never, unshaded;

void vertex() {
	// Called for every vertex the material is visible on.
}


void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float depth_texture_y = world.y/world.w;
	float vertex_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	
	float depth_blend = clamp((invert_y ? (depth_texture_y - vertex_y) : (vertex_y - depth_texture_y)) / depth_distance, 0.0, 1.0);
	
	vec4 col = texture(screen_texture, SCREEN_UV);
	ALBEDO = mix(col, primary_color, depth_blend).rgb;
}

/*
void fragment() {
	
	// Sample depth, but we’ll only use it as a distance measure
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view_pos = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view_pos /= view_pos.w;

	// View-space depth
	float view_depth = -view_pos.z;

	// Get fragment’s local Y (plane’s own up direction)
	float local_y = VERTEX.y;

	// Compute fog amount: local Y vs. distance-based depth
	float depth_blend = clamp((local_y + view_depth) / depth_distance, 0.0, 1.0);

	vec4 col = texture(screen_texture, SCREEN_UV);
	ALBEDO = mix(primary_color, col, depth_blend).rgb;
*/

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
