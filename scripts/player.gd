extends CharacterBody3D

@onready var crouched_hitbox = $"Crouched Box"
@onready var standing_hitbox = $"Standing Box"
@onready var model: Node3D = $"Elon Model"
@onready var camera_pivot: CameraPivot = $"Camera Pivot"
@onready var anim_tree: AnimationTree = model.get_node("AnimationTree")
@onready var anim_player: AnimationPlayer = model.get_node("AnimationPlayer")
@onready var standing_head: Vector3 = $"Standing Head".position
@onready var crouched_head: Vector3 = $"Crouched Head".position

@export var flashlight: Item
@export var chainsaw: Item

var standing: bool = true
func stand(flag: bool) -> void:
	if flag:
		standing_hitbox.disabled = false
		crouched_hitbox.disabled = true
		camera_pivot.target_position = standing_head
	else:
		standing_hitbox.disabled = true
		crouched_hitbox.disabled = false
		camera_pivot.target_position = crouched_head
	standing = flag

func _ready():
	stand(true)
	chainsaw.dequip()
	flashlight.equip()

const BLEND_SPEED = 7
var anim_state := "idle"
var anim_amounts: Dictionary = {
	crouch_idle = 0,
	crouch_walk = 0,
	chainsaw_run = 0,
	walk = 0,
	run = 0,
	walk_back = 0,
	crouch_walk_back = 0
}

func handle_animations(delta):
	for state in anim_amounts.keys():
		if anim_state == state:
			anim_amounts[state] = lerpf(anim_amounts[state], 1, BLEND_SPEED * delta)
		else:
			anim_amounts[state] = lerpf(anim_amounts[state], 0, BLEND_SPEED * delta)
	update_tree()
			
func handle_items():
	var flashlight_clicked = Input.is_action_just_pressed("Flashlight")
	if flashlight_clicked:
		flashlight.toggle()

func update_tree():
	for key in anim_amounts.keys():
		var modified = "parameters/%s/blend_amount" % key
		anim_tree[modified] = anim_amounts[key]

var jumping := false
var time_of_jump: float = 0
@onready var jump_anim_delay: float = .4 / anim_tree["parameters/jump_speed/scale"]

const SPEED = 5.0
const CROUCH_SPEED = 2.0
const RUN_SPEED = 11.
const JUMP_VELOCITY = 7

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if standing:
			anim_state = "idle"
		else:
			anim_state = "crouch_idle"

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		anim_tree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		jumping = true
		time_of_jump = Global.time()

	var input_dir = Input.get_vector("Move Right", "Move Left", "Move Back", "Move Forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var crouching = Input.is_action_pressed("Crouch")
	var running = not crouching and direction.z >= 0 and Input.is_action_pressed("Run")

	var move_speed: float
	if crouching:
		move_speed = CROUCH_SPEED
		stand(false)
	else:
		if running:
			move_speed = RUN_SPEED
		else:
			move_speed = SPEED
		stand(true)



	if jumping and Global.time() - time_of_jump > jump_anim_delay:
		jumping = false
		velocity.y = JUMP_VELOCITY
	
	var rotation_target := camera_pivot.rotation.y + PI
	
	if direction:
		if standing:
			if direction.z < 0:
				anim_state = "walk_back"
			elif running:
				anim_state = "run"
			else:
				anim_state = "walk"
		else:
			if direction.z < 0:
				anim_state = "crouch_walk_back"
			else:
				anim_state = "crouch_walk"
		
		var movement_angle = 0
		if (direction.x != 0):
			movement_angle = acos(-direction.x)
			if (direction.z < 0):
				movement_angle = -movement_angle
		else:
			movement_angle = asin(direction.z)
		var movement_rotation = movement_angle - PI/2
		if (direction.z < 0):
			movement_rotation = movement_rotation - PI
		
		
		direction = direction.rotated(Vector3.UP, rotation_target)
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		rotation_target += movement_rotation
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	rotation_target = fmod(rotation_target, (2 * PI))
	var rotation_diff = model.rotation.y - rotation_target
	if abs(rotation_diff) > PI:
		rotation_target = rotation_target - 2*PI

	model.rotation.y = lerpf(model.rotation.y, rotation_target, move_speed * delta)

	handle_animations(delta)
	handle_items()
	move_and_slide()
