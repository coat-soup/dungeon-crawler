shader_type canvas_item;

uniform sampler2D t: hint_screen_texture, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment(){
	COLOR = tint * vec4(textureLod(t, SCREEN_UV, 4.0).rgb, 1.0);
	}