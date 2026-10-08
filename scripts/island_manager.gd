extends Node3D
class_name IslandManager

func _ready() -> void:
	# Create a few islands for navigation
	_create_island(Vector3(80, 0, -120), 25.0)
	_create_island(Vector3(-100, 0, 80), 30.0)
	_create_island(Vector3(120, 0, 120), 20.0)

func _create_island(position: Vector3, radius: float) -> void:
	var island = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = radius * 0.5
	sphere_mesh.height = radius
	island.mesh = sphere_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.6, 0.5, 0.3)
	material.roughness = 0.8
	island.set_surface_override_material(0, material)
	
	island.position = position + Vector3(0, radius * 0.25, 0)
	add_child(island)
	
	# Add a simple collision shape
	var collision = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = radius * 0.5
	collision_shape.shape = sphere_shape
	collision.add_child(collision_shape)
	collision.position = position + Vector3(0, radius * 0.25, 0)
	add_child(collision)
