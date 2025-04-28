class_name Lake
extends StaticBody3D

@onready var interaction: InteractionComponent = $InteractionComponent
var water_shader: ShaderMaterial

func _ready() -> void:
	var water: MeshInstance3D = $Water
	water_shader = water.get_active_material(0)
	interaction.y_offset = .4
	interaction.tooltip_text = "Press 'F' to fill bucket"

func indicate_interaction(flag: bool, coll_point: Vector3 = Vector3.ZERO):
	var default_color := Color("151c3d")
	var highlight_color := Color("344599")
	if flag:
		water_shader.set_shader_parameter("albedo", highlight_color)
		Global.item_tooltip.global_position = coll_point + Vector3.UP * interaction.y_offset
	else:
		water_shader.set_shader_parameter("albedo", default_color)
	

func interact():
	var bucket = Global.player.inventory[Global.player.equipped_item] as Bucket
	bucket.add_water()
	Global.player.sfx_player.play_sound_effect("water_bucket")

func interaction_requirement() -> String:
	var item := Global.player.inventory[Global.player.equipped_item]
	if item is Bucket:
		var bucket = item as Bucket
		if not bucket.has_water:
			return ""
	return "It appears to have enough\nwater to fill a bucket..."