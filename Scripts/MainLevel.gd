class_name GameController extends Node

const BULLET_DECAL = preload("uid://enjxbit5eo4e")
const MAX_BULLET_DECAL_COUNT = 250

var bulletDecalsSpawned: Array 



func _ready() -> void:
	MultiplayerManager.serverSettingsConfirmed.connect(_spawn_new_level)
	multiplayer.server_disconnected.connect(_destroy_current_level)
	Global.gameController = self
	


func spawn_level(newLevel : Enum.MAPS) -> void:
	_destroy_current_level()
	_spawn_new_level(newLevel)
	print("Level Spawned")


func _destroy_current_level() -> void:
	for child in %LevelContainer.get_children():
		child.queue_free()

func _spawn_new_level(newLevel : Enum.MAPS = Enum.MAPS.DEV) -> void:
	var levelScene: PackedScene = Global.get_level(newLevel)
	%LevelContainer.add_child(levelScene.instantiate())
	

@rpc("authority", "call_remote", "reliable")
func request_bullet_decal_spawn(position : Vector3, normal : Vector3, parentPath : NodePath) -> void:
	_spawn_bullet_decal(position, normal, parentPath)


func _spawn_bullet_decal(position : Vector3, normal : Vector3, parentPath : NodePath) -> void:
	print("Spawning Decal as ", "Server" if multiplayer.is_server() else "Client")
	
	var decalInstance = Node3D
	var parent: Node = get_node(parentPath)
	
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
