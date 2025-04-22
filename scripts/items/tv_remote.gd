class_name TvRemote
extends Item

@export var tv: CrtTv
@onready var audio_player: PolyAudioPlayer = $PolyAudioPlayer

func _ready() -> void:
	super._ready()
	id = item_id.tv_remote

## TV remote will toggle the tv
## So it does not carry its own state of active or not_active
func toggle():
	Global.watched_tv = true
	if tv.playing_video:
		tv.play_static()
	else:
		tv.play_video()
	audio_player.play_sound_effect("toggle")


func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	pass
