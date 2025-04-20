class_name Player
extends CharacterBody3D

@onready var crouched_hitbox = $"Crouched Box"
@onready var standing_hitbox = $"Standing Box"
@onready var model: Node3D = $"Elon Model"
@onready var camera_pivot: CameraPivot = $"Camera Pivot"
@onready var anim_tree: AnimationTree = model.get_node("AnimationTree")
@onready var anim_player: AnimationPlayer = model.get_node("AnimationPlayer")
@onready var standing_head: Vector3 = $"Standing Head".position
@onready var crouched_head: Vector3 = $"Crouched Head".position
@onready var footsteps: PolyAudioPlayer = $FootstepPlayer
@onready var interaction_ray: RayCast3D = $"Camera Pivot/Camera3D/Interaction"

@export var chainsaw_pos: Node3D
@export var flashlight_pos: Node3D
@export var remote_pos: Node3D

var inventory: Array[Item]
var equipped_item := 0
const inventory_size = 3

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
	for item in range(inventory_size):
		inventory.append(null)
	Global.player = self

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

var hovered_object: CollisionObject3D = null
func set_item(slot: int, item: Item):
	inventory[slot] = item
	Global.item_interface.set_item(slot, item)

func get_free_slot() -> int:
	for slot in inventory.size():
		if inventory[slot] == null:
			return slot
	return -1

func select_item(slot: int):
	# handle previously selected
	if inventory[equipped_item] != null:
		inventory[equipped_item].set_equipped(false)
	equipped_item = slot
	Global.item_interface.select_item(slot)
	if inventory[equipped_item] != null:
		inventory[equipped_item].set_equipped(true)

func attach_item(item: Item):
	if item is Flashlight:
		item.attach(flashlight_pos)
	elif item is Chainsaw:
		item.attach(chainsaw_pos)
	elif item is TvRemote:
		item.attach(remote_pos)

func handle_interactions():
	hovered_object = interaction_ray.get_collider()
	var should_interact = Input.is_action_just_pressed("Interact")
	Global.item_tooltip.visible = hovered_object != null
	if (not should_interact) or (hovered_object == null):
		return
	if hovered_object is Item:
		var item: Item = hovered_object
		if inventory[equipped_item] == null:
			set_item(equipped_item, item)
			item.set_equipped(true)
		else:
			var free_slot = get_free_slot()
			if free_slot == -1:
				# Must toss away the current item slot
				pass
			else:
				set_item(free_slot, item)
				item.set_equipped(false)
		attach_item(item)
	else:
		hovered_object.interact()
		

func handle_items():
	var i0 = Input.is_action_just_pressed("SelectItem0")
	var i1 = Input.is_action_just_pressed("SelectItem1")
	var i2 = Input.is_action_just_pressed("SelectItem2")
	if i0:
		select_item(0)
	elif i1:
		select_item(1)
	elif i2:
		select_item(2)

	var equipped := inventory[equipped_item]
	if equipped == null:
		return
	if equipped is Flashlight:
		var flashlight_clicked = Input.is_action_just_pressed("Flashlight")
		if flashlight_clicked:
			equipped.toggle()
	elif equipped is TvRemote:
		var tv_clicked = Input.is_action_just_pressed("Flashlight")
		if tv_clicked:
			equipped.toggle()

func update_tree():
	for key in anim_amounts.keys():
		var blend_name = "parameters/%s/blend_amount" % key
		anim_tree[blend_name] = anim_amounts[key]

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
	
	if standing:
		anim_state = "idle"
	else:
		anim_state = "crouch_idle"

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and not jumping:
		anim_tree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		jumping = true
		time_of_jump = Global.time()

	var input_dir = Input.get_vector("Move Right", "Move Left", "Move Back", "Move Forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var crouching = Input.is_action_pressed("Crouch")
	var running = not crouching and input_dir.y >= 0 and Input.is_action_pressed("Run")

	var move_speed: float
	if crouching:
		move_speed = CROUCH_SPEED
		footsteps.speed_scale = .6
		stand(false)
	else:
		if running:
			move_speed = RUN_SPEED
			footsteps.speed_scale = 1.4
		else:
			move_speed = SPEED
			footsteps.speed_scale = 1
		stand(true)



	if jumping and Global.time() - time_of_jump > jump_anim_delay:
		jumping = false
		velocity.y = JUMP_VELOCITY
	
	var rotation_target := camera_pivot.rotation.y + PI
	
	if direction:
		if is_on_floor():
			footsteps.play_sound_effect("grass")
		if standing:
			if input_dir.y < 0:
				anim_state = "walk_back"
			elif running:
				anim_state = "run"
			else:
				anim_state = "walk"
		else:
			if input_dir.y < 0:
				anim_state = "crouch_walk_back"
			else:
				anim_state = "crouch_walk"
		
		var movement_angle = 0
		if (input_dir.x != 0):
			movement_angle = acos(-input_dir.x)
			if (input_dir.y < 0):
				movement_angle = -movement_angle
		else:
			movement_angle = asin(input_dir.y)
		var movement_rotation = movement_angle - PI/2
		if (input_dir.y < 0):
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
	handle_interactions()
	move_and_slide()

func _process(_delta: float) -> void:
	handle_items()
