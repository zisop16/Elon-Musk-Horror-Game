class_name Chainsaw
extends Item

@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	super._ready()
	interaction.y_offset = .8
	id = item_id.chainsaw

func activate():
	super.activate()
	anim_player.play("activate")

func deactivate():
	super.deactivate()
	anim_player.pause()