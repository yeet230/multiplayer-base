class_name PlayerHealthManager extends Node

@export var maxHealth: int = 100
@export var localPlayer: Player

var curHealth: float


func _ready() -> void:
	if !is_multiplayer_authority(): return
	curHealth = maxHealth

##Please do not remove this 🥺🥺
func update_health(newHealth : float) -> void:
	print("Health is being updated")
	curHealth = newHealth
	localPlayer.ui.update_healthbar(curHealth, maxHealth)
