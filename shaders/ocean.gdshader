shader_type spatial;
render_mode diffuse_lit, specular_smooth;

uniform vec4 albedo_color : source_color = vec4(0.12, 0.44, 0.82, 1.0);
uniform float amplitude = 0.8;
uniform float speed = 0.8;
uniform float frequency = 1.2;

varying float v_wave_height;

void vertex() {
	vec3 v = VERTEX;
	float time = TIME * speed;
	float wave = sin((v.x + time) * frequency) * amplitude;
	wave += sin((v.z * 1.4 + time * 1.2) * frequency) * amplitude * 0.6;
	wave += cos((v.x + v.z) * (frequency * 0.8) + time * 0.9) * amplitude * 0.4;
	v.y = wave;
	VERTEX = v;
	v_wave_height = wave;
}

void fragment() {
	vec3 color = albedo_color.rgb;
	color += vec3(0.0, 0.06, 0.10) * (v_wave_height + 1.0);
	ALBEDO = color;
	ROUGHNESS = 0.25;
	METALLIC = 0.10;
}
