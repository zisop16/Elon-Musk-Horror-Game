shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = texture(screen_texture, UV).rgb;
}
