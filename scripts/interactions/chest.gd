extends Openable

@export var item: PackedScene
var item_spawned: bool = false

func open():
	super.open()
	if not item_spawned:
		spawn_item()
	interaction.y_offset = 1.2

func spawn_item():
	var spawned_item = item.instantiate()
	get_tree().root.add_child(spawned_item)
	spawned_item.global_position = global_position
	const y_offset = 1.1
	spawned_item.global_position.y += y_offset
	spawned_item.global_rotation = Global.generate_random_rotation()
	var angle: float = randf_range(-PI/3, PI/3)
	var direction_vec := transform.basis.z.rotated(Vector3.UP, angle)
	var horizontal_speed := 2.5
	var vertical_speed := 7.
	spawned_item.linear_velocity = direction_vec * horizontal_speed + Vector3.UP * vertical_speed
	item_spawned = true
