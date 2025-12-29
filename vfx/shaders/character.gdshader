shader_type spatial;

render_mode cull_disabled, depth_draw_always, diffuse_toon, specular_toon;

instance uniform int mask_id = 0;

uniform sampler2D[8] mask_tex_array : filter_nearest;
instance uniform vec3 colour1 : source_color;
instance uniform vec3 colour2 : source_color;
instance uniform vec3 colour3 : source_color;

uniform float metal_metallic = 0.4;

uniform sampler2D dented_heightmap;
uniform float dented_heightmap_strength;

uniform sampler2D covered_metal_height;
uniform float covered_metal_height_strength;

uniform sampler2D chainmail_normal : filter_nearest;

uniform sampler2D clean_metal_tex : filter_nearest;

/**
* ALPHA 0: SKIN
*
* ALPHA 1: METAL
* - R: rust
* - G: dents
* - B: 
*
* ALPHA 2: CLOTH
* - R: tatter (holes)
* - G: wind strength
* - B: droopiness
* 
* ALPHA 3: CLOTH COVERED METAL
* - R: tatter
* - G : fresnel/velvet
*
* ALPHA 4: CHAINMAIL (+padding under)
* - R: tatter
*
* ALPHA 5: LEATHER
* - R: tatter
* - dents
* - age
*/
instance uniform vec4 material_attributes;



// function from https://github.com/pixezy/height_normal
vec3 heightToNormal(float height,float strength,vec3 vertex,vec3 normal){

	vec3 worldDerivativeX = dFdx(vertex);
    vec3 worldDerivativeY = dFdy(vertex);
	
    vec3 crossX = cross(normal, worldDerivativeX);
    vec3 crossY = cross( worldDerivativeY,normal);	
    float d = dot(worldDerivativeX,crossY);
    float sgn = d < 0.0 ? (-1.0) : 1.0;
    float surface = sgn / max(0.00000000000001192093, abs(d));

    float dHdx = dFdx(height);
    float dHdy = dFdy(height);
    vec3 surfGrad = surface * (dHdx*crossY + dHdy*crossX);
    return normalize(normal - (strength * surfGrad));
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 mask = texture(mask_tex_array[mask_id], UV).rgb;
	
	float height = mask.r * 1.0;
	
	ALBEDO = mask.b > 0.1? mask.b > 0.6? colour3 : colour2 : colour1;
	ALPHA = 1.0 - mask.g;
	ROUGHNESS = 0.0;
	
	if(material_attributes.a == 1.0){
		METALLIC = metal_metallic;
		
		height += texture(dented_heightmap, UV).r * dented_heightmap_strength * material_attributes.g;
		NORMAL = heightToNormal(height, 3.0, VERTEX, NORMAL);
		
		ALBEDO *= texture(clean_metal_tex, UV * 2.0).r;
	}
	
	
	//cloth covered metal
	if(material_attributes.a == 3.0){
		height += texture(covered_metal_height, UV).r * covered_metal_height_strength;
		NORMAL = heightToNormal(height, 3.0, VERTEX, NORMAL);
		
		
		if(material_attributes.b > 0.0 && mask.b == 0.0) ALBEDO += fresnel(2.0, NORMAL, VIEW)*material_attributes.b;
		if(mask.b > 0.4 && mask.b < 0.6) METALLIC = metal_metallic;
	}
	
	//chainmail
	if(material_attributes.a == 4.0){
		if(mask.b < 0.9){
			vec4 chain_norm = texture(chainmail_normal, UV*6.0);
			NORMAL = chain_norm.rgb * 3.0;
			NORMAL_MAP = chain_norm.rgb;
			NORMAL_MAP_DEPTH = 500.0;
			ALBEDO = chain_norm.a == 0.0? colour2 : colour1;
			if(chain_norm.a > 0.5) METALLIC = metal_metallic;
		}
		else NORMAL = heightToNormal(height, 3.0, VERTEX, NORMAL);
	}
}
