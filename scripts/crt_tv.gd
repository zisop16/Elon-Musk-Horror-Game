class_name CrtTv
extends StaticBody3D


@onready var audio_player: PolyAudioPlayer = $"PolyAudioPlayer"
@onready var video_player: VideoStreamPlayer = $"SubViewport/TV Screen/VideoStreamPlayer"
@onready var light: SpotLight3D = $SpotLight3D
var playing_video: bool = false

func _ready() -> void:
	play_static()

func play_video() -> void:
	audio_player.stop_sound_effects()
	audio_player.play_sound_effect("informational_video")
	video_player.play()
	playing_video = true

func play_static() -> void:
	audio_player.stop_sound_effects()
	audio_player.play_sound_effect("tv_static")
	video_player.stop()
	playing_video = false

func _on_video_finished() -> void:
	play_static()
	playing_video = false


func turn_off():
	light.visible = false