extends AnimatableBody3D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func sweep():
	visible = true
	anim_player.play("sweep")
