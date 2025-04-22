shader_type canvas_item;
render_mode blend_mix;

uniform float outLineSize: hint_range(0, .05, .001)  = 0.02;
uniform vec3 outline_color: source_color = vec3(0., 0., 0.);
uniform float custom_alpha: hint_range(0, 1, .01) = .4;

void fragment()
{
    vec4 tcol = texture(TEXTURE, UV);

    if (tcol.a == 0.0)
    {
        if (texture(TEXTURE, UV + vec2(0.0,          outLineSize)).a  != 0.0 ||
            texture(TEXTURE, UV + vec2(0.0,         -outLineSize)).a  != 0.0 ||
            texture(TEXTURE, UV + vec2(outLineSize,  0.0)).a          != 0.0 ||
            texture(TEXTURE, UV + vec2(-outLineSize, 0.0)).a          != 0.0 ||
            texture(TEXTURE, UV + vec2(-outLineSize, outLineSize)).a  != 0.0 ||
            texture(TEXTURE, UV + vec2(-outLineSize, -outLineSize)).a != 0.0 ||
            texture(TEXTURE, UV + vec2(outLineSize,  outLineSize)).a  != 0.0 ||
            texture(TEXTURE, UV + vec2(outLineSize,  -outLineSize)).a != 0.0) {
            	tcol.rgb = outline_color;
				tcol.a = custom_alpha;
			}
    } else {
		tcol.a = custom_alpha;
	}
    COLOR = tcol;
}