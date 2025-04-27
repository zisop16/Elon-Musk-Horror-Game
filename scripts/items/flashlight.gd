class_name Flashlight
extends Item

@onready var spotlight = $SpotLight3D
@onready var player: PolyAudioPlayer = $AudioPlayer
# Seconds of duration left in battery
const flashlight_battery_limit: float = 30
var flashlight_battery := flashlight_battery_limit

func _ready() -> void:
	super._ready()
	id = item_id.flashlight

func activate():
	super.activate()
	player.play_sound_effect("on")
	spotlight.visible = true

func deactivate():
	super.deactivate()
	player.play_sound_effect("off")
	spotlight.visible = false

func drop():
	super.drop()
	spotlight.visible = false

func toggle():
	if flashlight_battery == 0:
		return
	super.toggle()

func attach(target: Node3D):
	super.attach(target)
	

func _process(delta: float) -> void:
	if active:
		# flashlight_battery = move_toward(flashlight_battery, 0, delta)
		Global.stat_interface.set_flashlight(flashlight_battery / flashlight_battery_limit)
	if flashlight_battery == 0 and active:
		deactivate()
	
func add_battery(duration: float):
	flashlight_battery += duration
	flashlight_battery = clampf(flashlight_battery, 0, flashlight_battery_limit)