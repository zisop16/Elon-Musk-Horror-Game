class_name MineComponent
extends Node3D

@export var requires_pickaxe = false
@export var dropped_item: PackedScene
@export var particle_effect: PackedScene = null


func mine():
	var item: Item = dropped_item.instantiate()
	if particle_effect != null:
		var effect: GPUParticles3D = particle_effect.instantiate()
		get_tree().root.add_child(effect)
		effect.global_position = global_position
	get_tree().root.add_child(item)
	item.global_position = global_position
	item.rotation = Global.generate_random_rotation()
	get_parent().queue_free()