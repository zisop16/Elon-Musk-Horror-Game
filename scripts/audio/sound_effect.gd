class_name SoundEffect
extends Resource

@export var sounds: Array[AudioStream]
@export_range(-40, 40, 1) var volume: float = 0
@export_range(0, 4, .01) var pitch_variation: float = 0

func get_sound() -> AudioStream:
	if len(sounds) == 0:
		printerr("Attempted to play a sound effect that didnt exist")
		return null
	var random_index = randi_range(0, len(sounds) - 1)
	return sounds[random_index]

func get_pitch() -> float:
	var exponent = randf_range(-pitch_variation, pitch_variation)
	var base = 2
	return base**exponent
		