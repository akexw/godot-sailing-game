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
@export var sail_max_angle: float = 0.9

# Ocean and bob
@export var bob_amount: float = 0.35
@export var bob_speed: float = 2.0

@onready var ocean: OceanMesh = get_tree().get_first_node_in_group("ocean") as OceanMesh
@onready var sail_mesh: MeshInstance3D = $Sail
@onready var mast_mesh: MeshInstance3D = $Mast

# State
var sail_trim: float = 0.5
var boat_velocity: Vector3 = Vector3.ZERO
var current_heading: float = 0.0
var current_heel: float = 0.0
var rudder_angle: float = 0.0

func _ready() -> void:
	add_to_group("boat")
	current_heading = rotation.y
	if mast_mesh:
		mast_mesh.position = Vector3(0.0, 1.0, 0.0)
	if sail_mesh:
		sail_mesh.position = Vector3(0.0, 1.5, 0.0)

func _physics_process(delta: float) -> void:
	var turn_input: float = input_axis("turn_left", "turn_right")
	var trim_input: float = input_axis("move_forward", "move_backward")

	sail_trim = clamp(sail_trim + trim_input * 1.2 * delta, 0.0, 1.0)
	rudder_angle = lerp(rudder_angle, turn_input, 0.15)
	current_heading += rudder_angle * rudder_turn_speed * delta
	rotation.y = current_heading

	var apparent_wind: Vector3 = compute_apparent_wind()
	var sail_force: Dictionary = compute_sail_force(apparent_wind, sail_trim)

	current_heel = lerp(current_heel, float(sail_force["heel"]), heel_recovery_speed * delta)
	rotation.z = current_heel

	# Use the boat's local +Z as forward, which matches the hull model and camera follow.
	var boat_forward: Vector3 = transform.basis.z.normalized()
	var boat_right: Vector3 = transform.basis.x.normalized()
	var thrust_vector: Vector3 = boat_forward * float(sail_force["drive"]) + boat_right * float(sail_force["drift"])

	var desired_velocity: Vector3 = boat_velocity + thrust_vector * acceleration * delta
	boat_velocity = boat_velocity.lerp(desired_velocity, 1.0 - water_drag)
	boat_velocity = boat_velocity.lerp(Vector3.ZERO, water_drag * delta)

	if boat_velocity.length() > max_speed:
		boat_velocity = boat_velocity.normalized() * max_speed

	position += boat_velocity * delta

	if sail_mesh:
		var sail_rotation: float = lerp(-sail_max_angle, sail_max_angle, sail_trim)
		sail_mesh.rotation.z = sail_rotation + current_heel
		sail_mesh.rotation.x = -0.25
		sail_mesh.rotation.y = deg_to_rad(90.0)
		if mast_mesh:
			mast_mesh.rotation.z = current_heel

	if ocean:
		var bob: float = sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_amount
		position.y = ocean.get_ocean_height(position.x, position.z) + bob + 1.1

func compute_apparent_wind() -> Vector3:
	var true_wind: Vector3 = wind_direction.normalized() * wind_strength
	var gust: float = sin(Time.get_ticks_msec() * 0.001 * wind_gust_speed) * wind_gust_scale
	true_wind *= 1.0 + gust * 0.1
	return true_wind - boat_velocity

func compute_sail_force(apparent_wind: Vector3, trim: float) -> Dictionary:
	var local_wind: Vector3 = transform.basis.inverse() * apparent_wind
	var wind_speed: float = local_wind.length()

	if wind_speed < 0.1:
		return {"drive": 0.0, "drift": 0.0, "heel": 0.0}

	var wind_angle: float = atan2(local_wind.x, -local_wind.z)
	var head_to_wind_penalty: float = max(0.0, 1.0 - abs(wind_angle) / 0.52)
	var sail_angle: float = lerp(0.3, 0.05, trim)
	var angle_factor: float = max(0.0, cos(wind_angle - sail_angle) * (1.0 - head_to_wind_penalty * 0.5))
	var drive: float = angle_factor * wind_speed * trim * 0.8
	var lateral: float = sin(wind_angle) * wind_speed * (1.0 - abs(sail_angle)) * 0.6
	var heel: float = clamp(-lateral * 0.15, -max_heel_angle, max_heel_angle)

	return {
		"drive": drive,
		"drift": lateral * drift_factor,
		"heel": heel
	}

func input_axis(neg_name: String, pos_name: String) -> float:
	var value: float = 0.0
	if Input.is_action_pressed(neg_name):
		value -= 1.0
	if Input.is_action_pressed(pos_name):
		value += 1.0
	return value
