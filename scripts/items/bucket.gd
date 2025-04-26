class_name Bucket
extends Item

var has_water: bool = true
@onready var water: MeshInstance3D = $Water

func _ready() -> void:
	super._ready()
	id = item_id.bucket
	water.visible = has_water

func use_water():
	has_water = false
	water.visible = false

func add_water():
	has_water = true
	water.visible = true

