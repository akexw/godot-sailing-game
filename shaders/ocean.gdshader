shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx;

uniform vec4 albedo_color : source_color = vec4(0.12, 0.44, 0.82, 1.0);
uniform float amplitude = 0.8;
uniform float speed = 0.8;
uniform float frequency = 1.2;

// Each wave: xy = direction, z = relative amplitude, w = relative frequency.
// Must match OceanMesh.WAVES in scripts/ocean_mesh.gd.
const vec4 WAVES[6] = vec4[6](
	vec4(1.0, 0.2, 1.00, 0.20),
	vec4(0.6, 0.8, 0.60, 0.33),
	vec4(-0.5, 0.9, 0.35, 0.55),
	vec4(0.9, -0.6, 0.20, 0.90),
	vec4(-0.8, -0.4, 0.12, 1.50),
	vec4(0.3, -1.0, 0.07, 2.40)
);

varying float v_wave_height;
varying vec3 v_normal;

float wave_height(vec2 p, float t) {
	float h = 0.0;
	for (int i = 0; i < 6; i++) {
		vec2 d = normalize(WAVES[i].xy);
		float k = WAVES[i].w * frequency;
		float phase = dot(d, p) * k + t * sqrt(k) * 2.0;
		// Sharpened crest: troughs broad, crests peaked
		float s = sin(phase) * 0.5 + 0.5;
		h += (pow(s, 2.0) * 2.0 - 1.0) * WAVES[i].z * amplitude * 0.5;
	}
	return h;
}

void vertex() {
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME * speed;
	float h = wave_height(world.xz, t);
	float e = 0.25;
	float hx = wave_height(world.xz + vec2(e, 0.0), t);
	float hz = wave_height(world.xz + vec2(0.0, e), t);
	v_normal = normalize(vec3(h - hx, e, h - hz));
	VERTEX.y = h;
	v_wave_height = h;
	NORMAL = normalize((inverse(mat3(MODEL_MATRIX)) * v_normal));
}

void fragment() {
	float crest = smoothstep(0.3, 1.0, v_wave_height / max(amplitude, 0.001));
	vec3 color = mix(albedo_color.rgb * 0.8, albedo_color.rgb + vec3(0.05, 0.18, 0.2), clamp(v_wave_height / max(amplitude, 0.001) * 0.5 + 0.5, 0.0, 1.0));
	color = mix(color, vec3(0.85, 0.93, 1.0), crest * 0.35);
	ALBEDO = color;
	ROUGHNESS = 0.2;
	METALLIC = 0.1;
	SPECULAR = 0.6;
}
