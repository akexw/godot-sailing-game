extends CharacterBody3D

class_name Boat

# Movement
@export var move_speed: float = 20.0
@export var rotation_speed: float = 2.0
@export var bob_speed: float = 2.0
@export var bob_amount: float = 0.5

# References
@onready var ocean: OceanMesh = get_tree().get_first_node_in_group("ocean")

var base_y: float = 0.0

func _ready() -> void:
	base_y = position.y
	add_to_group("boat")

func _process(delta: float) -> void:
	handle_input(delta)
	update_boat_position(delta)

func handle_input(delta: float) -> void:
	var input_dir = Vector3.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("ui_down"):
		input_dir.z += 1
	if Input.is_action_pressed("ui_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir.x += 1
	
	# Normalize diagonal movement
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		position += input_dir * move_speed * delta
	
	# Rotate boat to face direction of movement
	if input_dir != Vector3.ZERO:
		var target_angle = atan2(input_dir.x, -input_dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

func update_boat_position(delta: float) -> void:
	if ocean:
		# Get ocean height at boat position
		var ocean_height = ocean.get_ocean_height(position.x, position.z)
		
		# Add bobbing motion
		var time = Time.get_ticks_msec() / 1000.0
		var bob = sin(time * bob_speed) * bob_amount
		
		# Set Y position to float on ocean
		position.y = ocean_height + bob
