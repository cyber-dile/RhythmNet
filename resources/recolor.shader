shader_type canvas_item;

uniform vec4 color;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	COLOR = vec4(color[0],color[1],color[2],COLOR[3]);
}