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

func _ready() -> void:
	boat = get_tree().get_first_node_in_group("boat")
	if waypoints.is_empty():
		push_warning("No waypoints defined for race")

func _process(delta: float) -> void:
	lap_time += delta

	if boat and current_waypoint < waypoints.size():
		var distance_to_waypoint: float = boat.global_position.distance_to(waypoints[current_waypoint])
		if distance_to_waypoint < waypoint_radius:
			current_waypoint += 1
			if current_waypoint >= waypoints.size():
				print("Lap complete! Time: %.1f seconds" % lap_time)
				current_waypoint = 0
				lap_time = 0.0

func get_distance_to_waypoint(position: Vector3) -> float:
	if current_waypoint < waypoints.size():
		return position.distance_to(waypoints[current_waypoint])
	return 0.0

func get_waypoint_heading(position: Vector3) -> float:
	if current_waypoint < waypoints.size():
		var direction: Vector3 = waypoints[current_waypoint] - position
		return rad_to_deg(atan2(direction.x, -direction.z))
	return 0.0
