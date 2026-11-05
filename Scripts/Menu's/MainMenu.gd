class_name MainMenu extends Control

const SYSTEM_MESSAGE_PREFAB = preload("res://SystemMessage.tscn")

enum MENU_LEVEL {
	MAIN,
	SETTINGS,
	HOST,
	PLAY
}

var menuLevel: MENU_LEVEL
var menuItems

@onready var mainMenu: Control = %MainMenu
@onready var clientMenu: Control = %ClientMenu
@onready var hostMenu: Control = %HostMenu


@onready var displayElementsCanvasLayer: CanvasLayer = $"../../DisplayElements"
@onready var menuItemsCanvasLayer: CanvasLayer = $"../../MenuItems"



@onready var playButton: Button = $MainMenu/MainMenuVBox/Play
@onready var hostButton: Button = $MainMenu/MainMenuVBox/Host
@onready var gameSettingsButton: Button = $MainMenu/MainMenuVBox/GameSettings
@onready var quickJoinButton: Button = $MainMenu/MainMenuVBox/QuickJoin
@onready var quitButton: Button = $MainMenu/MainMenuVBox/Quit
@onready var backButton: Button = $Back



func _ready() -> void:
	menuItems = [
		mainMenu,
		clientMenu,
		hostMenu,
	]
	
	_auto_mode_set()
	_change_menu_level(mainMenu)
	
	multiplayer.server_disconnected.connect(_server_disconnected)
	multiplayer.connection_failed.connect(_connection_failed)
	
	playButton.pressed.connect(_on_play_pressed)
	hostButton.pressed.connect(_on_host_pressed)
	#gameSettingsButton.pressed.connect()
	quickJoinButton.pressed.connect(_on_quick_join_pressed)
	quitButton.pressed.connect(_on_quit_pressed)
	backButton.pressed.connect(_on_back_pressed)
	


func _spawn_system_message(reason : String, desc : String) -> void:
	var instance = SYSTEM_MESSAGE_PREFAB.instantiate() as SystemMessage
	
	instance.descText = desc
	instance.reasonText = reason
	instance.set_anchors_preset(Control.PRESET_CENTER)
	add_child(instance)



func _auto_mode_set() -> void:
	if OS.has_feature("server") or OS.has_feature("dedicated_server"):
		print("Starting Dedicated Server Automaticlly")
		var data: Dictionary = {
			Enum.SERVER_DATA.LEVEL : Enum.MAPS.DEV,
			Enum.SERVER_DATA.PORT : MultiplayerManager.SERVER_PORT,
			Enum.SERVER_DATA.SPAWN_PLAYER : false,
		}
		
		MultiplayerManager.start_server.call_deferred(data)


func _change_menu_level(newLevel : Control) -> void:
	for menu in menuItems:
		menu.hide()
	
	newLevel.show()
	backButton.visible = true if newLevel != mainMenu else false


func set_canvas_items_visibility(newState : bool) -> void:
	displayElementsCanvasLayer.visible = newState
	menuItemsCanvasLayer.visible = newState


#region Signal Functions

func _server_disconnected() -> void:
	var reason: String = "N/A"
	var desc: String = ":0"
	
	print("disconnected")
	
	_spawn_system_message(reason, desc)
	set_canvas_items_visibility(true)

func _connection_failed() -> void:
	var reason: String = "Unable to reach Server"
	var desc: String = "The game instance is unable to reach the server, please check your network connection and try again"
	
	print("Failed Connection")
	
	
	_spawn_system_message(reason, desc)
	set_canvas_items_visibility(true)







func _on_play_pressed() -> void:
	_change_menu_level(clientMenu)
	var reason: String = "N/A"
	var desc: String = ":0"
	desc = "The game instance is unable to reach the server, please check your network connection then try again"
	
	
	print("disconnected")
	
	_spawn_system_message(reason, desc)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	_change_menu_level(mainMenu)

func _on_host_pressed() -> void:
	_change_menu_level(hostMenu)

func _on_quick_join_pressed() -> void:
	MultiplayerManager.join_server("127.0.0.1")
	set_canvas_items_visibility(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#endregion
