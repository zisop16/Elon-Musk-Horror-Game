class_name Chainsaw
extends Item

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area3D = $Hitbox
@export var blood_effect: PackedScene
@onready var sfx_player: PolyAudioPlayer = $PolyAudioPlayer

func _ready() -> void:
	super._ready()
	interaction.y_offset = .8
	id = item_id.chainsaw
	hitbox.monitoring = false

func activate():
	super.activate()
	anim_player.play("activate")
	hitbox.monitoring = true
	sfx_player.play_sound_effect("activate")

func deactivate():
	super.deactivate()
	anim_player.pause()
	hitbox.monitoring = false
	sfx_player.play_sound_effect("deactivate")

func on_hitbox_enter(body: Node3D) -> void:
	if not (body is Kamala):
		return
	var kamala = body as Kamala


