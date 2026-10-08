extends MeshInstance3D

class_name OceanMesh

# Ocean parameters
@export var grid_size: int = 128
@export var grid_scale: float = 1.0
@export var amplitude: float = 0.3
@export var wave_speed: float = 1.0
@export var wave_frequency: float = 1.0

# Mesh data
var mesh_data: MeshDataTool
var plane_mesh: PlaneMesh
var original_vertices: PackedVector3Array
var current_vertices: PackedVector3Array
var surface_index: int = 0

func _ready() -> void:
	# Create initial plane mesh
	plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(grid_size * grid_scale, grid_size * grid_scale)
	plane_mesh.subdivisions = Vector2i(grid_size, grid_size)
	
	# Set the mesh and create material
	mesh = plane_mesh
	
	# Setup mesh data tool for vertex manipulation
	mesh_data = MeshDataTool.new()
	mesh_data.create_from_surface(mesh, surface_index)
	
	# Store original vertex positions
	original_vertices = PackedVector3Array()
	for i in range(mesh_data.get_vertex_count()):
		original_vertices.append(mesh_data.get_vertex(i))
	
	current_vertices = original_vertices.duplicate()
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.0, 0.5, 0.8, 1.0)
	material.metallic = 0.5
	material.roughness = 0.2
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	set_surface_override_material(0, material)

func _process(delta: float) -> void:
	# Update vertex positions based on wave function
	for i in range(mesh_data.get_vertex_count()):
		var vertex = original_vertices[i]
		var x = vertex.x
		var z = vertex.z
		
		# Gerstner wave formula for more realistic waves
		var time = Time.get_ticks_msec() / 1000.0 * wave_speed
		
		# Wave 1: primary direction
		var wave1 = sin(x * wave_frequency + time) * amplitude
		wave1 += sin(z * wave_frequency * 0.7 + time * 0.8) * amplitude * 0.5
		
		# Wave 2: secondary direction for more complex waves
		var wave2 = cos(z * wave_frequency * 0.5 + time * 0.6) * amplitude * 0.7
		wave2 += cos(x * wave_frequency * 0.3 + time * 0.4) * amplitude * 0.3
		
		# Combine waves
		var y = wave1 + wave2
		
		# Add slight choppiness
		var chop = sin((x + z) * wave_frequency * 1.5 + time * 1.2) * amplitude * 0.2
		y += chop
		
		current_vertices[i] = Vector3(x, y, z)
		mesh_data.set_vertex(i, current_vertices[i])
	
	# Update the mesh
	mesh = mesh_data.commit_to_surface(mesh)

# Function to adjust wave parameters at runtime
func set_wave_params(new_amplitude: float, new_speed: float, new_frequency: float) -> void:
	amplitude = new_amplitude
	wave_speed = new_speed
	wave_frequency = new_frequency

# Function to get ocean height at a specific position (for boat floating)
func get_ocean_height(x: float, z: float) -> float:
	var time = Time.get_ticks_msec() / 1000.0 * wave_speed
	
	var wave1 = sin(x * wave_frequency + time) * amplitude
	wave1 += sin(z * wave_frequency * 0.7 + time * 0.8) * amplitude * 0.5
	
	var wave2 = cos(z * wave_frequency * 0.5 + time * 0.6) * amplitude * 0.7
	wave2 += cos(x * wave_frequency * 0.3 + time * 0.4) * amplitude * 0.3
	
	var chop = sin((x + z) * wave_frequency * 1.5 + time * 1.2) * amplitude * 0.2
	
	return wave1 + wave2 + chop
