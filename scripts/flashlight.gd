extends Item

@onready var spotlight = $SpotLight3D
@onready var player: PolyAudioPlayer = $AudioPlayer

func set_active(setting: bool):
	super.set_active(setting)
	spotlight.visible = setting

func toggle():
	super.toggle()
	if active:
		player.play_sound_effect("on")
	else:
		player.play_sound_effect("off")