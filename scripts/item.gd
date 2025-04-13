class_name Item
extends Node3D

var equipped: bool = false
var active: bool = false

func _ready() -> void:
	deactivate()
	dequip()

func set_active(setting: bool) -> void:
	active = setting

func activate():
	set_active(true)

func deactivate():
	set_active(false)

func toggle():
	set_active(not active)

func set_equipped(setting: bool) -> void:
	equipped = setting
	visible = equipped
	if not setting:
		set_active(false)

func equip():
	set_equipped(true)

func dequip():
	set_equipped(false)
