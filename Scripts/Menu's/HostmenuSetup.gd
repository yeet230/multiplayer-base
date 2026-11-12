extends Control

@export var menuController: MainMenu
@onready var hostButton: Button = $VBoxContainer/HostButton

@onready var portInput: LineEdit = $VBoxContainer/PortHBox/PortInput
@onready var checkButton: CheckButton = $VBoxContainer/SpawnPlayerHBox/CheckButton

@onready var mapSelector: OptionButton = $VBoxContainer/HBoxContainer/Map

var mapNames: Dictionary[Enum.MAPS, String] = {
	Enum.MAPS.DEV : "Dev Level",
	Enum.MAPS.MAIN : "Main Level"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hostButton.pressed.connect(_on_host_pressed)
	
	for map in Enum.MAPS:
		var key: int = Enum.MAPS.get(map)
		var mapName: String = mapNames[key]
		mapSelector.add_item(mapName, key)

func _on_host_pressed() -> void:
	var map = mapSelector.selected as Enum.MAPS
	var port: int = int(portInput.text)
	var spawnPlayer: bool = checkButton.button_pressed
	
	var data: Dictionary[Enum.SERVER_DATA, Variant] = {
		Enum.SERVER_DATA.LEVEL : map,
		Enum.SERVER_DATA.PORT : port,
		Enum.SERVER_DATA.SPAWN_PLAYER : spawnPlayer
	}
	
	
	menuController.hide()
	MultiplayerManager.start_server.call_deferred(data)
