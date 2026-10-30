class_name PlayerUi extends Control

var localPlayer: Player

@onready var positionLabel: Label = $DebugUI/RightVBoxContainer/Position
@onready var idLabel: Label = $DebugUI/LeftVBoxContainer/Id
@onready var ammoLabel: Label = $DebugUI/RightVBoxContainer/Ammo

func tick() -> void:
	update_hud()

func update_hud() -> void:
	update_ammo()

func update_ammo() -> void:
	ammoLabel.text = str(localPlayer.weaponManager.loadedCount)
