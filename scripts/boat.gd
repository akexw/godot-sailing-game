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
var target_heading: float = 0.0
var current_heel: float = 0.0
var rudder_angle: float = 0.0

func _ready() -> void:
	add_to_group("boat")
	current_heading = rotation.y

func _physics_process(delta: float) -> void:
	# Input
	var turn_input := input_axis("turn_left", "turn_right")
	var trim_input := input_axis("move_forward", "move_backward")
	
	# Sail trim (W/S)
	sail_trim = clamp(sail_trim + trim_input * 1.2 * delta, 0.0, 1.0)
	
	# Rudder input (A/D)
	rudder_angle = lerp(rudder_angle, turn_input, 0.15)
	current_heading += rudder_angle * rudder_turn_speed * delta
	
	# Update rotation from heading
	rotation.y = current_heading
	
	# Get apparent wind
	var apparent_wind = compute_apparent_wind(delta)
	
	# Calculate sail force and heel
	var sail_force = compute_sail_force(apparent_wind, sail_trim)
	var heel_target = sail_force.heel
	
	# Smooth heel angle toward target
	current_heel = lerp(current_heel, heel_target, heel_recovery_speed * delta)
	
	# Apply heel rotation (tilt the boat)
	rotation.z = current_heel
	
	# Compute boat acceleration from sail force
	var boat_forward = -transform.basis.z.normalized()
	var boat_right = transform.basis.x.normalized()
	
	var thrust_vector = boat_forward * sail_force.drive + boat_right * sail_force.drift
	
	# Apply drag and acceleration
	boat_velocity = boat_velocity.lerp(boat_velocity + thrust_vector * acceleration * delta, 1.0 - water_drag)
	boat_velocity = boat_velocity.lerp(Vector3.ZERO, water_drag * delta)
	
	# Clamp speed
	if boat_velocity.length() > max_speed:
		boat_velocity = boat_velocity.normalized() * max_speed
	
	# Update position
	position += boat_velocity * delta
	
	# Float on ocean
	if ocean:
		var bob := sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_amount
		position.y = ocean.get_ocean_height(position.x, position.z) + bob + 1.1

func compute_apparent_wind(delta: float) -> Vector3:
	# True wind in world space
	var true_wind = wind_direction.normalized() * wind_strength
	
	# Add wind gusts
	var gust = sin(Time.get_ticks_msec() * 0.001 * wind_gust_speed) * wind_gust_scale
	true_wind *= (1.0 + gust * 0.1)
	
	# Apparent wind = true wind - boat velocity
	var apparent = true_wind - boat_velocity
	return apparent

func compute_sail_force(apparent_wind: Vector3, trim: float) -> Dictionary:
	# Transform wind to boat space
	var local_wind = transform.basis.inverse() * apparent_wind
	var wind_speed = local_wind.length()
	
	if wind_speed < 0.1:
		return {"drive": 0.0, "drift": 0.0, "heel": 0.0}
	
	# Angle of attack: measure how the wind hits the sail
	var wind_angle = atan2(local_wind.x, -local_wind.z)
	
	# Sail efficiency drops sharply within 30 degrees of head-to-wind
	var head_to_wind_penalty = max(0.0, 1.0 - abs(wind_angle) / 0.52)  # 0.52 rad ≈ 30°
	
	# Sail angle: trim controls how close to the wind we can sail
	var sail_angle = lerp(0.3, 0.05, trim)  # Trimmed in = tighter to wind
	var angle_factor = max(0.0, cos(wind_angle - sail_angle) * (1.0 - head_to_wind_penalty * 0.5))
	
	# Drive force (forward)
	var drive = angle_factor * wind_speed * trim * 0.8
	
	# Lateral force (sideways, creates drift and heel)
	var lateral = sin(wind_angle) * wind_speed * (1.0 - abs(sail_angle)) * 0.6
	
	# Heel: more lateral force = more heel
	var heel = clamp(lateral * 0.15, -max_heel_angle, max_heel_angle)
	
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
