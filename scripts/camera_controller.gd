extends Camera3D

class_name CameraController

@export var distance: float = 20.0
@export var height: float = 10.0
@export var smooth_speed: float = 5.0

var target_position: Vector3
var target: Node3D

func _ready() -> void:
	target = get_tree().get_first_node_in_group("boat")
	if not target:
		push_warning("Camera: No boat found in 'boat' group")

func _process(delta: float) -> void:
	if target:
		# Calculate desired camera position (behind and above the boat)
		var behind_direction = -target.transform.basis.z
		target_position = target.position + (behind_direction * distance) + (Vector3.UP * height)
		
		# Smoothly move camera to target position
		global_position = global_position.lerp(target_position, smooth_speed * delta)
		
		# Look at the boat
		look_at(target.position + Vector3.UP * 2, Vector3.UP)
