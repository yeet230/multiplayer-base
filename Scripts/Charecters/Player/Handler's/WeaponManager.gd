class_name WeaponManager extends Node

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

func setup_timers() -> void:
	reloadTimer = Timer.new()
	fireTimer = Timer.new()
	
	add_child(fireTimer)
	add_child(reloadTimer)
	
	reloadTimer.timeout.connect(_on_reload_timeout)
	fireTimer.timeout.connect(_on_fire_timeout)

func _ready() -> void:
	setup_timers()


func _on_reload_timeout() -> void:
	pass

func _on_fire_timeout() -> void:
	pass
