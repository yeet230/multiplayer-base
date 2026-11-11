extends Node

@warning_ignore_start("unused_signal")

signal serverSettingsConfirmed(level : Enum.MAPS)
signal chatRecieved(chat : String)
signal updateSharedPlayerData(data : Dictionary)

const SERVER_PORT: int = 39286

var serverDamageMulti: float = 1.0
var commandStarter: String 
var serverStoredPlayerData: Dictionary[int, Dictionary]
var serverData: Dictionary[Enum.SERVER_DATA, Variant]

func _ready() -> void:
	multiplayer.peer_connected.connect(_server_handle_player_join)
	multiplayer.peer_disconnected.connect(_server_handle_player_leave)
	pass
	

func get_player_from_id(playerId : int) -> Player:
	for player in get_tree().get_nodes_in_group("Players"):
		if player.name == str(playerId):
			return player
	return null

func get_player_weapon(playerId : int) -> Enum.WEAPON_ID:
	var result: Enum.WEAPON_ID = serverStoredPlayerData[playerId][Enum.PLAYER_DATA.ACTIVE_WEAPON]
	return result

func get_player_health(playerId : int) -> float:
	var result: float = serverStoredPlayerData[playerId][Enum.PLAYER_DATA.HEALTH]
	return result

func start_server(data : Dictionary) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_server(SERVER_PORT)
	var level: Enum.MAPS = data[Enum.SERVER_DATA.LEVEL]
	
	print("Level is ", level)
	
	serverData[Enum.SERVER_DATA.LEVEL] = level
	
	if err != OK:
		var errCode: Enum.ERROR_CODES = Enum.ERROR_CODES.ERR_FAILED_TO_START_SERVER
		Global.throw_error(errCode, "%s" % err)
		return
	
	multiplayer.multiplayer_peer = peer
	commandStarter = Global.create_command_starter()
	serverSettingsConfirmed.emit(level)
	
	print("Server started on port ", SERVER_PORT)
	print("Command starter: ", commandStarter)
	push_warning("I am Server!!")


func join_server(ip : String, port : int = SERVER_PORT) -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var err: Error = peer.create_client(ip, port)
	
	if err != OK:
		push_error("Failed to connect: %s" % err)
		return
	
	multiplayer.multiplayer_peer = peer
	

func create_player_data(peerId : int) -> void:
	serverStoredPlayerData[peerId] = {
		Enum.PLAYER_DATA.HEALTH : 100,
		Enum.PLAYER_DATA.LIFE_ID : 0,
		Enum.PLAYER_DATA.ACTIVE_WEAPON : Enum.WEAPON_ID.AK_47
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

func set_player_server_data(playerId : int, newValue : Variant, key : Enum.PLAYER_DATA) -> void:
	serverStoredPlayerData[playerId][key] = newValue

func _handle_player_hit(shootingPlayerId : int, hitPlayerId : int) -> void:
	var weapon: Enum.WEAPON_ID = get_player_weapon(shootingPlayerId)
	var weaponDamage: float = WeaponData.get_weapon_damage(weapon)
	var hitPlayerCurHealth: float = get_player_health(hitPlayerId)
	var hitPlayerNewHealth: float = hitPlayerCurHealth - (weaponDamage * serverDamageMulti)
	
	set_player_server_data(hitPlayerId, hitPlayerNewHealth, Enum.PLAYER_DATA.HEALTH)
	update_health.rpc_id(hitPlayerId, hitPlayerNewHealth)

@rpc("any_peer", "call_remote", "unreliable")
func player_request_weapon_change(newWeapon : Enum.WEAPON_ID) -> void:
	if !Enum.WEAPON_ID.find_key(newWeapon): print("code fails here line 102"); return
	if !Global.weaponData.has(newWeapon): print("code fails here line 103"); return
	if serverData[Enum.SERVER_DATA.LEVEL] != Enum.MAPS.DEV: print("code fails here line 104"); return
	
	var playerId: int = multiplayer.get_remote_sender_id()
	print(" giving new weapon to player: ", playerId)
	
	

@rpc("any_peer", "call_remote", "reliable")
func server_handle_hit() -> void:
	var senderId: int = multiplayer.get_remote_sender_id()
	var player: Player = get_player_from_id(senderId)
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
func player_reload() -> void:
	var playerId: int = multiplayer.get_remote_sender_id()
	var weaponId: Enum.WEAPON_ID = get_player_weapon(playerId)
	var reloadTime: float = WeaponData.get_weapon_reload_time(weaponId)
	
	
	await get_tree().create_timer(reloadTime - 0.5).timeout


##Please do not remove this
##Otherwise the server will crash 🥺🥺🥺
@rpc("authority", "call_remote", "reliable")
func update_health(newHealth : float) -> void:
	Global.clientPlayer.playerHealthManager.update_health(newHealth)
