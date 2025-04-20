class_name TvRemote
extends Item

@export var tv: CrtTv

func activate():
	super.activate()
	tv.play_video()

func deactivate():
	super.deactivate()
	tv.play_static()

func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	# Global.update_log("pos", global_position)
