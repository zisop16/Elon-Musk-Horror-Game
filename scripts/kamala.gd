class_name Kamala
extends CharacterBody3D

@onready var footsteps = $FootstepPlayer
@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var anim_tree: AnimationTree = $Model/AnimationTree
@onready var knife_hitbox: Area3D = %KamalaKnife
@onready var sfx_player: PolyAudioPlayer = $SFXPlayer
@export var blood_effect: PackedScene
@export var kamala_flee_locations: Node3D
@export var dissolve_effect: PackedScene
var activated := false
var next_activation_time: float = 10 ** 9

const WALK_SPEED: float = 3.2
const RUN_SPEED: float = 6.5
const JUMP_VELOCITY: float = 5

enum {WALK, IDLE, RUN}
var anim_state := "idle"
var anim_amounts: Dictionary = {
	walk = 0,
	run = 0
}

func _ready() -> void:
	Global.kamala = self
	find_all_materials()
	Global.map.darkened.connect(self.activate)

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
	navigation.target_position = pos
	add_anger(loudness)

func should_run() -> bool:
	return dissolving or anger > run_anger_threshold

func following_player() -> bool:
	# Fix later
	return not dissolving
	# return not dissolving and saw_player or anger > follow_player_anger_threshold

func get_movement_direction() -> Vector3:
	if following_player():
		navigation.target_position = Global.player.global_position
	var direction := navigation.get_next_path_position() - global_position
	direction = direction.slide(Vector3.UP)
	direction = direction.normalized()

	return direction



## Casts a ray from kamala to the player, true if the ray is not obstructed
## And the player is within kamala's viewing distance
func player_visible() -> bool:
	const viewing_distance: float = 20
	var diff = Global.player.global_position - global_position
	## Short circuit if the player is outside of viewing distance
	if diff.length() > viewing_distance:
		return false
	var space_state := get_world_3d().direct_space_state
	var y_offset = Vector3.UP * .5
	var query := PhysicsRayQueryParameters3D.create(global_position + y_offset, Global.player.global_position + y_offset)
	## Will collide with terrain, player
	query.collision_mask = 0b10
	var result := space_state.intersect_ray(query)
	## For some reason, this is actually possible XD?
	if result.is_empty():
		return false
	var coll = result["collider"]
	return coll == Global.player

const attack_range: float = 1.1

func should_attack() -> bool:
	if not saw_player:
		return false
	var player_pos := Global.player.global_position
	var diff := (player_pos - global_position).slide(Vector3.UP)
	return diff.length() < attack_range

var attacking := false
func activate_knife_hitbox():
	knife_hitbox.monitoring = true
	sfx_player.play_sound_effect("swing")
func end_knife_hitbox():
	knife_hitbox.monitoring = false
func end_attack():
	attacking = false
