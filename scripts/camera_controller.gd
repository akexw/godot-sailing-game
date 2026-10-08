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

	var desired_position: Vector3 = target.global_position + Vector3(0, height, 0) - target.global_basis.z * distance
	global_position = global_position.lerp(desired_position, follow_speed * delta)
	look_at(target.global_position + Vector3(0, 1.5, 0), Vector3.UP)
