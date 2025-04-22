class_name MineComponent
extends Node3D

@export var requires_pickaxe = false
@export var dropped_item: PackedScene
@export var particle_effect: PackedScene = null

## Generate uniform random euler rotation
func generate_random_rotation() -> Vector3:
	## Choose three points u, v, w ∈ [0,1] uniformly at random. A uniform, random quaternion is given by the simple expression:
	## h = ( sqrt(1-u) sin(2πv), sqrt(1-u) cos(2πv), sqrt(u) sin(2πw), sqrt(u) cos(2πw))
	var u := randf()
	var v := randf()
	var w := randf()
	var h := Quaternion(sqrt(1-u) * sin(2*PI*v), sqrt(1-u) * cos(2*PI*v), sqrt(u) * sin(2*PI*w), sqrt(u) * cos(2*PI*w))
	return h.get_euler()


func mine():
	var item: Item = dropped_item.instantiate()
	if particle_effect != null:
		var effect: GPUParticles3D = particle_effect.instantiate()
		get_tree().root.add_child(effect)
		effect.global_position = global_position
	get_tree().root.add_child(item)
	item.global_position = global_position
	item.rotation = generate_random_rotation()
	get_parent().queue_free()