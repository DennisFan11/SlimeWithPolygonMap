shader_type canvas_item;
varying mat4 world_to_screen;
varying mat4 screen_to_world;
varying vec2 rot;
uniform float offset = 0;
uniform float angle = 0;
uniform int ma = 20;
void vertex(){
	world_to_screen = SCREEN_MATRIX * CANVAS_MATRIX;
	screen_to_world = inverse(world_to_screen);
	rot = vec2(cos(angle), sin(angle));

}
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;
void fragment(){
	vec2 uv = SCREEN_UV;
	COLOR = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);


	int i = 0;
	while (COLOR.a <= 0.4 && i <= ma){
		i+=1;
		// Puts uv in world space
		uv = uv * 2.0 - 1.0;
		uv = (screen_to_world * vec4(uv,0,1)).xy;
		//offset
		uv += rot * offset;
		// Puts uv back in screen space
		uv = (world_to_screen * vec4(uv,0,1)).xy;
		uv = uv * 0.5 + 0.5;

		COLOR = textureLod(SCREEN_TEXTURE, uv, 0.0);
		//vec4 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
		//if (c.a > 0.0001) {
	        //c.rgb /= c.a;
	    //}
	    //COLOR *= c;

		//COLOR.rgb *= vec3(0.4,0.4,0.4);
	}
	//vec4 c = textureLod(SCREEN_TEXTURE, uv, 0.0);
	//if (c.a > 0.0001) {
        //c.rgb /= c.a;
    //}
    //COLOR *= c;
}