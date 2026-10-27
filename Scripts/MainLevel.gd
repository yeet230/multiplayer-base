extends Node

func _ready() -> void:
	MultiplayerManager.serverSettingsConfirmed.connect(_spawn_new_level)
	multiplayer.server_disconnected.connect(_destroy_current_level)


func spawn_level(newLevel : Global.MAPS) -> void:
	_destroy_current_level()
	_spawn_new_level(newLevel)


func _destroy_current_level() -> void:
	for child in %LevelContainer.get_children():
		child.queue_free()

func _spawn_new_level(newLevel : Global.MAPS = Global.MAPS.DEV) -> void:
	var levelScene: PackedScene = Global.get_level(newLevel)
	%LevelContainer.add_child(levelScene.instantiate())
	pass
