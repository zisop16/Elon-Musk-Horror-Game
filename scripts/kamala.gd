extends CharacterBody3D

@onready var footsteps = $FootstepPlayer
@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var anim_tree: AnimationTree = $Model/AnimationTree
@onready var knife: Area3D = %KamalaKnife

const WALK_SPEED := 1.8
const RUN_SPEED := 4
const JUMP_VELOCITY := 4.5

enum {WALK, IDLE, RUN}
var anim_state := "idle"
var anim_amounts: Dictionary = {
	walk = 0,
	run = 0
}

func handle_animations():
	var delta = get_process_delta_time()
	const ANIM_BLEND_SPEED: float = 7
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

func update_anim_tree():
	for key in anim_amounts.keys():
		var blend_name = "parameters/%s/blend_amount" % key
		anim_tree[blend_name] = anim_amounts[key]

var remaining_idle_time: float = 0
var target_position: Vector3
## Ranges from 0 -> 100
var anger: float = 60
## Kamala will chase the player when she reaches this threshold
const follow_player_anger_threshold: float = 50
const run_anger_threshold: float = 25


func add_anger(increase: float):
	anger += increase
	anger = clampf(0, 100, anger)

## Informs kamala of a noise, increases her anger in response to loudness
func handle_noise(pos: Vector3, loudness: float):
	target_position = pos
	add_anger(loudness)

func should_run() -> bool:
	return anger > run_anger_threshold

func following_player() -> bool:
	return saw_player or anger > follow_player_anger_threshold

func get_movement_direction() -> Vector3:
	if following_player():
		target_position = Global.player.global_position
	navigation.target_position = target_position
	var direction := navigation.get_next_path_position() - global_position
	direction = direction.slide(Vector3.UP)
	direction = direction.normalized()

	return direction

## Casts a ray from kamala to the player, true if the ray is not obstructed
## And the player is within kamala's viewing distance
func player_visible() -> bool:
	const viewing_distance: float = 30
	var diff = Global.player.global_position - global_position
	## Short circuit if the player is outside of viewing distance
	if diff.length() > viewing_distance:
		return false
	var space_state := get_world_3d().direct_space_state
	var y_offset = Vector3.UP * .5
	var query := PhysicsRayQueryParameters3D.create(global_position + y_offset, Global.player.global_position + y_offset)
	## Will collide with terrain, player, and rigidbodies
	query.collision_mask = 0b111
	var result := space_state.intersect_ray(query)
	## For some reason, this is actually possible XD?
	if result.is_empty():
		return false
	var coll = result["collider"]
	return coll == Global.player

const attack_range: float = 1.1
func at_navigation_target() -> bool:
	var diff := (target_position - global_position).slide(Vector3.UP)
	return diff.length() < attack_range

func should_attack() -> bool:
	if not saw_player:
		return false
	var diff := (target_position - global_position).slide(Vector3.UP)
	return diff.length() < attack_range

var attacking := false
var knife_active := false
func activate_knife_hitbox():
	knife_active = true
func end_knife_hitbox():
	knife_active = false
func end_attack():
	attacking = false


var saw_player: bool
func _physics_process(delta: float) -> void:
	saw_player = player_visible()
	if saw_player:
		const player_visible_angriness: float = 4
		add_anger(player_visible_angriness * delta)
	else:
		const anger_falloff: float = -2
		add_anger(anger_falloff * delta)
	var direction: Vector3 = get_movement_direction()
	var current_horizontal_speed: float
	var target_speed: float
	var movement_vector: Vector3
	
	if remaining_idle_time > 0:
		remaining_idle_time = move_toward(remaining_idle_time, 0, delta)
		movement_vector = Vector3.ZERO
	elif attacking or at_navigation_target():
		movement_vector = Vector3.ZERO
	else:
		current_horizontal_speed = velocity.slide(Vector3.UP).length()
		var running := should_run()
		if running:
			target_speed = RUN_SPEED
			footsteps.speed_scale = 1.4
			anim_state = "run"
		else:
			target_speed = WALK_SPEED
			footsteps.speed_scale = .7
			anim_state = "walk"
		movement_vector = direction * target_speed
	if movement_vector != Vector3.ZERO:
		# footsteps.play_step()
		velocity = movement_vector + velocity.project(Vector3.UP)
	else:
		anim_state = "idle"
		var friction = 30
		var current_horizontal_direction = velocity.slide(Vector3.UP).normalized()
		current_horizontal_speed = move_toward(current_horizontal_speed, 0, friction * delta)
		velocity = current_horizontal_direction * current_horizontal_speed + velocity.project(Vector3.UP)

	const rotation_speed: float = 6
	var target_angle = Vector3.MODEL_FRONT.signed_angle_to(direction, Vector3.UP)
	global_rotation.y = lerpf(global_rotation.y, target_angle, rotation_speed * delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	handle_attack()
	handle_collisions()

	

func handle_attack():
	if attacking:
		if knife_active:
			var overlap = knife.get_overlapping_bodies()
			if overlap.is_empty():
				return
			var player: Player = null
			for hit in overlap:
				if hit is Player:
					player = hit
					break
			if player == null:
				return
	elif should_attack():
		anim_tree["parameters/stab/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		attacking = true

func handle_collisions():
	var mass = 1
	for i in get_slide_collision_count():
		var coll = get_slide_collision(i)
		var push_impulse = (velocity * mass).project(-coll.get_normal())
		if coll.get_collider() is RigidBody3D:
			coll.get_collider().apply_central_impulse(push_impulse)

func _process(_delta: float) -> void:
	handle_animations()
