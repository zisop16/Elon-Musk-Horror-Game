class_name ItemTextures
extends Resource

@export var item_textures: Dictionary[Item.item_id, Texture2D]

func get_tex(id: Item.item_id) -> Texture2D:
	return item_textures[id]
