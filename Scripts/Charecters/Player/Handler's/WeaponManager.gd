class_name WeaponManager extends Node

const COLLISION_MASKS: int = 1 | 2

enum WEAPON_BEHAVIOR {
	SEMI_FIRE,
	BURST_FIRE,
	AUTO_FIRE,
	SHOTGUN_FIRE,
	CHARGED_SHOT,
	MELEE
}

enum RELOAD_TYPE {
	MAG,
	SLUG,
	NONE
}

@export var mainCamera: Camera3D
@export var localPlayer: Player

var weaponData: WeaponData

var fireMode: WEAPON_BEHAVIOR
var reloadType: RELOAD_TYPE
var weaponId: Global.WEAPON_ID
var weaponName: String

var maxRange: float = 100.0
var magSize: int = 0
var loadedCount: int = 0
var projectilesPerShot: int = 1

var fireRate: float = 0.1
var bulletDamage: float = 10.0
var reloadSpeed: float = 1.0
var spread: float = 0.0

var canFire: bool = true
var isReloading: bool = false
var isTriggerHeld: bool = false
var burstShotsRemaining: int = 0

var isReloadPressed: bool = false
var isShootPressed: bool = false
var isShootReleased: bool = false

var reloadTimer: Timer
var fireTimer: Timer

func _equip_new_weapon(newWeapon : Global.WEAPON_ID) -> void:
	if !multiplayer.is_server():
		server_update_equipped_weapon.rpc_id(1, newWeapon)
	
	isShootPressed = false
	weaponData = Global.get_weapon_data(newWeapon)
	load_weapon_data()
	
	if multiplayer.is_server():
		print(Global.WEAPON_ID.find_key(newWeapon))
	

@rpc("any_peer", "call_remote", "reliable")
func server_update_equipped_weapon(newWeapon : Global.WEAPON_ID) -> void:
	_equip_new_weapon(newWeapon)

func load_weapon_data() -> void:
	bulletDamage = weaponData.damage
	loadedCount = weaponData.loadedAmmo
	magSize = weaponData.magSize
	weaponName = weaponData.weaponName
	weaponId = weaponData.weaponId
	fireMode = weaponData.fireMode
	reloadType = weaponData.reloadType
	maxRange = weaponData.shootDist
	reloadSpeed = weaponData.reloadSpeed
	fireRate = weaponData.fireRate
	spread = weaponData.bulletSpread
	projectilesPerShot = weaponData.projectilePerShot

func tick() -> void:
	if isShootPressed:
		_player_trigger_pressed()
		print("Shooting")
	elif isShootReleased:
		_player_trigger_released()
		print("Not Shooting")
	elif isReloadPressed:
		_start_reload()
		#print("Reloading")

func _player_trigger_pressed() -> void:
	isTriggerHeld = true
	
	# Interrupt shell-by-shell reload if we have at least one shell loaded.
	if isReloading and loadedCount > 0:
		cancel_reload()
	
	try_fire()

func _player_trigger_released() -> void:
	isTriggerHeld = false
	print("i'm here :0")

func _start_reload() -> void:
	if isReloading: return
	if loadedCount >= magSize: return

func try_fire() -> void:
	if !canFire: return
	if isReloading: return
	if loadedCount <= 0: return
	
	match fireMode:
		WEAPON_BEHAVIOR.SEMI_FIRE:
			fire_single_shot()
		WEAPON_BEHAVIOR.AUTO_FIRE:
			fire_single_shot()
		WEAPON_BEHAVIOR.BURST_FIRE:
			burstShotsRemaining = projectilesPerShot
			fire_burst_shot()
		WEAPON_BEHAVIOR.SHOTGUN_FIRE:
			fire_shotgun_shot()

func perform_hitscan() -> Dictionary:
	var activeCamera: Camera3D = localPlayer.visionManager.get_camera()
	var from: Vector3 = activeCamera.global_position
	var to: Vector3 = from + (-activeCamera.global_transform.basis.z * maxRange)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to, COLLISION_MASKS)
	var spaceState: PhysicsDirectSpaceState3D = activeCamera.get_world_3d().direct_space_state
	var results: Dictionary = spaceState.intersect_ray(query)
	
	return results

func _handle_hit_check() -> void:
	MultiplayerManager.server_handle_hit.rpc_id(1)
	
	var result: Dictionary = perform_hitscan()
	
	if result.is_empty(): return
	
	var collider: Node3D = result.get("collider")
	
	

func setup_timers() -> void:
	reloadTimer = Timer.new()
	fireTimer = Timer.new()
	
	add_child(fireTimer)
	add_child(reloadTimer)
	
	reloadTimer.timeout.connect(_on_reload_timeout)
	fireTimer.timeout.connect(_on_fire_timeout)
	
	reloadTimer.autostart = false
	reloadTimer.one_shot = true
	fireTimer.autostart = false
	fireTimer.one_shot = true
	

func _ready() -> void:
	setup_timers()

func cancel_reload() -> void:
	isReloading = false
	reloadTimer.stop()

func begin_reload_timer() -> void:
	if isReloading or loadedCount >= magSize: return
	
	isReloading = true
	reloadTimer.start(reloadSpeed)

func _on_reload_timeout() -> void:
	pass

func begin_fire_cooldown() -> void:
	canFire = false
	fireTimer.start(fireRate)

func _on_fire_timeout() -> void:
	canFire = true
	
	if loadedCount <= 0: return
	
	match fireMode:
		WEAPON_BEHAVIOR.AUTO_FIRE:
			if isTriggerHeld and !isReloading:
				fire_single_shot()
				print("Fire called from here")
			print(isTriggerHeld, "  :  ", !isReloading)
	
		WEAPON_BEHAVIOR.BURST_FIRE:
			fire_burst_shot()

func fire_single_shot() -> void:
	loadedCount -= 1
	_handle_hit_check()
	begin_fire_cooldown()

func fire_burst_shot() -> void:
	if burstShotsRemaining <= 0: return
	
	loadedCount -= 1
	burstShotsRemaining -= 1
	
	_handle_hit_check()
	begin_fire_cooldown()

func fire_shotgun_shot() -> void:
	loadedCount -= 1
	
	for i in range(projectilesPerShot):
		_handle_hit_check()
	
	begin_fire_cooldown()
