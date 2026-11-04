class_name WeaponData extends Resource

@export_group("Weapon Behavior Settings")
@export_subgroup("Float's")
@export var damage: float
@export var shootDist: float
@export var bulletSpread: float
@export var reloadSpeed: float
@export var fireRate: float

@export_subgroup("Integer's")
@export var projectilePerShot: int
@export var magSize: int
@export var loadedAmmo: int

@export_subgroup("Enum's")
@export var weaponGlobalId: Global.WEAPON_ID
@export var fireMode: WeaponManager.WEAPON_BEHAVIOR
@export var reloadType: WeaponManager.RELOAD_TYPE

@export_subgroup("Other")
@export var weaponName: String

var weaponDropOffDamage: float 
##Default is 0%. this means there is no damage reduction occuring
@export_range(0, 100, 1, "suffix:%") var weaponDamageDropOffPercentage: float = 0.0:
	get:
		return weaponDropOffDamage * 100
	set(value):
		weaponDropOffDamage = value / 100

@export_group("Weapon Mesh Settings")
@export var mesh: Mesh
@export var meshPosition: Vector3
@export var meshRotation: Vector3


static func get_weapon_damage(weaponId : Global.WEAPON_ID) -> float:
	var result: float = Global.weaponData[weaponId].damage
	return result

static func get_weapon_data(weaponId : Global.WEAPON_ID) -> WeaponData:
	var result: WeaponData = Global.weaponData[weaponId]
	return result

static func get_weapon_reload_time(weaponId : Global.WEAPON_ID) -> float:
	var result: float = Global.weaponData[weaponId].reloadSpeed
	return result
