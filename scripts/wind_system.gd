extends Node3D

@export var wind_direction: Vector3 = Vector3(1.0, 0.0, -0.5).normalized()
@export var wind_strength: float = 12.0
@export var wind_gust_speed: float = 0.3
@export var wind_gust_scale: float = 3.0

var boat: Boat

func _ready() -> void:
	boat = get_tree().get_first_node_in_group("boat") as Boat
	if boat:
		boat.wind_direction = wind_direction
		boat.wind_strength = wind_strength
		boat.wind_gust_speed = wind_gust_speed
		boat.wind_gust_scale = wind_gust_scale

func set_wind(direction: Vector3, strength: float) -> void:
	wind_direction = direction.normalized()
	wind_strength = strength
	if boat:
		boat.wind_direction = wind_direction
		boat.wind_strength = wind_strength
