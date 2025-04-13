extends Item

@onready var spotlight = $SpotLight3D

func set_active(setting: bool):
	super.set_active(setting)
	spotlight.visible = setting