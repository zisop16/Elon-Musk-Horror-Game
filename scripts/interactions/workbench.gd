class_name Workbench
extends StaticBody3D

@export var item_textures: ItemTextures
@export var recipes: Array[CraftingRecipe]
@export var item_scenes: Dictionary[Item.item_id, PackedScene]
@onready var interaction: InteractionComponent = $InteractionComponent
@onready var input1: TextureRect = %Input1
@onready var input2: TextureRect = %Input2
@onready var output: TextureRect = %Output

func _ready() -> void:
	set_recipe()
	interaction.tooltip_text = "Press 'F' to craft"
	
func interact() -> void:
	var craftable := determine_craftable_recipe()
	if craftable == null:
		return
	var slots = craftable.use_items(Global.player.inventory)
	var item1 := Global.player.inventory[slots[0]]
	var item2 := Global.player.inventory[slots[1]]
	item1.queue_free()
	item2.queue_free()
	Global.player.inventory[slots[0]] = null
	Global.player.inventory[slots[1]] = null
	Global.item_interface.set_item(slots[0], null)
	Global.item_interface.set_item(slots[1], null)
	var crafted_item: Item = item_scenes[craftable.output].instantiate()
	get_tree().root.add_child(crafted_item)
	crafted_item.global_position = global_position
	const y_offset = 1.5
	crafted_item.global_position.y += y_offset
	crafted_item.global_rotation = Global.generate_random_rotation()
	crafted_item.linear_velocity = Vector3(0, 5, 0)
	crafted_items[crafted_item.id] = true
	set_recipe()

func interaction_requirement() -> String:
	var craftable := determine_craftable_recipe()
	if craftable == null:
		return "You can't craft anything"
	return ""

func set_recipe():
	var recipe := determine_recipe()
	input1.texture = item_textures.get_tex(recipe.input1)
	input2.texture = item_textures.get_tex(recipe.input2)
	output.texture = item_textures.get_tex(recipe.output)

func get_recipe_by_output(id: Item.item_id) -> CraftingRecipe:
	for recipe in recipes:
		if recipe.output == id:
			return recipe
	return null

var crafted_items: Dictionary[Item.item_id, bool] = {
	Item.item_id.pickaxe: false,
	Item.item_id.chainsaw: false,
	Item.item_id.gold_chain: false,
	Item.item_id.bucket: false,
}
func determine_recipe() -> CraftingRecipe:
	## Target recipes in ascending order based on crafting history and items in inventory
	if not crafted_items[Item.item_id.pickaxe]:
		return get_recipe_by_output(Item.item_id.pickaxe)
	elif not crafted_items[Item.item_id.bucket]:
		return get_recipe_by_output(Item.item_id.bucket)
	elif not crafted_items[Item.item_id.gold_chain]:
		return get_recipe_by_output(Item.item_id.gold_chain)
	else:
		return get_recipe_by_output(Item.item_id.chainsaw)

func determine_craftable_recipe() -> CraftingRecipe:
	var chainsaw_recipe := get_recipe_by_output(Item.item_id.chainsaw)
	var chain_recipe := get_recipe_by_output(Item.item_id.gold_chain)
	var bucket_recipe := get_recipe_by_output(Item.item_id.bucket)
	var pickaxe_recipe := get_recipe_by_output(Item.item_id.pickaxe)
	var attempt_craft = chainsaw_recipe.use_items(Global.player.inventory)
	if not attempt_craft.count(-1):
		return chainsaw_recipe
	attempt_craft = chain_recipe.use_items(Global.player.inventory)
	if not attempt_craft.count(-1):
		return chain_recipe
	attempt_craft = bucket_recipe.use_items(Global.player.inventory)
	if not attempt_craft.count(-1):
		return bucket_recipe
	attempt_craft = pickaxe_recipe.use_items(Global.player.inventory)
	if not attempt_craft.count(-1):
		return pickaxe_recipe
	return null