class_name Openable
extends StaticBody3D

var is_open := false
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var interaction: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction.tooltip_text = "Press 'F' to open"

func interact():
	if is_open:
		close()
	else:
		open()

func open():
	anim_player.play("open")
	is_open = true
	interaction.tooltip_text = "Press 'F' to close"

func close():
	anim_player.play("close")
	is_open = false
	interaction.tooltip_text = "Press 'F' to open"
