shader_type canvas_item;
// A faint washi grain over everything: fine speckle and long fibres.

uniform float strength = 0.07;
// The grain's colour, and a wash of it over everything (sepia for the menus).
uniform vec3 tint = vec3(1.0);
uniform float wash = 0.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 p = FRAGCOORD.xy;
	float speckle = hash(floor(p / 1.5));
	float fibre = hash(vec2(floor(p.x / 40.0 + p.y * 0.07), floor(p.y / 3.0)));
	float grain = mix(speckle, fibre, 0.35);
	vec3 fleck = grain > 0.5 ? tint : tint * 0.25;
	float a = abs(grain - 0.5) * strength * 2.0;
	COLOR = vec4(mix(tint, fleck, a / max(a + wash, 0.0001)), a + wash);
}
