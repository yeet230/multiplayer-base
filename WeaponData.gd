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
@export var weaponId: Global.WEAPON_ID
@export var fireMode: WeaponManager.WEAPON_BEHAVIOR
@export var reloadType: WeaponManager.RELOAD_TYPE

@export_subgroup("Other")
@export var weaponName: String

@export_group("Weapon Mesh Settings")
@export var mesh: Mesh
@export var meshPosition: Vector3
@export var meshRotation: Vector3
