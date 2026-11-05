extends Node

const primaryWeapons: Array[Enum.WEAPON_ID] = [
	Enum.WEAPON_ID.AK_47,
	Enum.WEAPON_ID.P90,
	Enum.WEAPON_ID.MP5,
	Enum.WEAPON_ID.MK_12,
	Enum.WEAPON_ID.AR_15,
]

const secondaryWeapons: Array[Enum.WEAPON_ID] = [
	Enum.WEAPON_ID.DEAGLE ,
	Enum.WEAPON_ID.SMG12 ,
	Enum.WEAPON_ID.M191 ,
	#Enum.WEAPON_ID. ,
]

var levels: Dictionary[Enum.MAPS, PackedScene]
var weaponData: Dictionary[Enum.WEAPON_ID, WeaponData]

var PlayerStartingHealth: float = 100
var mouseSens: float = 0.002

var gameController: GameController 
var commandHandler: CommandHandler
var clientPlayer: Player

func _ready() -> void:
	levels = { 
		Enum.MAPS.DEV : preload("res://Scenes/3D/Levels/Dev/Dev.tscn"),
		Enum.MAPS.MAIN : preload("res://Scenes/3D/Levels/LevelOne.tscn"),
	}
	
	weaponData = {
		Enum.WEAPON_ID.AK_47 : preload("res://Resources/Weapon System/Primary/ak_47.tres"),
	}
	


func get_level(levelId : Enum.MAPS) -> PackedScene:
	var result: PackedScene = levels[levelId]
	return result



func throw_error(errCode : Enum.ERROR_CODES, text : String = "") -> void:
	var errorKey: String = str(Enum.ERROR_CODES.find_key(errCode))
	var formattedString: String = str(errorKey, " : ", errCode, "\n", text )
	assert(false, formattedString)


#func get_user_current_weapon() -> Weapon:

func create_command_starter() -> String:
	var result: String = ""
	var possibleChars: Array[String] = ["-", "/", "*", "_", "+", "#", "!", "%", "c", "Siff_Cat_Meow_Meows"]
	for i in range(2):
		result += possibleChars.pick_random()
	return result
