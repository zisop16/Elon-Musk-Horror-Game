class_name EscapeDoor
extends Openable

var locked := false

func interaction_requirement():
	if locked:
		return "The door is locked."
	if Global.player.get_flashlight() != null:
		return ""
	return "You shouldn't go outside\nwithout your flashlight..."

func lock():
	close()
	locked = true