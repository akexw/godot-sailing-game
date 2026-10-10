extends CharacterBody3D
class_name Boat

# Physics parameters
@export_range(0.0, 30.0) var max_speed: float = 20.0
@export_range(0.0, 20.0) var acceleration: float = 2.5
@export_range(0.0, 4.0) var rudder_turn_speed: float = 0.4
@export_range(0.0, 1.0) var water_drag: float = 0.2
@export_range(0.0, 1.0) var drift_factor: float = 0.05
@export_range(0.0, 10.0) var keel_grip: float = 4.0  # higher = less sideways slip

# Wind system
@export var wind_direction: Vector3 = Vector3(0.0, 0.0, 1.0).normalized()
@export var wind_strength: float = 12.0
@export var wind_gust_speed: float = 0.3
@export var wind_gust_scale: float = 3.0
@export var wind_angle: float = 0
@export var true_wind: Vector3 = Vector3(0, 0, 0)
@export var anglediff: float = 1


# Sail and heel
@export_range(0.0, 1.0) var max_heel_angle: float = 0.45
@export_range(0.0, 2.0) var heel_recovery_speed: float = 1.2
@export var sail_max_angle: float = 0.9
@export_range(0.0, 1.57) var head_to_wind_zone: float = 0.78  # ~45 degrees in radians
@export_range(1.0, 10.0) var head_to_wind_penalty_strength: float = 10.0

# Ocean and bob
@export var bob_amount: float = 0.05
@export var bob_speed: float = 0.3

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
	rudder_angle = lerp(rudder_angle, -turn_input, 0.15)
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
	
		# Use the flat heading, so heel doesn't tilt the axes
	var fwd: Vector3 = Vector3(sin(current_heading), 0.0, cos(current_heading))
	var right: Vector3 = Vector3(cos(current_heading), 0.0, -sin(current_heading))
	
	var forward_speed: float = boat_velocity.dot(fwd)
	var side_speed: float = boat_velocity.dot(right)
	forward_speed *= 1.0 - abs(rudder_angle) * 0.15 * delta
	var grip: float = keel_grip * clamp(abs(forward_speed) / 3.0, 0.2, 1.0)
	
	# The keel resists sideways motion much more than forward motion
	side_speed = lerp(side_speed, 0.0, 1.0 - exp(-grip * delta))
	boat_velocity = fwd * forward_speed + right * side_speed
	
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
	true_wind = wind_direction.normalized() * wind_strength
	var gust: float = sin(Time.get_ticks_msec() * 0.001 * wind_gust_speed) * wind_gust_scale
	true_wind *= 1.0 + gust * 0.1
	return true_wind - boat_velocity

#the difference in angle between true wind and the boats heading
'func wind_diff_angle() -> float:
	add_to_group("boat")
	var find_anglediff: float = abs(atan2(wind_direction.x, wind_direction.z) - rotation.y)
	return find_anglediff'

# Bearing the wind blows TOWARD, same convention as rotation.y (forward = +Z)
func wind_bearing() -> float:
	return atan2(wind_direction.x, wind_direction.z)

# boat.gd: bearing the wind comes FROM (forward = +Z, same as rotation.y)
func wind_source_bearing() -> float:
	return atan2(-wind_direction.x, -wind_direction.z)

func compute_sail_force(apparent_wind: Vector3, trim: float) -> Dictionary:
	var local_wind: Vector3 = transform.basis.inverse() * apparent_wind
	var wind_speed: float = local_wind.length()
	
	var wind_angle: float = atan2(local_wind.x, local_wind.z)  
	var abs_wind_angle: float = abs(wind_angle)
	
	var signed_diff: float = angle_difference(current_heading, wind_source_bearing())
	var side: float = sign(signed_diff)
	
	anglediff = abs(signed_diff)
	
	# no go zone
	if anglediff < 0.78:
		return {"drive": 0.0, "drift": 0.0, "heel": 0.0}
	
	var drive: float = 0
	var lateral: float = 0
	var heel: float = 0
	
	# close haul
	if 0.78 <= anglediff and anglediff < 1:
		drive = wind_speed * trim * 0.1
		lateral = sin(signed_diff) * wind_speed * 0.05
		heel = clamp(lateral * 0.4, -max_heel_angle, max_heel_angle)
	
	# close reach
	if 1 <= anglediff and anglediff < 1.4:
		drive= wind_speed * trim * 0.12
		lateral = sin(signed_diff) * wind_speed * 0.03
		heel = clamp(lateral * 0.4, -max_heel_angle, max_heel_angle)
	
	# beam reach
	if 1.4 <= anglediff and anglediff < 1.7:
		drive = wind_speed * trim * 0.17
		lateral = sin(signed_diff) * wind_speed * 0.015
		heel = clamp(lateral * 0.4, -max_heel_angle, max_heel_angle)
		
		# broad reach
	if 1.7 <= anglediff and anglediff < 2.6:
		drive = wind_speed * trim * 0.15
		lateral = sin(signed_diff) * wind_speed * 0.005
		heel = clamp(lateral * 0.4, -max_heel_angle, max_heel_angle)
		
		# running
	if anglediff >= 2.6:
		drive = wind_speed * trim * 0.145
		lateral = sin(signed_diff) * wind_speed * 0.001
		heel = clamp(lateral * 0.4, -max_heel_angle, max_heel_angle)
		

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
