float flow_power_from_time(float t){
	return clamp(1.5 * (1.0 - abs(t - 0.5) * 2.0), 0.0, 1.0);
}

vec4 sample_flowmap(vec2 uv, sampler2D tex, vec2 flow){
	float t_a = fract(TIME);
	vec2 uv_a = uv + flow * t_a;
	float p_a = flow_power_from_time(t_a);
	
	float t_b = fract(TIME + 0.33333);
	vec2 uv_b = uv + flow * t_b + vec2(0.33333);
	float p_b = flow_power_from_time(t_b);
	
	float t_c = fract(TIME + 0.66666);
	vec2 uv_c = uv + flow * t_c + vec2(0.66666);;
	float p_c = flow_power_from_time(t_c);
	
	return (texture(tex, uv_a) * p_a + texture(tex, uv_b) * p_b + texture(tex, uv_c) * p_c) / 2.0;
}