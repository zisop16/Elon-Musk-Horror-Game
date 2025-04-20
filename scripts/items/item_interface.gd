class_name ItemInterface
extends Control

var item_textures: Array[TextureRect] = []
var item_slots: Array[Panel]
var selected_item := 0
@export var flashlight: Texture2D
@export var chainsaw: Texture2D
@export var tv_remote: Texture2D
@export var selected_style: StyleBox
@export var unselected_style: StyleBox

func _ready() -> void:
	var container = $HBoxContainer
	for panel: Panel in container.get_children():
		item_textures.append(panel.get_child(0))
		item_slots.append(panel)
	Global.item_interface = self
	item_slots[selected_item].add_theme_stylebox_override("panel", selected_style)
	
func set_item(slot: int, item: Item):
	var tex := item_textures[slot]
	if item == null:
		tex.texture = null
		return
	if item is Flashlight:
		tex.texture = flashlight
	elif item is Chainsaw:
		tex.texture = chainsaw
	elif item is TvRemote:
		tex.texture = tv_remote
	
## Changes the style of the selected item panel to be hovered
func select_item(slot: int):
	item_slots[selected_item].add_theme_stylebox_override("panel", unselected_style)
	selected_item = slot
	item_slots[selected_item].add_theme_stylebox_override("panel", selected_style)
