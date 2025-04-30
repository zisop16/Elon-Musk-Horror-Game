class_name FriendlyKamala
extends Node3D

var played_audio := false
var time_played_audio: float
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var interaction: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction.tooltip_text = "Press 'F' to talk to Kamala!"

func interact():
	if played_audio:
		return
	audio_player.play()
	time_played_audio = Global.time()
	interaction.tooltip_text = ""
	Global.map.lock_house()
	played_audio = true

func _physics_process(_delta: float) -> void:
	var diff = Global.player.global_position - global_position
	global_rotation.y = Vector3.MODEL_FRONT.signed_angle_to(diff, Vector3.UP)

const time_before_change: float = 14.86
func _process(_delta: float) -> void:
	if played_audio:
		if Global.time() - time_played_audio > time_before_change:
			Global.map.become_dark()
			queue_free()

func interaction_requirement():
	return ""
