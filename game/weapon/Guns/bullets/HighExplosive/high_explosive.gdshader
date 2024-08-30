shader_type canvas_item;
uniform sampler2D curve;
void fragment() {
	vec3 c1 = vec3(1.0,0.0,0.0);
	vec3 c2 = vec3(1.0,1.0,0.0);
	
	vec2 center = vec2(0.5,0.5);
	float dist = length(UV-center); // 0.0 ~ 0.5
	if (dist>=0.5){
		discard;
	}
	float x = 1.0-(dist*2.0);
	x = texture(curve, vec2(x,0.0)).r;
	COLOR.rgb = vec3(1.0, x, 0.0);
	COLOR.a *= 1.5;
}
