shader_type spatial;
uniform sampler2D noise_tex;

void fragment() {
	float noise_val = texture(noise_tex, UV).r;
	ALPHA = 0.;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
