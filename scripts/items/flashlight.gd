class_name Flashlight
extends Item

@onready var spotlight = $SpotLight3D
@onready var player: PolyAudioPlayer = $AudioPlayer
@onready var hitbox: Area3D = $Hitbox
# Seconds of duration left in battery
const flashlight_battery_limit: float = 60
var flashlight_battery := flashlight_battery_limit

func _ready() -> void:
	super._ready()
	id = item_id.flashlight
	spotlight.visible = false
	hitbox.monitoring = false

func activate():
	super.activate()
	player.play_sound_effect("on")
	spotlight.visible = true
	hitbox.monitoring = true

func deactivate():
	super.deactivate()
	player.play_sound_effect("off")
	spotlight.visible = false
	hitbox.monitoring = false

func drop():
	super.drop()
	spotlight.visible = false
	hitbox.monitoring = false
	if Global.player.get_flashlight() == null:
		Global.stat_interface.set_flashlight_visibility(false)

func toggle():
	if flashlight_battery == 0:
		return
	super.toggle()

func attach(target: Node3D):
	super.attach(target)
	Global.stat_interface.set_flashlight_visibility(true)

func _process(delta: float) -> void:
	if active:
		flashlight_battery = move_toward(flashlight_battery, 0, delta)
		Global.stat_interface.set_flashlight(flashlight_battery / flashlight_battery_limit)
	if flashlight_battery == 0 and active:
		deactivate()

func hit_kamala() -> bool:
	if not active:
		return false
	var bodies := hitbox.get_overlapping_bodies()
	for body in bodies:
		if body is Kamala:
			return true
	return false

func _physics_process(_delta: float) -> void:
	super._physics_process(_delta)
	var hit := hit_kamala()
	if hit:
		Global.kamala.receive_flashlight()

	
func add_battery(duration: float):
	flashlight_battery += duration
	flashlight_battery = clampf(flashlight_battery, 0, flashlight_battery_limit)