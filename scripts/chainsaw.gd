class_name Chainsaw
extends Item

@onready var anim_player = $Model/AnimationPlayer

func set_active(setting: bool):
	super.set_active(setting)
	if setting:
		anim_player.play("activate")
	else:
		anim_player.pause()