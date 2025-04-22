extends Node3D

var capture_mouse: bool = true

func _ready() -> void:
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var fps_average = 0

var last_logged = 0
var logging_interval = .5

func _process(delta: float) -> void:
	var curr_fps = 1/delta
	if Input.is_action_just_pressed("Free Mouse"):
		capture_mouse = not capture_mouse
		if capture_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		