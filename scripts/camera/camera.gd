extends Camera3D

@export var target: Node3D
@export var FOLLOW_SPEED: float = 6
var reverse_camera: bool = false
var unreversed_position: Vector3 = position
var unreversed_rotation: float = rotation.y

func reverse():
	reverse_camera = not reverse_camera
	rotation.y = rotation.y + PI

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	unreversed_position = lerp(unreversed_position, target.position, FOLLOW_SPEED * delta)
	var should_reverse = Input.is_action_just_pressed("Reverse Camera")
	if should_reverse:
		reverse()

	if reverse_camera:
		position = -unreversed_position
	else:
		position = unreversed_position
