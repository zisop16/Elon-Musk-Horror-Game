extends Node3D

func _process(delta: float) -> void:
	if Global.logging:
		print("FPS: ", 1/delta)