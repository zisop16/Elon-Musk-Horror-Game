class_name ItemInterface
extends Control

var texture_rects: Array[TextureRect] = []
var item_slots: Array[Panel]
var selected_item := 0
var last_time_used: float = 0
@onready var container = $HBoxContainer
@export var fade_curve: Curve
@export var item_textures: ItemTextures
@export var selected_style: StyleBox
@export var unselected_style: StyleBox

func _ready() -> void:
	
	for panel: Panel in container.get_children():
		texture_rects.append(panel.get_child(0))
		item_slots.append(panel)
	Global.item_interface = self
	item_slots[selected_item].add_theme_stylebox_override("panel", selected_style)
	
func set_item(slot: int, item: Item):
	last_time_used = Global.time()
	var tex := texture_rects[slot]
	if item == null:
		tex.texture = null
		return
	tex.texture = item_textures.get_tex(item.id)
	
	
## Changes the style of the selected item panel to be hovered
func select_item(slot: int):
	item_slots[selected_item].add_theme_stylebox_override("panel", unselected_style)
	selected_item = slot
	item_slots[selected_item].add_theme_stylebox_override("panel", selected_style)
	last_time_used = Global.time()

func _process(_delta: float) -> void:
	const fade_duration: float = 7
	var fade_progress = (Global.time() - last_time_used) / fade_duration
	var alpha := fade_curve.sample(fade_progress)
	container.modulate = Color(1, 1, 1, alpha)