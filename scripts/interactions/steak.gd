extends RigidBody3D

@onready var interaction: InteractionComponent = $InteractionComponent

func _ready() -> void:
	interaction.tooltip_text = "Press 'F' to pick up"
	interaction.y_offset = .3

func interact():
	## The steak will regenerate the player to full stamina
	Global.player.stamina = Global.player.max_stamina
	Global.stat_interface.set_stamina(Global.player.stamina / Player.max_stamina)
	Global.player.sfx_player.play_sound_effect("eat")
	queue_free()

func interaction_requirement() -> String:
	return ""