shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	float a = floor(texture(SCREEN_TEXTURE, SCREEN_UV).a*4.0)/4.0;
	
	COLOR.rgb = vec3(a, a, a);
	COLOR.rgb -= 0.20;
	COLOR.a = ceil(a);
	//COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
}