func cancel_attack():
	attacking = false
	knife_hitbox.monitoring = false
	anim_tree["parameters/stab/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT

func set_dissolve(flag: bool):
	dissolving = flag
	if dissolving:
		initial_time_dissolving = Global.time()
		navigation.target_position = find_respawn_location()
		dissolve_all_materials()
		var effect = dissolve_effect.instantiate()
		get_tree().root.add_child(effect)
		effect.global_position = global_position
		effect.global_rotation = global_rotation
	else:
		undissolve_all_materials()
		var dormant_duration := randf_range(10, 30)
		next_activation_time = Global.time() + dormant_duration
		activated = false
		visible = false
		if attacking:
			cancel_attack()
		being_flashed = false
		at_navigation_target = false
		anim_tree["parameters/total_speed/scale"] = 1

var saw_player: bool
var screaming := false

func set_scream(flag: bool):
	screaming = flag
	if screaming:
		sfx_player.play_sound_effect("scream")
	else:
		sfx_player.stop_sound_effect("scream")

func handle_scream():
	if dissolving or being_flashed:
		return
	if saw_player and not screaming:
		set_scream(true)
	if not saw_player and screaming:
		set_scream(false)

func _physics_process(delta: float) -> void:
	if !activated:
		if Global.time() > next_activation_time:
			activate()
		else:
			return
	saw_player = player_visible()
	handle_flash()
	handle_scream()
	
	if not dissolving and saw_player:
		const player_visible_angriness: float = 2
		add_anger(player_visible_angriness * delta)
	else:
		const anger_falloff: float = -3
		add_anger(anger_falloff * delta)
	var direction: Vector3 = get_movement_direction()
	var current_horizontal_speed: float
	var target_speed: float
	var movement_vector: Vector3
	
	if remaining_idle_time > 0:
		remaining_idle_time = move_toward(remaining_idle_time, 0, delta)
		movement_vector = Vector3.ZERO
	elif attacking or at_navigation_target or being_flashed:
		movement_vector = Vector3.ZERO
		if at_navigation_target:
			# Decide next navigation target...
			at_navigation_target = false
		if dissolving:
			var time_spent_dissolving = Global.time() - initial_time_dissolving
			if time_spent_dissolving > dissolve_duration:
				set_dissolve(false)
				
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
		footsteps.play_step()
		velocity = movement_vector + velocity.project(Vector3.UP)
	else:
		anim_state = "idle"
		var friction = 30
		var current_horizontal_direction = velocity.slide(Vector3.UP).normalized()
		current_horizontal_speed = move_toward(current_horizontal_speed, 0, friction * delta)
		velocity = current_horizontal_direction * current_horizontal_speed + velocity.project(Vector3.UP)

	if not (dissolving or being_flashed):
		const rotation_speed: float = 6
		var target_angle = Vector3.MODEL_FRONT.signed_angle_to(direction, Vector3.UP)
		global_rotation.y = lerpf(global_rotation.y, target_angle, rotation_speed * delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

	navigation.velocity = velocity

func handle_attack():
	if dissolving or being_flashed:
		return
	if attacking:
		if not knife_hitbox.monitoring:
			return
		var overlap = knife_hitbox.get_overlapping_bodies()
		if overlap.is_empty():
			return
		var player: Player = null
		for hit in overlap:
			if hit is Player:
				player = hit
				break
		if player == null:
			return
		var blood_particles = blood_effect.instantiate()
		var y_level = knife_hitbox.global_position.y
		var direction = (knife_hitbox.global_position - player.global_position).slide(Vector3.UP).normalized()
		var angle = Vector3.MODEL_FRONT.signed_angle_to(direction, Vector3.UP)
		player.model.add_child(blood_particles)
		blood_particles.global_position = player.model.global_position
		blood_particles.global_position += direction * .3
		blood_particles.global_position.y = y_level
		blood_particles.global_rotation = Vector3(0, angle, 0)
		sfx_player.play_sound_effect("stab")
		const knife_damage = 40
		Global.player.add_health(-knife_damage)
		end_knife_hitbox()
			
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

func activate():
	global_position = find_respawn_location()
	activated = true
	visible = true

func find_respawn_location() -> Vector3:
	var locations = kamala_flee_locations.get_children() as Array[Node3D]
	locations.shuffle()
	for location in locations:
		var pos: Vector3 = location.global_position
		var horizontal_distance := (pos - Global.player.global_position).slide(Vector3.UP)
		var min_dist: float = 40
		if horizontal_distance.length() > min_dist:
			return pos
	return locations[0].global_position

## How long the player must flash kamala before she runs
const flashlight_endurance: float = 2.5
func handle_flash():
	if dissolving:
		return
	if flash_tick_remaining:
		flash_tick_remaining = false
		if not being_flashed:
			being_flashed = true
			initial_time_flashed = Global.time()
			set_scream(false)
	else:
		being_flashed = false
	var should_dissolve = being_flashed and ((Global.time() - initial_time_flashed) > flashlight_endurance)
	if should_dissolve:
		set_dissolve(true)
	if being_flashed:
		anim_tree["parameters/total_speed/scale"] = 0
	else:
		anim_tree["parameters/total_speed/scale"] = 1


var dissolving := false
var being_flashed := false
var initial_time_flashed: float
var initial_time_dissolving: float
## When kamala is flashed by a flashlight, she is given a flash tick
## This flash tick is then processed by physics_process, which changes it to false for the next frame
## If flash_tick_remaining is false on any given physics process, kamala is no longer being flashed
var flash_tick_remaining := false
func receive_flashlight():
	if dissolving:
		return
	flash_tick_remaining = true

func _process(_delta: float) -> void:
	handle_animations()


var at_navigation_target := false

## Navigation agent method handles

func on_target_reached() -> void:
	at_navigation_target = true

func on_navigation_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.project(Vector3.UP) + safe_velocity.slide(Vector3.UP)
	move_and_slide()
	handle_attack()
	handle_collisions()

var all_materials: Array[ShaderMaterial]
const dissolve_duration: float = 1.5
func find_all_materials():
	var skeleton = $Model/Armature/Skeleton3D
	find_materials_recursive(skeleton)
	for material in all_materials:
		material.set_shader_parameter("dissolve_duration", dissolve_duration)

func find_materials_recursive(root: Node3D):
	if root == null:
		return
	if root is MeshInstance3D:
		var mesh := root as MeshInstance3D
		all_materials.append(mesh.get_active_material(0))
	for child in root.get_children():
		find_materials_recursive(child)

func dissolve_all_materials():
	for material in all_materials:
		start_material_dissolve(material)

func undissolve_all_materials():
	for material in all_materials:
		disable_material_dissolve(material)		

func start_material_dissolve(mat: ShaderMaterial):
	mat.set_shader_parameter("dissolve_start_time", Global.time())
	mat.set_shader_parameter("enable_dissolve", true)

func disable_material_dissolve(mat: ShaderMaterial):
	mat.set_shader_parameter("enable_dissolve", false)
