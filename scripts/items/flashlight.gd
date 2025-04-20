class_name Flashlight
extends Item

@onready var spotlight = $SpotLight3D
@onready var player: PolyAudioPlayer = $AudioPlayer

func activate():
	super.activate()
	player.play_sound_effect("on")
	spotlight.visible = true

func deactivate():
	super.deactivate()
	player.play_sound_effect("off")
	spotlight.visible = false