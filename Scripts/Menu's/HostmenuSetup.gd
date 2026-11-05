extends Control

@onready var mapSelector: OptionButton = $VBoxContainer/HBoxContainer/Map

var mapNames: Dictionary[Enum.MAPS, String] = {
	Enum.MAPS.DEV : "Dev Level",
	Enum.MAPS.MAIN : "Main Level"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for map in Enum.MAPS:
		var key: int = Enum.MAPS.get(map)
		var mapName: String = mapNames[key]
		mapSelector.add_item(mapName, key)
