class_name Item
extends RigidBody3D

@onready var interaction: InteractionComponent = $InteractionComponent
enum item_id {flashlight, tv_remote, chainsaw, wood_block, pickaxe, bucket, iron_ingot, gold_chain, gold_ingot}

## Whether the item is currently activated
var active: bool = false
var attached_node: Node3D = null
var id: item_id
const item_coll_mask := 0b1111
const item_coll_layer := 0b1000

func _ready() -> void:
	interaction.tooltip_text = "Press 'F' to pick up"
	interaction.y_offset = .3

func attach(node: Node3D):
	gravity_scale = 0
	collision_mask = 0
	collision_layer = 0
	attached_node = node
	interaction.disable_outline()

## Drops the item from the player's hand
## Item should silently deactivate if dropped
func drop():
	gravity_scale = 1
	collision_mask = item_coll_mask
	collision_layer = item_coll_layer
	visible = true
	global_position = attached_node.global_position
	global_rotation = attached_node.global_rotation
	attached_node = null
	active = false

func _physics_process(_delta: float) -> void:
	if attached_node != null:
		global_position = attached_node.global_position
		global_rotation = attached_node.global_rotation

func interaction_requirement() -> String:
	return ""

func set_active(setting: bool) -> void:
	active = setting

func activate():
	set_active(true)

func deactivate():
	set_active(false)

func toggle():
	if active:
		deactivate()
	else:
		activate()

## Player class handles item interaction
func interact():
	pass
