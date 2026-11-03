class_name PlayerUi extends Control

var localPlayer: Player

@onready var positionLabel: Label = $DebugUI/RightVBoxContainer/Position
@onready var idLabel: Label = $DebugUI/LeftVBoxContainer/Id
@onready var ammoLabel: Label = $DebugUI/RightVBoxContainer/Ammo

@onready var option_button: OptionButton = $OptionButton

@onready var healthBar: ColorRect = $DebugUI/HealthBar

func tick() -> void:
	update_hud()
	for item in Global.WEAPON_ID.keys():
		var value: int = Global.WEAPON_ID[item]
		option_button.add_item(item, value)

func update_hud() -> void:
	update_ammo()

func update_ammo() -> void:
	ammoLabel.text = str(localPlayer.weaponManager.loadedCount)

func update_healthbar(newHealth : float, maxHealth) -> void:
	var healthPercentage: float = (13.0 / maxHealth)
	print("_update_health", healthPercentage)
	healthBar.material.set_shader_parameter("value", healthPercentage)
	
