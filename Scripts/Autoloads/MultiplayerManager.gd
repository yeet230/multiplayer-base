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
	ACTIVE_WEAPON,
	
}

var commandStarter: String 
var serverStoredPlayerData: Dictionary[int, Dictionary]
var serverData: Dictionary[SERVER_DATA, Variant]

#@onready var gameController: Node = Global.gameController

func _ready() -> void:
	#push_warning("i am the server :0")
	multiplayer.peer_connected.connect(_server_handle_player_join)
	multiplayer.peer_disconnected.connect(_server_handle_player_leave)
	pass
	

func get_player_from_id(playerId : int) -> Player:
	for player in get_tree().get_nodes_in_group("Players"):
		if player.name == str(playerId):
			return player
	return null

func get_player_weapon(playerId : int) -> Global.WEAPON_ID:
	var result:Global.WEAPON_ID = serverStoredPlayerData[playerId][PLAYER_DATA.ACTIVE_WEAPON]
	return result

func start_server(_data : Dictionary) -> void:
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
	

func create_player_data(peerId : int) -> void:
	serverStoredPlayerData[peerId] = {
		PLAYER_DATA.HEALTH : 100,
		PLAYER_DATA.LIFE_ID : 0,
		PLAYER_DATA.ACTIVE_WEAPON : Global.WEAPON_ID.AK_47
	}


func _server_handle_player_join(peerId : int) -> void:
	if !multiplayer.is_server():
		multiplayer.peer_connected.disconnect(_server_handle_player_join)
		return
	create_player_data(peerId)
	
	

func _server_handle_player_leave(peerId : int) -> void:
	if !multiplayer.is_server():
		multiplayer.peer_disconnected.disconnect(_server_handle_player_leave)
		return
	
	serverStoredPlayerData.erase(peerId)


func _handle_player_hit(shootingPlayerId : int, hitPlayerId : int) -> void:
	var hitPlayer: Player = get_player_from_id(hitPlayerId)
	var weapon: Global.WEAPON_ID = get_player_weapon(shootingPlayerId)
	var weaponDamage: float = Global.get_weapon_damage(weapon)
	
	update_health.rpc_id(hitPlayerId, 20)

@rpc("any_peer", "call_remote", "reliable")
func server_handle_hit() -> void:
	var senderId: int = multiplayer.get_remote_sender_id()
	var player: Player = get_player_from_id(senderId)
	#var playerWeapon: Global.WEAPON_ID = get_player_weapon(senderId)
	
	var results: Dictionary = player.weaponManager.perform_hitscan()
	
	if results.is_empty(): return
	
	var collider: Node3D = results.get("collider")
	
	if collider is Player:
		var hitPlayerId: int = int(collider.name)
		_handle_player_hit(senderId, hitPlayerId)
	else:
		var hitPosition: Vector3 = results.get("position")
		var hitNormal: Vector3 = results.get("normal")
		var hitObjectPath: NodePath = get_path_to(collider)
		
		Global.gameController.request_bullet_decal_spawn.rpc(hitPosition, hitNormal, hitObjectPath)
	
	#print("Server Weapon HitScan Results: ", results)

@rpc("any_peer", "call_remote", "reliable")

func _update_player_health(playerId : int) -> void:
	pass


##Please do not remove this 🥺🥺
@rpc("authority", "call_remote", "reliable")
func update_health(newHealth : float) -> void:
	Global.clientPlayer.playerHealthManager.update_health(newHealth)
