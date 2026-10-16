extends MeshInstance3D
class_name OceanMesh

# x,y = direction, z = relative amplitude, w = relative frequency (matches ocean.gdshader)
const WAVES: Array[Vector4] = [
	Vector4(1.0, 0.2, 1.00, 0.20),
	Vector4(0.6, 0.8, 0.60, 0.33),
	Vector4(-0.5, 0.9, 0.35, 0.55),
	Vector4(0.9, -0.6, 0.20, 0.90),
	Vector4(-0.8, -0.4, 0.12, 1.50),
	Vector4(0.3, -1.0, 0.07, 2.40),
]

var _target: Node3D

@export var size: Vector2 = Vector2(600, 600)
@export var subdivisions: int = 300
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

func _process(_delta: float) -> void:
	if _target == null:
		_target = get_tree().get_first_node_in_group("boat") as Node3D
	if _target == null:
		return
	# Snap to the vertex grid so the waves (computed in world space) don't swim
	var cell: Vector2 = Vector2(size.x / subdivisions, size.y / subdivisions)
	var p: Vector3 = _target.global_position
	global_position = Vector3(snappedf(p.x, cell.x), 0.0, snappedf(p.z, cell.y))

func get_ocean_height(x: float, z: float) -> float:
	var t: float = Time.get_ticks_msec() * 0.001 * speed
	var h: float = 0.0
	for w in WAVES:
		var d: Vector2 = Vector2(w.x, w.y).normalized()
		var k: float = w.w * frequency
		var phase: float = (d.x * x + d.y * z) * k + t * sqrt(k) * 2.0
		var s: float = sin(phase) * 0.5 + 0.5
		h += (s * s * 2.0 - 1.0) * w.z * amplitude * 0.5
	return h
