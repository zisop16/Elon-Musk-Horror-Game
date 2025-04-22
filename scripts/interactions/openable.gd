class_name Openable
extends AnimatableBody3D

var is_open := false
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var interaction: InteractionComponent = $InteractionComponent
@onready var audio_player: PolyAudioPlayer = $PolyAudioPlayer

func _ready() -> void:
	interaction.tooltip_text = "Press 'F' to open"

func interact():
	if is_open:
		close()
	else:
		open()

func open():
	anim_player.play("open")
	audio_player.play_sound_effect("open")
	is_open = true
	collision_layer = 0b1000
	interaction.tooltip_text = "Press 'F' to close"

func close():
	anim_player.play("close")
	audio_player.play_sound_effect("close")
	is_open = false
	collision_layer = 0b1001
	interaction.tooltip_text = "Press 'F' to open"

func interaction_requirement() -> String:
	return ""