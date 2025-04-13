extends Node

var logging = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func time() -> float:
	return Time.get_ticks_usec() / 10.**6