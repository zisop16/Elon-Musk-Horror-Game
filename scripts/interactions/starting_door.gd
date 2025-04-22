extends Openable


func interaction_requirement():
	if not Global.watched_tv:
		return "You have a feeling\nyou should turn on the TV..."
	return ""