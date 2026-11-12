class_name PlayerSpawner extends MultiplayerSpawner

## Spawns player objects upon client connect, renames them, and sets their authority to the client the belong to.

@export var player_scene : PackedScene = preload("res://Scenes/3D/Actors/Player/Player.tscn")


enum NAME_FORMAT {
	MULTIPLAYER_ID
}

## Upon spawn, the player nodes will be renamed to differentiate which client owns each player node & set their multiplayer authorities.
## Rename all spawned player nodes to the given format upon adding it to the tree
## MULTIPLAYER_ID: All player node names will be renamed to the internal multiplayer ID of the client that owns them
@export var player_name_format : NAME_FORMAT = NAME_FORMAT.MULTIPLAYER_ID

## Upon spawning a player object in, that client will have their player node's
## .find_children("*", "Camera3D") (also for Camera2D) called
## and the first camera found will have its .current property set to true.
@export var set_camera_as_current_on_spawn : bool = true

func _enter_tree():
	#$MultiplayerSpawner.add_spawnable_scene(player_scene.resource_path)
	#spawn_path = get_node(".").get_path()
	spawn_function = _custom_spawn_func

func _ready():
	if !is_multiplayer_authority(): return
	
	if multiplayer.is_server():
		if MultiplayerManager.spawn_player():
			add_player(1)
	
	
	spawn_path = self.get_path()
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	### It's possible there are already multiple peers connected by _ready()
	### In that case, the signals have not been connected yet and so they won't be triggered.
	for peer in multiplayer.get_peers():
		add_player(peer)

func _custom_spawn_func(data : Variant) -> Node:
	print("Player spawned")
	
	var player = player_scene.instantiate() as Player
	player.name = str(data.multiplayer_id)
	player.set_multiplayer_authority(data.multiplayer_id)
	player.position = Vector3.ZERO
	set_camera_current_if_necessary(player)
	return player

func set_camera_current_if_necessary(player : Node):
	if set_camera_as_current_on_spawn and multiplayer.get_unique_id() == player.name.to_int():
		var camera_3ds = player.find_children("*", "Camera3D")
		if camera_3ds.size() > 0:
			camera_3ds[0].current = true


func add_player(id = 1):
	spawn({"multiplayer_id": id})


func del_player(id):
	for player in get_children().filter(func(c): return not c is MultiplayerSpawner):
		if player.name.to_int() == id:
			remove_child(player)
			player.queue_free()
