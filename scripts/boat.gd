extends CharacterBody3D
class_name Boat

@export var move_speed: float = 14.0
@export var turn_speed: float = 1.8
@export var bob_amount: float = 0.35
@export var bob_speed: float = 2.0

@onready var ocean: OceanMesh = get_tree().get_first_node_in_group("ocean")

func _ready() -> void:
	add_to_group("boat")

func _physics_process(delta: float) -> void:
	var turn_input := 0.0
	if Input.is_action_pressed("turn_left"):
		turn_input += 1.0
	if Input.is_action_pressed("turn_right"):
		turn_input -= 1.0
	rotation.y += turn_input * turn_speed * delta

	var move_input := 0.0
	if Input.is_action_pressed("move_forward"):
		move_input += 1.0
	if Input.is_action_pressed("move_backward"):
		move_input -= 1.0

	if move_input != 0.0:
		var forward := -transform.basis.z
		position += forward * move_input * move_speed * delta

	if ocean:
		var bob := sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_amount
		position.y = ocean.get_ocean_height(position.x, position.z) + bob + 1.1
