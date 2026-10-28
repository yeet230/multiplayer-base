extends Node

@warning_ignore_start("unused_signal")

signal serverSettingsConfirmed()
signal chatRecieved(chat : String)
signal updateSharedPlayerData(data : Dictionary)

const SERVER_PORT: int = 39286

enum SERVER_DATA {
	LEVEL,
	PORT,
	SPAWN_PLAYER,
	USED_USERNAMES,
	
	
}

enum PLAYER_DATA {
	HEALTH,
	KILLS,
	DEATHS,
	SCORE,
	AMMO,
	USERNAME,
	LIFE_ID,
	PRIMARY_WEAPON,
	SECONDARY_WEAPON,
	GADGET,
	ABILITY,
	
}

var commandStarter: String 
var serverStoredPlayerData: Dictionary[int, Dictionary]
var serverData: Dictionary[SERVER_DATA, Variant]

@onready var gameController: Node = get_node("/root/Game")

func _ready() -> void:
	#push_warning("i am the server :0")
	multiplayer.peer_connected.connect(_server_handle_player_join)
	multiplayer.peer_disconnected.connect(_server_handle_player_leave)
	pass
	

func start_server(data : Dictionary) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_server(SERVER_PORT)
	
	if err != OK:
		var errCode: Global.ERROR_CODES = Global.ERROR_CODES.ERR_FAILED_TO_START_SERVER
		Global.throw_error(errCode, "%s" % err)
		#push_error("Failed to create server: %s" % err)
		return
	
	multiplayer.multiplayer_peer = peer
	commandStarter = Global.create_command_starter()
	serverSettingsConfirmed.emit()
	
	print("Server started on port ", SERVER_PORT)
	print("Command starter: ", commandStarter)
	push_warning("I am Server!!")


func join_server(ip : String) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(ip, SERVER_PORT)
	
	if err != OK:
		push_error("Failed to connect: %s" % err)
		return
	
	multiplayer.multiplayer_peer = peer


func _server_handle_player_join(peerId : int) -> void:
	if !multiplayer.is_server():
		multiplayer.peer_connected.disconnect(_server_handle_player_join)
		return
	
	
	

func _server_handle_player_leave(peerId : int) -> void:
	if !multiplayer.is_server():
		multiplayer.peer_disconnected.disconnect(_server_handle_player_join)
		return
	
	serverStoredPlayerData.erase(peerId)
