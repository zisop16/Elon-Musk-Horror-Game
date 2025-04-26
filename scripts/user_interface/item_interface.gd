class_name ItemInterface
extends Control

var texture_rects: Array[TextureRect] = []
var item_slots: Array[Panel]
var selected_item := 0
@export var item_textures: ItemTextures
@export var selected_style: StyleBox
@export var unselected_style: StyleBox

func _ready() -> void:
	var container = $HBoxContainer
	for panel: Panel in container.get_children():
		texture_rects.append(panel.get_child(0))
		item_slots.append(panel)
	Global.item_interface = self
	item_slots[selected_item].add_theme_stylebox_override("panel", selected_style)
	
func set_item(slot: int, item: Item):
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
