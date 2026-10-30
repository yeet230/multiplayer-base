extends Node

enum ERROR_CODES {
	ERR_FAILED_TO_START_SERVER,
	ERR_,
}

enum MAPS {
	DEV,
	MAIN
}

enum WEAPON_ID {
	AK_47,
	P90,
	MP5,
	SMG12 = 1000,
	DEAGLE,
	
}

var levels: Dictionary[MAPS, PackedScene]
var weaponData: Dictionary[WEAPON_ID, WeaponData]

var PlayerStartingHealth: float = 100
var mouseSens: float = 0.002

func _ready() -> void:
	levels = { 
		MAPS.DEV : preload("res://Scenes/3D/Levels/Dev/Dev.tscn"),
		MAPS.MAIN : preload("res://Scenes/3D/Levels/LevelOne.tscn"),
	}
	
	weaponData = {
		WEAPON_ID.AK_47 : preload("res://Resources/Weapon System/Primary/ak_47.tres"),
	}

func get_level(levelId : MAPS) -> PackedScene:
	var result: PackedScene = levels[levelId]
	return result


func throw_error(errCode : ERROR_CODES, text : String) -> void:
	pass

func get_weapon_data(weaponId : WEAPON_ID) -> WeaponData:
	var result: WeaponData = weaponData[weaponId]
	return result

#func get_user_current_weapon() -> Weapon:

func create_command_starter() -> String:
	var result: String = ""
	var possibleChars: Array[String] = ["-", "/", "*", "_", "+", "#", "!", "%", "c", "Siff_Cat_Meow_Meows"]
	for i in range(2):
		result += possibleChars.pick_random()
	return result
