shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	//float a = 1.0 - ceil(texture(screen_texture, SCREEN_UV).a);
	////COLOR = texture(TEXTURE, UV);
	//COLOR.a *= a;
	COLOR = mix(COLOR, texture(screen_texture, SCREEN_UV), 0.5);
}