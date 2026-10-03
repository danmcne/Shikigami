shader_type canvas_item;
// A faint washi grain over everything: fine speckle and long fibres.

uniform float strength = 0.07;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 p = FRAGCOORD.xy;
	float speckle = hash(floor(p / 1.5));
	float fibre = hash(vec2(floor(p.x / 40.0 + p.y * 0.07), floor(p.y / 3.0)));
	float grain = mix(speckle, fibre, 0.35);
	COLOR = vec4(vec3(grain > 0.5 ? 1.0 : 0.0), abs(grain - 0.5) * strength * 2.0);
}
