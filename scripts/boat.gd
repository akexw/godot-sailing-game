extends CharacterBody3D
class_name Boat

@export_range(0.0, 30.0) var max_speed: float = 18.0
@export_range(0.0, 20.0) var acceleration: float = 7.5
@export_range(0.0, 4.0) var rudder_turn_speed: float = 1.6
@export_range(0.0, 1.0) var drift_amount: float = 0.35
@export var wind_direction: Vector3 = Vector3(1.0, 0.0, 0.0)
@export var wind_strength: float = 12.0
@export var bob_amount: float = 0.35
@export var bob_speed: float = 2.0

@onready var ocean: OceanMesh = get_tree().get_first_node_in_group("ocean")

var sail_trim: float = 0.5
var boat_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	add_to_group("boat")

func _physics_process(delta: float) -> void:
	var turn_input := input_axis("turn_left", "turn_right")
	var trim_input := input_axis("move_forward", "move_backward")

	# Sail trim: W pulls the sail in and increases drive; S eases it out.
	sail_trim = clamp(sail_trim + trim_input * 1.2 * delta, 0.0, 1.0)

	# Rudder steering
	rotation.y += turn_input * rudder_turn_speed * delta

	var local_wind := transform.basis.inverse() * wind_direction.normalized()
	var head_to_wind := clamp(-local_wind.z, 0.0, 1.0)
	var beam_wind := abs(local_wind.x)
	var sailing_power := clamp((beam_wind * 1.2) - (head_to_wind * 0.9) + ((sail_trim - 0.5) * 0.8), 0.0, 1.0)

	# Real sailing behavior: best when wind is off the beam, poor when pointed into the wind.
	var forward := -transform.basis.z.normalized()
	var side_force := transform.basis.x.normalized() * local_wind.x * max_speed * drift_amount
	var drive := forward * max_speed * sailing_power * 0.9
	var target_velocity := drive + side_force

	# This creates a simple but realistic feel: you can sail in a broad arc, but not directly into the wind.
	boat_velocity.x = lerp(boat_velocity.x, target_velocity.x, acceleration * delta)
	boat_velocity.z = lerp(boat_velocity.z, target_velocity.z, acceleration * delta)
	boat_velocity.y = 0.0
	position += boat_velocity * delta

	if ocean:
		var bob := sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_amount
		position.y = ocean.get_ocean_height(position.x, position.z) + bob + 1.1

func input_axis(neg_name: String, pos_name: String) -> float:
	var value := 0.0
	if Input.is_action_pressed(neg_name):
		value -= 1.0
	if Input.is_action_pressed(pos_name):
		value += 1.0
	return value
