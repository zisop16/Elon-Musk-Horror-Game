shader_type canvas_item;
uniform float bloodiness : hint_range(0, 1, .01) = 1.;
uniform float dist_exponent : hint_range(0, 5, .01) = 1.;
uniform float alpha_offset: hint_range(0, 1, .01) = 0.1;
uniform float brightness: hint_range(0, 1, .01) = .5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 offset = UV - vec2(.5, .5);
	float dist_sq = dot(offset, offset);
	float blood_factor = pow(dist_sq, dist_exponent / 2.) * bloodiness * 5.;
	COLOR.a *= blood_factor;
	COLOR.a -= alpha_offset;
	COLOR.rgb *= brightness;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
