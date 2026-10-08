extends Camera3D

@export var distance: float = 12.0
@export var height: float = 6.0
@export var follow_speed: float = 4.0

var target: Node3D

func _ready() -> void:
	target = get_tree().get_first_node_in_group("boat")
	if target == null:
		push_warning("No boat found in group 'boat'.")

func _process(delta: float) -> void:
	if target == null:
		return

	# Follow only the boat's horizontal position so the camera doesn't bob with the wave motion.
	var target_flat_position: Vector3 = target.global_position
	target_flat_position.y = 0.0
	var desired_position: Vector3 = target_flat_position + Vector3(0.0, height, 0.0) - target.global_basis.z * distance
	global_position = global_position.lerp(desired_position, follow_speed * delta)
	look_at(Vector3(target.global_position.x, target.global_position.y + 1.5, target.global_position.z), Vector3.UP)
