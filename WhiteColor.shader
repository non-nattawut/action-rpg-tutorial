shader_type canvas_item;

uniform bool active = true; // uniform = export

void fragment() { //#execute on every pixerl
	vec4 previous_color = texture(TEXTURE , UV); // sprite ทัั้งอัน
	vec4 white_color = vec4(1.0, 1.0, 1.0, previous_color.a);
	vec4 new_color = previous_color;
	if (active == true){
		new_color = white_color;
	}
	COLOR = new_color; //RGB and alpha -> RGBA
}