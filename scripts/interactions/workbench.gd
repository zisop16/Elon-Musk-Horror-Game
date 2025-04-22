class_name Workbench
extends StaticBody3D

@export var item_textures: ItemTextures
@export var recipes: Array[CraftingRecipe]
@onready var interaction: InteractionComponent = $InteractionComponent
@onready var input1: TextureRect = %Input1
@onready var input2: TextureRect = %Input2
@onready var output: TextureRect = %Output

func _ready() -> void:
	set_recipe()
	interaction.tooltip_text = "Press 'F' to craft"
	
func interact() -> void:
	pass

func interaction_requirement() -> String:
	return ""

func set_recipe():
	var recipe := determine_recipe()
	input1.texture = item_textures.get_tex(recipe.input1)
	input2.texture = item_textures.get_tex(recipe.input2)
	output.texture = item_textures.get_tex(recipe.output)

func determine_recipe() -> CraftingRecipe:
	return recipes[0]