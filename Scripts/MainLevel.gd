extends Node

const BULLET_DECAL = preload("uid://enjxbit5eo4e")
const MAX_BULLET_DECAL_COUNT = 250

var bulletDecalsSpawned: Array 



func _ready() -> void:
	MultiplayerManager.serverSettingsConfirmed.connect(_spawn_new_level)
	multiplayer.server_disconnected.connect(_destroy_current_level)
	Global.root = self


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

@rpc("authority", "call_remote", "reliable")
func spawn_bullet_decal(position : Vector3, normal : Vector3, parentPath : NodePath) -> void:
	var decalInstance = Node3D
	var parent: Node3D = get_node(parentPath)
	
	if len(bulletDecalsSpawned) >= MAX_BULLET_DECAL_COUNT and is_instance_valid(bulletDecalsSpawned[0]):
		decalInstance = bulletDecalsSpawned.pop_front()
		bulletDecalsSpawned.push_back(decalInstance)
		decalInstance.reparent(parent)
	else:
		decalInstance = BULLET_DECAL.instantiate()
		parent.add_child(decalInstance)
		bulletDecalsSpawned.push_back(decalInstance)
		
	if !is_instance_valid(bulletDecalsSpawned[0]):
		bulletDecalsSpawned.pop_front()
	
	decalInstance.global_transform = Transform3D(Quaternion(Vector3.UP, normal), position)
	decalInstance.get_node("GPUParticles3D").emitting = true
