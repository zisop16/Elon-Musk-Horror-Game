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
@onready var interaction_ray: RayCast3D = %InteractionRay

@onready var item_pos: Dictionary[Item.item_id, Node3D] = {
	Item.item_id.chainsaw: $"Elon Model/Wrapper/Sketchfab_model/Skeleton3D/BoneAttachment3D/Chainsaw",
	Item.item_id.flashlight: $"Elon Model/Wrapper/Sketchfab_model/Skeleton3D/BoneAttachment3D/Flashlight",
	Item.item_id.tv_remote: $"Elon Model/Wrapper/Sketchfab_model/Skeleton3D/BoneAttachment3D/TvRemote",
	Item.item_id.wood_block: $"Elon Model/Wrapper/Sketchfab_model/Skeleton3D/BoneAttachment3D/WoodBlock",
	Item.item_id.pickaxe: $"Elon Model/Wrapper/Sketchfab_model/Skeleton3D/BoneAttachment3D/Pickaxe",
	Item.item_id.bucket: $"Elon Model/Wrapper/Sketchfab_model/Skeleton3D/BoneAttachment3D/Bucket",
	Item.item_id.gold_chain: $"Elon Model/Wrapper/Sketchfab_model/Skeleton3D/BoneAttachment3D/GoldChain",
	Item.item_id.gold_ingot: $"Elon Model/Wrapper/Sketchfab_model/Skeleton3D/BoneAttachment3D/GoldIngot",
	Item.item_id.iron_ingot: $"Elon Model/Wrapper/Sketchfab_model/Skeleton3D/BoneAttachment3D/IronIngot",
	Item.item_id.saw_movie: $"Elon Model/Wrapper/Sketchfab_model/Skeleton3D/BoneAttachment3D/SawMovie"
}

var inventory: Array[Item]
var equipped_item := 0
const inventory_size = 4
const max_stamina: float = 20
const stamina_regen: float = .4
var stamina := max_stamina
const max_health: float = 100
var health := max_health
var health_regen: float = 2

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

func handle_animations():
	const ANIM_BLEND_SPEED = 7
	var delta = get_process_delta_time()
	for state in anim_amounts.keys():
		if anim_state == state:
			anim_amounts[state] = lerpf(anim_amounts[state], 1, ANIM_BLEND_SPEED * delta)
		else:
			anim_amounts[state] = lerpf(anim_amounts[state], 0, ANIM_BLEND_SPEED * delta)
			# If the animation is blended to zero, reset it to starting position
			if anim_amounts[state] < .01:
				# The standard run seek node is named standard_run_time
				var time_seek = state + "_time"
				anim_tree["parameters/" + time_seek + "/seek_request"] = 0.0
	update_anim_tree()

var hovered_object: CollisionObject3D = null
func set_item(slot: int, item: Item):
	inventory[slot] = item
	Global.item_interface.set_item(slot, item)
	if item != null:
		attach_item(item)

func remove_item(slot: int):
	var item := inventory[slot]
	set_item(slot, null)
	if item != null:
		item.queue_free()

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
	var pos := item_pos[item.id]
	item.attach(pos)

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
	var coll_point = interaction_ray.get_collision_point()
	hovered_object.interaction.show_tooltip(coll_point)
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
				set_item(equipped_item, item)
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
	var i1 = Input.is_action_just_pressed("SelectItem1")
	var i2 = Input.is_action_just_pressed("SelectItem2")
	var i3 = Input.is_action_just_pressed("SelectItem3")
	var i4 = Input.is_action_just_pressed("SelectItem4")
	var drop = Input.is_action_just_pressed("DropItem")
	if i1:
		select_item(0)
	elif i2:
		select_item(1)
	elif i3:
		select_item(2)
	elif i4:
		select_item(3)
	if drop:
		drop_item()

	var equipped := inventory[equipped_item]
	var use_item = Input.is_action_just_pressed("Use")
	if not use_item:
		return
	if equipped is Flashlight:
		equipped.toggle()
	elif equipped is TvRemote:
		equipped.toggle()
	elif equipped is Chainsaw:
		equipped.toggle()
	else:
		# All items without uses will just mine
		self.mine()

