class_name InteractionComponent
extends Node3D

@onready var interactor: CollisionObject3D = get_parent()
@export var outline_material_holder: MeshInstance3D
var outline_material: ShaderMaterial
var tooltip_text := "Press 'F' to interact"
var y_offset := 0.

func _ready() -> void:
	if outline_material_holder:
		outline_material = outline_material_holder.get_active_material(0).next_pass
	# outline_material_holder.get_active_material(0).next_pass = null

func show_tooltip(coll_point: Vector3):
	Global.item_tooltip.global_position = global_position
	Global.item_tooltip.global_position.y += y_offset
	if outline_material:
		outline_material.set_shader_parameter("enabled", true)
	else:
		## Currently only defined for the lake
		interactor.indicate_interaction(true, coll_point)
	var requirement = interactor.interaction_requirement()
	if requirement == "":
		Global.item_tooltip.label.text = tooltip_text
		Global.item_tooltip.label.label_settings.font_color = Color.WHITE
	else:
		Global.item_tooltip.label.text = requirement
		Global.item_tooltip.label.label_settings.font_color = Color.DARK_RED

func disable_outline():
	if outline_material:
		outline_material.set_shader_parameter("enabled", false)
	else:
		interactor.indicate_interaction(false)
