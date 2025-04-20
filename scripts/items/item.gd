class_name Item
extends RigidBody3D

@export var outline_material: ShaderMaterial

var equipped: bool = false
var active: bool = false
var attached_node: Node3D = null
const item_coll_mask := 0b1111
const item_coll_layer := 0b1000

func _ready() -> void:
	var interaction: InteractionComponent = $InteractionComponent
	interaction.tooltip_text = "Press 'F' to pick up"
	set_scale_recursive()

func attach(node: Node3D):
	gravity_scale = 0
	collision_mask = 0
	attached_node = node

func detach():
	gravity_scale = 1
	collision_mask = item_coll_mask
	collision_layer = item_coll_layer
	attached_node = null

func _physics_process(_delta: float) -> void:
	if attached_node != null:
		global_position = attached_node.global_position
		global_rotation = attached_node.global_rotation
	var hovered = Global.player.hovered_object == self
	outline_material.set_shader_parameter("enabled", hovered)


func set_scale_recursive():
	# First, we'll set this node to use "top level" mode. This basically
	# disconnects it from its parent's transform3d
	var was_top_level := top_level
	top_level = true

	# If the node has a scale of 1, there's nothing for us to do.
	if scale.x == 1: return

	# Apply scale to all children before we reset it
	for child in get_children():
		if child is Node3D:
			child.scale *= scale
			child.transform.origin *= scale

	# Reset the rigidbody's scale to 1
	scale = Vector3.ONE
	top_level = was_top_level

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

func set_equipped(setting: bool) -> void:
	equipped = setting
	visible = equipped
	if not setting:
		set_active(false)

func equip():
	set_equipped(true)

func dequip():
	set_equipped(false)

## Player class handles item interaction
func interact():
	pass