func mine():
	if mining:
		return
	self.sfx_player.play_sound_effect("mine")
	anim_tree["parameters/mine/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	anim_tree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
	mining = true
	mine_time = Global.time()

## Called by mining animation
func mine_effect():
	mining = false
	var mining_target := interaction_ray.get_collider()
	if mining_target == null:
		return
	var mine_component: MineComponent = mining_target.find_child("MineComponent")
	var holding_pickaxe := self.inventory[equipped_item] is Pickaxe
	if mine_component == null or mine_component.requires_pickaxe and not holding_pickaxe:
		return
	mine_component.mine()

func update_anim_tree():
	for key in anim_amounts.keys():
		var blend_name = "parameters/%s/blend_amount" % key
		anim_tree[blend_name] = anim_amounts[key]

var mining := false
var jumping := false
var jump_time: float
var mine_time: float
@onready var jump_delay: float = .22 / anim_tree["parameters/jump_speed/scale"]
@onready var mine_delay: float = .56 / anim_tree["parameters/mine_speed/scale"]


const WALK_SPEED = 3.5
const CROUCH_SPEED = 2.0
const RUN_SPEED = 8.
const JUMP_SPEED = 8


## Called by jump animation
func jump_effect() -> void:
	jumping = false
	velocity.y = JUMP_SPEED

var running_last_frame: bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		var falling = velocity.y < 0
		var gravity = get_gravity() * delta
		if falling:
			const fast_fall_multiplier = 2.2
			gravity *= fast_fall_multiplier
		velocity += gravity

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor() and not jumping:
		anim_tree["parameters/jump/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		anim_tree["parameters/mine/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT
		jumping = true
		jump_time = Global.time()

	if jumping and (Global.time() - jump_time) > jump_delay:
		jump_effect()
	if mining and (Global.time() - mine_time) > mine_delay:
		mine_effect()

	var input_dir = Input.get_vector("Move Right", "Move Left", "Move Back", "Move Forward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var crouching = Input.is_action_pressed("Crouch")
	# Prevents the player from staying in permanent run on 0 stamina
	var stamina_allows_run = ((running_last_frame and stamina > 0) or stamina > 0.5)
	var running = input_dir != Vector2.ZERO and not crouching and input_dir.y >= 0 and Input.is_action_pressed("Run") and stamina_allows_run

	var current_horizontal_speed := velocity.slide(Vector3.UP).length()
	var target_speed: float
	if crouching:
		target_speed = CROUCH_SPEED
		footsteps.speed_scale = .8
	else:
		if running:
			target_speed = RUN_SPEED
			footsteps.speed_scale = 1.4
		else:
			target_speed = WALK_SPEED
			footsteps.speed_scale = 1
	const speed_control: float = 20
	current_horizontal_speed = move_toward(current_horizontal_speed, target_speed, speed_control * delta)
	var rotation_target := camera_pivot.rotation.y + PI
	
	if direction:
		if is_on_floor():
			footsteps.play_step()

		## left is positive and right is negative, so we need negative of this angle
		var movement_rotation := -Vector2(0, 1).angle_to(input_dir)
		if (abs(movement_rotation) - PI/2) > Global.epsilon:
			# If the character is walking backwards, they face forward and play walking back anim
			movement_rotation -= PI
		
		direction = direction.rotated(Vector3.UP, rotation_target)
		velocity.x = direction.x * current_horizontal_speed
		velocity.z = direction.z * current_horizontal_speed
		rotation_target += movement_rotation
	else:
		var friction = 60
		var current_horizontal_direction = velocity.slide(Vector3.UP).normalized()
		current_horizontal_speed = move_toward(current_horizontal_speed, 0, friction * delta)
		velocity = current_horizontal_direction * current_horizontal_speed + velocity.project(Vector3.UP)

	
	rotate_model(rotation_target)
	determine_anim_state(input_dir, running, crouching)
	move_and_slide()
	handle_stats(running)
	
	handle_collisions(target_speed * direction)
	running_last_frame = running

func determine_anim_state(input_dir: Vector2, running: bool, crouching: bool):
	if crouching:
		if input_dir.y < 0:
			anim_state = "crouch_walk_back"
		elif input_dir != Vector2.ZERO:
			anim_state = "crouch_walk"
		else:
			anim_state = "crouch_idle"
	elif running:
		anim_state = "run"
	else:
		if input_dir.y < 0:
			anim_state = "walk_back"
		elif input_dir != Vector2.ZERO:
			anim_state = "walk"
		else:
			anim_state = "idle"
	stand(!crouching)

func rotate_model(rotation_target: float):
	var delta = get_physics_process_delta_time()
	rotation_target = fposmod(rotation_target, (2 * PI))
	model.rotation.y = fposmod(model.rotation.y, (2 * PI))
	var rotation_diff = model.rotation.y - rotation_target
	if rotation_diff > PI:
		rotation_target = rotation_target + 2*PI
	elif rotation_diff < -PI:
		rotation_target = rotation_target - 2*PI

	var rotate_speed = 10
	model.rotation.y = lerpf(model.rotation.y, rotation_target, rotate_speed * delta)

func add_stamina(increase: float):
	stamina += increase
	stamina = clampf(stamina, 0, max_stamina)
	Global.stat_interface.set_stamina(stamina / max_stamina)

func handle_stats(running: bool):
	var delta = get_physics_process_delta_time()
	var stamina_change: float
	if running:
		stamina_change = -delta
	else:
		stamina_change = stamina_regen * delta
	add_stamina(stamina_change)
	add_health(health_regen * delta)

func add_health(increase: float):
	health += increase
	health = clampf(health, 0, max_health)
	Global.stat_interface.set_health(health/max_health)
	

func handle_collisions(target_horizontal_velocity: Vector3):
	## Use our target horizontal velocity + our vertical velocity as basis for collision momentum
	var target_velocity := target_horizontal_velocity + velocity.project(Vector3.UP)
	var mass = 1
	var target_momentum = mass * target_velocity
	for i in get_slide_collision_count():
		var coll = get_slide_collision(i)
		var push_impulse = (target_momentum).project(-coll.get_normal())
		if coll.get_collider() is RigidBody3D:
			coll.get_collider().apply_central_impulse(push_impulse)

func _process(_delta: float) -> void:
	handle_interactions()
	handle_items()
	handle_animations()

func has(id: Item.item_id) -> bool:
	for item in inventory:
		if item.id == id:
			return true
	return false
