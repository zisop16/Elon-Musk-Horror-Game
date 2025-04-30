// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_enable;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

uniform sampler2D texture_normal : hint_roughness_normal, filter_linear_mipmap, repeat_enable;
uniform float normal_scale : hint_range(-16.0, 16.0);

uniform sampler2D texture_emission : source_color, hint_default_black, filter_linear_mipmap, repeat_enable;
uniform vec4 emission : source_color;
uniform float emission_energy : hint_range(0.0, 100.0, 0.01) = 0;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

uniform sampler2D dissolve_noise;
uniform bool enable_dissolve = false;
uniform float dissolve_start_time;
uniform float dissolve_duration : hint_range(0, 10, .1) = 3;
global uniform float game_time;

uniform bool enable_face_glitch = false;
uniform sampler2D face_noise : filter_nearest;
uniform float face_noise_speed : hint_range(0, 200, .01);

vec3 hash( vec3 p )
{
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
			  dot(p,vec3(269.5,183.3,246.1)),
			  dot(p,vec3(113.5,271.9,124.6)));

	return fract(sin(p)*43758.5453123);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

float luminance(vec3 linear) { 
	return dot(linear, vec3(0.21250175, 0.71537574, 0.07212251)); 
}

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;

	float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	SPECULAR = specular;

	vec4 roughness_texture_channel = vec4(0.0, 1.0, 0.0, 0.0);
	float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	// Emission: Enabled
	vec3 emission_tex = texture(texture_emission, base_uv).rgb;
	// Emission Operator: Add
	EMISSION = (emission.rgb + emission_tex) * emission_energy;
	
	// Normal Map: Enabled
	NORMAL_MAP = texture(texture_normal, base_uv).rgb;
	NORMAL_MAP_DEPTH = normal_scale;
	
	if (enable_face_glitch) {
		float noise_value = texture(face_noise, UV).r;
		float time_rounded = round(fract(TIME) * face_noise_speed);
		vec3 hash_col = hash(vec3(noise_value, time_rounded, 0.));
		float lum = luminance(ALBEDO);
		lum = pow(lum, 1.5) * 5.;
		vec3 hsv = vec3(hash_col.r, mix(.9, 1., hash_col.g), lum);
		vec3 col = hsv2rgb(hsv);
		float original_component = .1;
		ALBEDO = mix(col, ALBEDO, original_component);
	}
		
	if (enable_dissolve) {
		float noise_value = texture(dissolve_noise, UV).r;
		float time_factor = (game_time - dissolve_start_time) / dissolve_duration;
		float erosion = noise_value * pow(time_factor, .6);
		float erosion_threshold = .3;
		if (erosion > erosion_threshold) {
			ALPHA = 0.;
		} else {
			ALPHA = 1.;
		}
		
		float grey_value = (ALBEDO.r + ALBEDO.g + ALBEDO.b) / 3.;
		grey_value = pow(grey_value, 3.);
		vec3 grey_col = vec3(grey_value);
		// Dissolved object will be fully grey faster than it is fully dissolved
		float grey_speed = 1.7;
		float greyness = smoothstep(0., 1., time_factor * grey_speed);
		vec3 combined_col = mix(ALBEDO, grey_col, greyness);
		ALBEDO = combined_col;
	}
	
}
