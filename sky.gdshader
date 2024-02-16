shader_type sky;

uniform vec3 skyColor: source_color;
uniform vec3 bottomColor: source_color;

void sky() {
	if (EYEDIR.y > 0.0) {
		COLOR = skyColor;
	} else {
		COLOR = bottomColor;
	}
}
