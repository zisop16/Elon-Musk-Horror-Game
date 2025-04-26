extends RigidBody3D

@onready var interaction: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction.tooltip_text = "Press 'F' to pick up"
	interaction.y_offset = .3

func interact():
	var flashlight := Global.player.get_flashlight()
	const battery_amount = 40
	flashlight.add_battery(battery_amount)
	Global.stat_interface.set_flashlight(flashlight.flashlight_battery / Flashlight.flashlight_battery_limit)
	Global.player.sfx_player.play_sound_effect("item_pickup")
	queue_free()

func interaction_requirement() -> String:
	var player_flashlight := Global.player.get_flashlight()
	if player_flashlight == null:
		return "Flashlight Required"
	return ""