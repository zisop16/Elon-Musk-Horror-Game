extends Node3D

@onready var escape_door: EscapeDoor = $EscapeDoor/AnimatableBody3D

func close():
	escape_door.lock()