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
		_equip_new_weapon.rpc_id(1, newWeapon)
	
	isShootPressed = false
	weaponData = Global.get_weapon_data(newWeapon)
	load_weapon_data()
	

func load_weapon_data() -> void:
	bulletDamage = weaponData.damage
	loadedCount = weaponData.ammo
	magSize = weaponData.magSize
	weaponName = weaponData.weaponName
	weaponId = weaponData.weaponID
	fireMode = weaponData.fireMode
	reloadType = weaponData.reloadType
	maxRange = weaponData.shootDistance
	reloadSpeed = weaponData.reloadSpeed
	fireRate = weaponData.fireRate
	spread = weaponData.bulletSpread
	projectilesPerShot = weaponData.projectilesPerShot

func tick() -> void:
	if isShootPressed:
		_player_trigger_released()
	elif isShootReleased:
		_player_trigger_pressed()
	elif isReloadPressed:
		_start_reload()

func _player_trigger_pressed() -> void:
	pass

func _player_trigger_released() -> void:
	pass

func _start_reload() -> void:
	if isReloading: return
	if loadedCount >= magSize: return
	
	

func perform_hitscan() -> Dictionary:
	var activeCamera: Camera3D = localPlayer.visionManager.get_camera()
	var from: Vector3 = activeCamera.global_position
	var to: Vector3 = from + (-activeCamera.global_transform.basis.z * maxRange)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to, COLLISION_MASKS)
	var spaceState: PhysicsDirectSpaceState3D = activeCamera.get_world_3d().direct_space_state
	var results: Dictionary = spaceState.intersect_ray(query)
	
	return results

func setup_timers() -> void:
	reloadTimer = Timer.new()
	fireTimer = Timer.new()
	
	add_child(fireTimer)
	add_child(reloadTimer)
	
	reloadTimer.timeout.connect(_on_reload_timeout)
	fireTimer.timeout.connect(_on_fire_timeout)
	
	reloadTimer.autostart = false
	fireTimer.autostart = false

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
			fire_single_shot()
		WEAPON_BEHAVIOR.BURST_FIRE:
			fire_burst_shot()
