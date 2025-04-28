class_name PolyAudioPlayer
extends AudioStreamPlayer3D

@export var sound_effects: Dictionary[String, SoundEffect]
var streams: Dictionary[String, Array]

func _ready() -> void:
	stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32

@export_range(0, 20, .01) var delay: float = 0
var last_played: float = 0
var speed_scale: float = 1

func play_sound_effect(tag: String) -> void:
	var total_delay = sound_effects[tag].delay + delay
	var next_play_time = last_played + (total_delay / speed_scale)
	if Global.time() < next_play_time:
		return
	last_played = Global.time()

	var sound_effect := sound_effects[tag]
	var audio_stream := sound_effect.get_sound()
	if audio_stream == null:
		return
	if !playing:
		play()
	var poly_stream_playback := get_stream_playback()

	if not streams.has(tag):
		streams[tag] = []
	streams[tag].append(poly_stream_playback.play_stream(audio_stream, 0, sound_effect.volume, sound_effect.get_pitch()))

func stop_sound_effect(tag: String) -> void:
	if not streams.has(tag):
		return
	var poly_stream_playback := get_stream_playback()
	for stream_id in streams[tag]:
		poly_stream_playback.stop_stream(stream_id)

func stop_sound_effects() -> void:
	for tag in streams:
		stop_sound_effect(tag)
