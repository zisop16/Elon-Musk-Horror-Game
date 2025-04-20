class_name ItemTooltip
extends MeshInstance3D

@onready var label: Label = $SubViewport/Control/Label

func _ready() -> void:
	Global.item_tooltip = self
