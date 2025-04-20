class_name Chainsaw
extends Item

@onready var anim_player = $AnimationPlayer

func activate():
	super.activate()
	anim_player.play("activate")

func deactivate():
	super.deactivate()
	anim_player.pause()