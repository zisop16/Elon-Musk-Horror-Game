class_name CraftingRecipe
extends Resource

@export var input1: Item.item_id
@export var input2: Item.item_id
@export var output: Item.item_id

func use_items(inventory: Array[Item]) -> Array[int]:
	var slot1: int = -1
	var slot2: int = -1
	for ind in inventory.size():
		if inventory[ind] == null:
			continue
		var id := inventory[ind].id
		if slot1 == -1 and input1 == id:
			slot1 = ind
			continue
		if slot2 == -1 and input2 == id:
			slot2 = ind
	return [slot1, slot2]
