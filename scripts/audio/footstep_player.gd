class_name FootstepPlayer
extends PolyAudioPlayer

@onready var parent: Node3D = get_parent()
var effect_names: Dictionary[int, String] = {
	0: "stone",
	1: "dirt",
	2: "grass",
	3: "dirt",
	4: "sand",
	5: "stone",
	6: "gravel",
	7: "iron",
	8: "iron",
	9: "stone",
	10: "iron",
	11: "stone",
	12: "stone",
	13: "stone"
}

func play_step():
	var effect_name := effect_names[get_terrain_id()]
	play_sound_effect(effect_name)

func get_terrain_id() -> int:
	var tex_blend := Global.terrain.data.get_texture_id(parent.global_position)
	if tex_blend[2] > .5:
		return tex_blend[1] as int
	else:
		return tex_blend[0] as int