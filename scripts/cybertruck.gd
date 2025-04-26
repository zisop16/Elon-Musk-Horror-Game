class_name CyberTruck
extends AnimatableBody3D

@export var broken_fence: Node3D
@export var unbroken_fence: Node3D
@export var tree_fire: Node3D
@export var big_explosion: PackedScene
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

func drive() -> void:
	anim_player.play("car_anims/crash")
	audio_player.play()

func crash() -> void:
	unbroken_fence.queue_free()
	broken_fence.visible = true
	var fence_fire_sfx = broken_fence.find_child("AudioStreamPlayer3D")
	fence_fire_sfx.play()
	var explosion = big_explosion.instantiate()
	get_tree().root.add_child(explosion)
	explosion.global_position = global_position
	explosion.global_position.y += 1

func burn() -> void:
	tree_fire.visible = true
	var explosion = big_explosion.instantiate()
	get_tree().root.add_child(explosion)
	explosion.global_position = global_position