class_name InteractionComponent
extends Node3D

@onready var interactor: CollisionObject3D = get_parent()
@export var outline_material: ShaderMaterial
var tooltip_text := "Press 'F' to interact"

func _physics_process(_delta: float) -> void:
	var hovered = Global.player.hovered_object == interactor
	outline_material.set_shader_parameter("enabled", hovered)
	if hovered:
		Global.item_tooltip.global_position = global_position
		Global.item_tooltip.label.text = tooltip_text
