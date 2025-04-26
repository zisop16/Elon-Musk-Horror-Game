extends RigidBody3D


func _physics_process(delta: float) -> void:
	var root = find_child("RootNode")
	print(global_rotation, " ", root.global_rotation, " ", get_parent().global_rotation, " ", root.rotation)