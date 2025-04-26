class_name StatInterface
extends Control

@onready var stamina: ProgressBar = %StaminaBar
@onready var flashlight: ProgressBar = %FlashlightBar

func _ready() -> void:
	Global.stat_interface = self

func set_stamina(value: float):
	stamina.value = value * 100

func set_flashlight(value: float):
	flashlight.value = value * 100