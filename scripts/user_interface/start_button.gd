extends Button

@export var game: PackedScene
var game_thread: Thread
var game_obj: Node3D
var game_instantiated := false
var instantiating := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_thread = Thread.new()

func create_game():
	game_obj = game.instantiate()
	game_instantiated = true

func start_click() -> void:
	print("hi1")
	if not instantiating:
		game_thread.start(create_game)
		instantiating = true
	if game_instantiated:
		get_tree().root.add_child(game_obj)
		get_parent().queue_free()