class_name Map
extends Node3D

var capture_mouse: bool = true


func _ready() -> void:
	if capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.map = self

var fps_average = 0

var last_logged = 0
var logging_interval = .5

func _process(delta: float) -> void:
	var curr_fps = 1/delta
	if curr_fps < 100:
		print("fps drop ", curr_fps)
		pass
	
	
	if Input.is_action_just_pressed("Free Mouse"):
		capture_mouse = not capture_mouse
		if capture_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

@export var start_wall: StaticBody3D
@export var sweep_wall: AnimatableBody3D
@onready var environment: WorldEnvironment = $WorldEnvironment
@onready var deleted_objects: Node3D = $DeletedByKamala
@onready var moonlight: DirectionalLight3D = $Moonlight
@export var dark_environment: Environment
@onready var ambient_noise: AudioStreamPlayer = $AmbientNoise
@export var wind: AudioStream
signal darkened

func lock_house():
	var house = deleted_objects.find_child("House")
	house.close()

func become_dark():
	deleted_objects.queue_free()
	ambient_noise.stop()
	ambient_noise.stream = wind
	ambient_noise.play()
	sweep_wall.sweep()
	sweep_wall.visible = true
	moonlight.visible = true
	environment.environment = dark_environment
	darkened.emit()