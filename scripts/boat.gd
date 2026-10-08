extends CharacterBody3D
class_name Boat

# Physics parameters
@export_range(0.0, 30.0) var max_speed: float = 20.0
@export_range(0.0, 20.0) var acceleration: float = 8.0
@export_range(0.0, 4.0) var rudder_turn_speed: float = 1.8
@export_range(0.0, 1.0) var water_drag: float = 0.15
@export_range(0.0, 1.0) var drift_factor: float = 0.25

# Wind system
@export var wind_direction: Vector3 = Vector3(1.0, 0.0, -0.5).normalized()
@export var wind_strength: float = 12.0
@export var wind_gust_speed: float = 0.3
@export var wind_gust_scale: float = 3.0

# Sail and heel
@export_range(0.0, 1.0) var max_heel_angle: float = 0.45
@export_range(0.0, 2.0) var heel_recovery_speed: float = 1.2

# Ocean and bob
@export var bob_amount: float = 0.35
@export var bob_speed: float = 2.0

@onready var ocean: OceanMesh = get_tree().get_first_node_in_group("ocean")

# State
var sail_trim: float = 0.5
var boat_velocity: Vector3 = Vector3.ZERO
var current_heading: float = 0.0
var current_heel: float = 0.0
var rudder_angle: float = 0.0

func _ready() -> void:
	add_to_group("boat")
	current_heading = rotation.y

func _physics_process(delta: float) -> void:
	# Input
	var turn_input := input_axis("turn_left", "turn_right")
	var trim_input := input_axis("move_forward", "move_backward")

	# Sail trim: W = trim in, S = ease out
	sail_trim = clamp(sail_trim + trim_input * 1.2 * delta, 0.0, 1.0)

	# Rudder input and heading update
	rudder_angle = lerp(rudder_angle, turn_input, 0.15)
	current_heading += rudder_angle * rudder_turn_speed * delta
	rotation.y = current_heading

	# Apparent wind from true wind minus boat motion
	var apparent_wind: Vector3 = compute_apparent_wind()

	# Compute sail force based on wind angle and trim
	var sail_force: Dictionary = compute_sail_force(apparent_wind, sail_trim)

	# Heel smoothly follows sail force
	current_heel = lerp(current_heel, sail_force["heel"], heel_recovery_speed * delta)
	rotation.z = current_heel

	# Apply acceleration in the boat's local frame
	var boat_forward: Vector3 = -transform.basis.z.normalized()
	var boat_right: Vector3 = transform.basis.x.normalized()
	var thrust_vector: Vector3 = boat_forward * sail_force["drive"] + boat_right * sail_force["drift"]

	var desired_velocity: Vector3 = boat_velocity + thrust_vector * acceleration * delta
	boat_velocity = boat_velocity.lerp(desired_velocity, 1.0 - water_drag)
	boat_velocity = boat_velocity.lerp(Vector3.ZERO, water_drag * delta)

	if boat_velocity.length() > max_speed:
		boat_velocity = boat_velocity.normalized() * max_speed

	position += boat_velocity * delta

	if ocean:
		var bob := sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_amount
		position.y = ocean.get_ocean_height(position.x, position.z) + bob + 1.1

func compute_apparent_wind() -> Vector3:
	var true_wind: Vector3 = wind_direction.normalized() * wind_strength
	var gust := sin(Time.get_ticks_msec() * 0.001 * wind_gust_speed) * wind_gust_scale
	true_wind *= 1.0 + gust * 0.1

	# Apparent wind = true wind - boat velocity
	return true_wind - boat_velocity

func compute_sail_force(apparent_wind: Vector3, trim: float) -> Dictionary:
	var local_wind: Vector3 = transform.basis.inverse() * apparent_wind
	var wind_speed := local_wind.length()

	if wind_speed < 0.1:
		return {"drive": 0.0, "drift": 0.0, "heel": 0.0}

	# Wind angle relative to the bow:
	# negative/positive values mean wind comes from port/starboard side
	var wind_angle := atan2(local_wind.x, -local_wind.z)

	# The closer to head-to-wind, the worse the sail works.
	var head_to_wind_penalty := max(0.0, 1.0 - abs(wind_angle) / 0.52)

	# Sail trim adjusts how close to the wind the boat can point.
	var sail_angle := lerp(0.3, 0.05, trim)
	var angle_factor := max(0.0, cos(wind_angle - sail_angle) * (1.0 - head_to_wind_penalty * 0.5))

	# Drive is strongest off the beam / broad reach, weak close to the wind.
	var drive := angle_factor * wind_speed * trim * 0.8

	# Lateral force creates drift and heel.
	var lateral := sin(wind_angle) * wind_speed * (1.0 - abs(sail_angle)) * 0.6
	var heel := clamp(lateral * 0.15, -max_heel_angle, max_heel_angle)

	return {
		"drive": drive,
		"drift": lateral * drift_factor,
		"heel": heel
	}

func input_axis(neg_name: String, pos_name: String) -> float:
	var value := 0.0
	if Input.is_action_pressed(neg_name):
		value -= 1.0
	if Input.is_action_pressed(pos_name):
		value += 1.0
	return value
