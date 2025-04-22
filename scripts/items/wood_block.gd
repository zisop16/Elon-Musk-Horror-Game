class_name WoodBlock
extends Item

func _ready() -> void:
	super._ready()
	interaction.y_offset = .6
	id = item_id.wood_block