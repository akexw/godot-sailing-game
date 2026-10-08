extends MeshInstance3D
class_name OceanMesh

@export var size: Vector2 = Vector2(200, 200)
@export var subdivisions: int = 120
@export var amplitude: float = 0.8
@export var speed: float = 0.8
@export var frequency: float = 1.2
@export var ocean_color: Color = Color(0.12, 0.44, 0.82, 1.0)

func _ready() -> void:
	_build_mesh()
	add_to_group("ocean")

func _build_mesh() -> void:
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = size
	plane.subdivide_depth = subdivisions
	plane.subdivide_width = subdivisions
	mesh = plane

	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = preload("res://shaders/ocean.gdshader")
	material.set_shader_parameter("albedo_color", ocean_color)
	material.set_shader_parameter("amplitude", amplitude)
	material.set_shader_parameter("speed", speed)
	material.set_shader_parameter("frequency", frequency)
	set_surface_override_material(0, material)

func get_ocean_height(x: float, z: float) -> float:
	var time: float = Time.get_ticks_msec() * 0.001 * speed
	var height: float = sin((x + time) * frequency) * amplitude
	height += sin((z * 1.4 + time * 1.2) * frequency) * amplitude * 0.6
	height += cos((x + z) * (frequency * 0.8) + time * 0.9) * amplitude * 0.4
	return height
