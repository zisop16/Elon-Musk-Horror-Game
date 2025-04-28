shader_type spatial;
render_mode cull_disabled, unshaded;

uniform vec3 top_color : source_color;
uniform vec3 bottom_color : source_color;
uniform sampler2D noise;
uniform sampler2D width_curve : filter_linear, repeat_disable;
uniform sampler2D relative_wind_strength : filter_linear, repeat_disable;
uniform sampler2D wind_noise;
uniform float wind_direction : hint_range(0, 7, .01) = 0.;
uniform float wind_strength : hint_range(0, 10, .01) = 2.;
uniform float wind_frequency : hint_range(0, 10, .01) = 2.;
uniform float wind_turbulence : hint_range(0, .1, .001) = .1;

float width_multiplier(float y) {
	y = 1. - y;
	float width_curve_value = texture(width_curve, vec2(y, y)).r;
	return width_curve_value;
}

vec2 wind_direction_vector() {
	float wind_angle = 2. * PI * texture(wind_noise, vec2(TIME * wind_turbulence)).r;
	return vec2(cos(wind_angle), sin(wind_angle));
}



// hash vec2 -> float
float hash( vec2 f )
{   uvec2
          x = floatBitsToUint(f),
          q = 1103515245U * ( x>>1U ^ x.yx    );
    return float( 1103515245U * (q.x ^ q.y>>3U) ) / float(0xffffffffU);
}

vec2 xz_offset(vec3 vert, vec2 uv, vec2 world_pos) {
	float y = 1.-uv.y;
	float width = abs(vert.x);
	float current_wind_strength = wind_strength * sin(TIME * wind_frequency);
	float relative_strength = texture(relative_wind_strength, vec2(y, y)).r;
	vec2 wind = wind_direction_vector() * vec2(current_wind_strength * relative_strength);
	return wind * width;
}

void vertex() {
	vec2 world_pos = (MODEL_MATRIX * vec4( VERTEX, 1.)).xz;
	vec2 offset = xz_offset(VERTEX, UV, world_pos);
	VERTEX.x *= width_multiplier(UV.y);
    VERTEX.xz = normalize(INV_VIEW_MATRIX[0].xz) * VERTEX.x + normalize(INV_VIEW_MATRIX[2].xz) * VERTEX.z;
	VERTEX.xz += offset;
    VERTEX.y = VERTEX.y;

}

void fragment() {
	float height = 1. - UV.y;
	ALBEDO = mix(bottom_color, top_color, height);
}