class_name CameraPivot
extends Node3D

@export var mouse_sensitivity: float = .0007
@onready var spring = $"Camera Spring"
@export var max_length := 2.5
@export var min_length := 1.

var target_position: Vector3
func _physics_process(delta: float) -> void:
	var LERP_SPEED = 15
	position = position.lerp(target_position, delta * LERP_SPEED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.y = wrapf(rotation.y, 0, 2*PI)
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clampf(rotation.x, -PI/2, PI/3);

	var zoom_amount = .3
	if event.is_action_pressed("Zoom In"):
		spring.spring_length -= zoom_amount
	if event.is_action_pressed("Zoom Out"):
		spring.spring_length += zoom_amount
	spring.spring_length = clampf(spring.spring_length, min_length, max_length)
