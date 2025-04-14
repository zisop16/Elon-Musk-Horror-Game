class_name PolyAudioPlayer
extends AudioStreamPlayer3D

@export var sound_effects: Dictionary[String, SoundEffect]

func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32

@export_range(0, 4, .1) var delay: float = 0
var last_played: float = 0
var speed_scale: float = 1

func play_sound_effect(tag: String) -> void:
	var next_play_time = last_played + (delay / speed_scale)
	if Global.time() < next_play_time:
		return
	last_played = Global.time()

	var sound_effect := sound_effects[tag]
	var audio_stream := sound_effect.get_sound()
	if audio_stream == null:
		return
	if !playing:
		self.play()
	var poly_stream_playback := self.get_stream_playback()

	poly_stream_playback.play_stream(audio_stream, 0, sound_effect.volume, sound_effect.get_pitch())
