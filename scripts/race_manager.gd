extends Node3D
class_name RaceManager

@export var waypoints: Array[Vector3] = [
	Vector3(100, 0, -100),
	Vector3(150, 0, 50),
	Vector3(-50, 0, 150),
	Vector3(-150, 0, -50),
	Vector3(0, 0, 0)
]
@export var waypoint_radius: float = 20.0

var current_waypoint: int = 0
var lap_time: float = 0.0
var boat: Node3D
<<<<<<< HEAD
=======
# test code starts here

>>>>>>> origin/main
var waypoint_buoy: MeshInstance3D

func _ready() -> void:
	boat = get_tree().get_first_node_in_group("boat")
	_create_waypoint_buoy()
	if waypoints.is_empty():
		push_warning("No waypoints defined for race")
	_update_waypoint_buoy()
<<<<<<< HEAD

=======
	
>>>>>>> origin/main
func _process(delta: float) -> void:
	lap_time += delta

	if boat == null:
		boat = get_tree().get_first_node_in_group("boat")

	if boat == null:
		return

	if current_waypoint < waypoints.size():
		var distance_to_waypoint: float = boat.global_position.distance_to(waypoints[current_waypoint])
		if distance_to_waypoint < waypoint_radius:
			current_waypoint += 1
			_update_waypoint_buoy()
			if current_waypoint >= waypoints.size():
				print("Lap complete! Time: %.1f seconds" % lap_time)
				current_waypoint = 0
				lap_time = 0.0
				_update_waypoint_buoy()

<<<<<<< HEAD
=======

>>>>>>> origin/main
func _create_waypoint_buoy() -> void:
	waypoint_buoy = MeshInstance3D.new()
	var buoy_mesh: CylinderMesh = CylinderMesh.new()
	buoy_mesh.top_radius = 1.0
	buoy_mesh.bottom_radius = 1.0
	buoy_mesh.height = 3.0
	waypoint_buoy.mesh = buoy_mesh
<<<<<<< HEAD

=======
>>>>>>> origin/main
	var buoy_material: StandardMaterial3D = StandardMaterial3D.new()
	buoy_material.albedo_color = Color(1.0, 0.75, 0.2)
	buoy_material.emission_enabled = true
	buoy_material.emission = Color(1.0, 0.6, 0.0)
	buoy_material.emission_energy_multiplier = 0.5
	waypoint_buoy.material_override = buoy_material
	add_child(waypoint_buoy)
	waypoint_buoy.visible = false
<<<<<<< HEAD

=======
>>>>>>> origin/main
func _update_waypoint_buoy() -> void:
	if waypoint_buoy == null:
		return
	if waypoints.is_empty():
		waypoint_buoy.visible = false
		return
	waypoint_buoy.position = waypoints[current_waypoint] + Vector3(0.0, 1.5, 0.0)
	waypoint_buoy.visible = true
<<<<<<< HEAD

=======
>>>>>>> origin/main
func get_distance_to_waypoint(target_position: Vector3) -> float:
	if current_waypoint < waypoints.size():
		return target_position.distance_to(waypoints[current_waypoint])
	return 0.0
<<<<<<< HEAD

=======
>>>>>>> origin/main
func get_waypoint_heading(target_position: Vector3) -> float:
	if current_waypoint < waypoints.size():
		var direction: Vector3 = waypoints[current_waypoint] - target_position
		return rad_to_deg(atan2(direction.x, -direction.z))
	return 0.0
