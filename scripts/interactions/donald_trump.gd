class_name DonaldTrump
extends StaticBody3D

@onready var interaction: InteractionComponent = $InteractionComponent
@onready var audio_player: PolyAudioPlayer = $PolyAudioPlayer
@onready var gold_spawn: Node3D = $GoldSpawnPoint
@export var gold_ingot: PackedScene
var found_bucket := false

func _ready() -> void:
	interaction.tooltip_text = "Press 'F' to give him\nYour bucket"

func interact():
	var gold: GoldIngot = gold_ingot.instantiate()
	get_tree().root.add_child(gold)
	gold.global_position = gold_spawn.global_position
	var forward_direction := transform.basis.z
	var angle_bound := PI/4
	var random_angle := randf_range(-angle_bound, angle_bound)
	var vertical_component := Vector3.UP * 3.
	var forward_component := forward_direction.rotated(Vector3.UP, random_angle) * 4.
	gold.linear_velocity = vertical_component + forward_component
	Global.player.remove_item(Global.player.equipped_item)
	audio_player.play_sound_effect("thank")
	audio_player.stop_sound_effect("ask_bucket")
	found_bucket = true

func interaction_requirement() -> String:
	var player := Global.player
	if player.inventory[player.equipped_item] is Bucket:
		return ""
	return "He appears to be looking\nFor a bucket..."

func _physics_process(_delta: float) -> void:
	if found_bucket:
		return
	if (Global.player.global_position - global_position).length() < 9:
		audio_player.play_sound_effect("ask_bucket")