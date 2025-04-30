class_name StatInterface
extends Control

@onready var stamina: ProgressBar = %StaminaBar
@onready var flashlight: ProgressBar = %FlashlightBar
@onready var flashlight_panel: Panel = %FlashlightPanel
var blood_material: ShaderMaterial

func _ready() -> void:
	Global.stat_interface = self
	var blood_tex: TextureRect = %BloodTex
	blood_material = blood_tex.material

func set_stamina(value: float):
	stamina.value = value * 100

func set_flashlight(value: float):
	flashlight.value = value * 100

func set_health(value: float):
	blood_material.set_shader_parameter("bloodiness", 1. - value)

func set_flashlight_visibility(flag: bool):
	flashlight_panel.visible = flag