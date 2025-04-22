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
@onready var footsteps: FootstepPlayer = $FootstepPlayer
@onready var sfx_player: PolyAudioPlayer = $SFXPlayer
@onready var interaction_ray: RayCast3D = $"Camera Pivot/Camera3D/Interaction"

@export var chainsaw_pos: Node3D
@export var flashlight_pos: Node3D
@export var remote_pos: Node3D
@export var mining_hitbox: Area3D

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
	attach_item(item)

func get_free_slot() -> int:
	for slot in inventory.size():
		if inventory[slot] == null:
			return slot
	return -1

func get_flashlight() -> Flashlight:
	for item in inventory:
		if item is Flashlight:
			return item
	return null

func select_item(slot: int):
	# handle previously selected
	if inventory[equipped_item] != null:
		inventory[equipped_item].visible = false
	equipped_item = slot
	Global.item_interface.select_item(slot)
	if inventory[equipped_item] != null:
		inventory[equipped_item].visible = true

func attach_item(item: Item):
	if item is Flashlight:
		item.attach(flashlight_pos)
	elif item is Chainsaw:
		item.attach(chainsaw_pos)
	elif item is TvRemote:
		item.attach(remote_pos)

func handle_interactions():
	# Disable the outline of the object hovered on previous frame
	if hovered_object != null:
		hovered_object.interaction.disable_outline()
	var coll := interaction_ray.get_collider()
	if (coll == null) or (not coll.has_method("interact")):
		hovered_object = null
		Global.item_tooltip.label.text = ""
		return
	hovered_object = coll
	hovered_object.interaction.show_tooltip()
	var should_interact = Input.is_action_just_pressed("Interact") and hovered_object.interaction_requirement() == ""
	if not should_interact:
		return
	if hovered_object is Item:
		var item: Item = hovered_object
		if inventory[equipped_item] == null:
			set_item(equipped_item, item)
		else:
			var free_slot = get_free_slot()
			if free_slot == -1:
				# Must toss away the current item slot
				drop_item()
				set_item(free_slot, item)
			else:
				set_item(free_slot, item)
				item.visible = false
		hovered_object = null
		Global.item_tooltip.label.text = ""
		sfx_player.play_sound_effect("item_pickup")
	else:
		hovered_object.interact()
		
func drop_item():
	var to_drop := inventory[equipped_item]
	if to_drop == null:
		return
	inventory[equipped_item] = null
	to_drop.drop()
	Global.item_interface.set_item(equipped_item, null)

func handle_items():
	var i0 = Input.is_action_just_pressed("SelectItem0")
	var i1 = Input.is_action_just_pressed("SelectItem1")
	var i2 = Input.is_action_just_pressed("SelectItem2")
	var drop = Input.is_action_just_pressed("DropItem")
	if i0:
		select_item(0)
	elif i1:
		select_item(1)
	elif i2:
		select_item(2)
	if drop:
		drop_item()

	var equipped := inventory[equipped_item]
	var use_item = Input.is_action_just_pressed("Use")
	if not use_item:
		return
	if equipped == null:
		self.mine()
	if equipped is Flashlight:
		equipped.toggle()
	elif equipped is TvRemote:
		equipped.toggle()

var mining := false

func mine():
	if mining:
		return
	anim_tree["parameters/mine/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	mining = true

## Called by mining animation
func mine_effect():
	mining = false
	var targets: Array[Mineable] = []
	targets.assign(mining_hitbox.get_overlapping_bodies())
	print(targets)
	if targets.size() == 0:
		return
	var holding_pickaxe := self.inventory[equipped_item] is Pickaxe
	var min_dist: float
	var closest_valid_target: Mineable = null
	for target in targets:
		if not holding_pickaxe and target.requires_pickaxe:
			continue
		var dist: float = (target.global_position - global_position).length_squared()
		if closest_valid_target == null:
			min_dist = dist
			closest_valid_target = target
		elif dist < min_dist:
			min_dist = dist
			closest_valid_target = target
	print(closest_valid_target)
	if closest_valid_target != null:
		closest_valid_target.mine()

func update_tree():
	for key in anim_amounts.keys():
		var blend_name = "parameters/%s/blend_amount" % key
		anim_tree[blend_name] = anim_amounts[key]

var jumping := false

const WALK_SPEED = 3.5
const CROUCH_SPEED = 2.0
const RUN_SPEED = 8.
const JUMP_SPEED = 8

## Called by jump animation
func jump_effect() -> void:
	jumping = false
	velocity.y = JUMP_SPEED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		var falling = velocity.y < 0
		var gravity = get_gravity() * delta
		if falling:
			const fast_fall_multiplier = 2.2
			gravity *= fast_fall_multiplier
		velocity += gravity
	
	if standing:
		anim_state = "idle"
	else:
		anim_state = "crouch_idle"

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and not jumping:
		anim_tree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		jumping = true

	var input_dir = Input.get_vector("Move Right", "Move Left", "Move Back", "Move Forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var crouching = Input.is_action_pressed("Crouch")
	var running = not crouching and input_dir.y >= 0 and Input.is_action_pressed("Run")

	var current_horizontal_speed := velocity.slide(Vector3.UP).length()
	var target_speed: float
	if crouching:
		target_speed = CROUCH_SPEED
		footsteps.speed_scale = .8
		stand(false)
	else:
		if running:
			target_speed = RUN_SPEED
			footsteps.speed_scale = 1.4
		else:
			target_speed = WALK_SPEED
			footsteps.speed_scale = 1
		stand(true)
	const speed_control: float = 20
	current_horizontal_speed = move_toward(current_horizontal_speed, target_speed, speed_control * delta)
	
	var rotation_target := camera_pivot.rotation.y + PI
	
	if direction:
		if is_on_floor():
			footsteps.play_step()
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
		velocity.x = direction.x * current_horizontal_speed
		velocity.z = direction.z * current_horizontal_speed
		rotation_target += movement_rotation
	else:
		var friction = 60
		var current_horizontal_direction = velocity.slide(Vector3.UP).normalized()
		current_horizontal_speed = move_toward(current_horizontal_speed, 0, friction * delta)
		velocity = current_horizontal_direction * current_horizontal_speed + velocity.project(Vector3.UP)

	rotation_target = fmod(rotation_target, (2 * PI))
	var rotation_diff = model.rotation.y - rotation_target
	if rotation_diff > PI:
		rotation_target = rotation_target + 2*PI
	elif rotation_diff < -PI:
		rotation_target = rotation_target - 2*PI

	var rotate_speed = 10
	model.rotation.y = lerpf(model.rotation.y, rotation_target, rotate_speed * delta)
	model.rotation.y = fmod(model.rotation.y, (2 * PI))

	handle_animations(delta)
	var mass = 1
	
	move_and_slide()
	for i in get_slide_collision_count():
		var coll = get_slide_collision(i)
		var push_impulse = (target_speed * mass * direction).project(-coll.get_normal())
		if coll.get_collider() is RigidBody3D:
			coll.get_collider().apply_central_impulse(push_impulse)

func _process(_delta: float) -> void:
	handle_interactions()
	handle_items()
