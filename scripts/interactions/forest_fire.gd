extends StaticBody3D

@onready var interaction: InteractionComponent = $InteractionComponent
@export var cybertruck: CyberTruck
@onready var audio_player: PolyAudioPlayer = $PolyAudioPlayer

func _ready() -> void:
	interaction.y_offset = .5
	interaction.tooltip_text = "Press 'F' to douse the fire"

func interact():
	# Reparent the audio player so it doesn't free itself
	audio_player.play_sound_effect("douse_fire")
	audio_player.reparent(get_tree().root)
	cybertruck.drive()
	var bucket := Global.player.inventory[Global.player.equipped_item] as Bucket
	bucket.use_water()
	queue_free()

func interaction_requirement() -> String:
	var player_item = Global.player.inventory[Global.player.equipped_item]
	if player_item is Bucket:
		var bucket = player_item as Bucket
		if bucket.has_water:
			return ""
	return "You need a water bucket\nto put out this fire..."

func indicate_interaction(flag: bool, coll_point: Vector3):
	pass