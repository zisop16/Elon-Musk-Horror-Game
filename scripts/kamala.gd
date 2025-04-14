extends CharacterBody3D

@onready var footsteps = $FootstepPlayer

const WALK_SPEED := 2.
const RUN_SPEED := 6.
const JUMP_VELOCITY := 4.5

enum {WALK, IDLE, RUN}
var ai_state = IDLE
var remaining_state_time: float = 0
var target_position: Vector3

func get_movement_direction() -> Vector3:
	if ai_state == IDLE:
		return Vector3.ZERO
	return (target_position - global_position).slide(Vector3.UP).normalized()

func at_target() -> bool:
	var diff := target_position - global_position
	const epsilon = .5
	return diff.length() < epsilon

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := get_movement_direction()
	var move_speed: float
	var movement_vector = direction * move_speed
	if at_target():
		movement_vector = Vector3.ZERO

	if ai_state == WALK:
		move_speed = WALK_SPEED
		footsteps.speed_scale = .4
	elif ai_state == RUN:
		move_speed = RUN_SPEED
		footsteps.speed_scale = 2

	if movement_vector != Vector3.ZERO:
		footsteps.play("grass")
		velocity = movement_vector
	else:
		var friction = 3
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)

	move_and_slide()
