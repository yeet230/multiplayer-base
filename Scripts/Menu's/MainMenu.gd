class_name MainMenu extends Node

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

@onready var backButton: Button = $MenuItems/Back

@onready var displayElementsCanvasLayer: CanvasLayer = $DisplayElements
@onready var menuItemsCanvasLayer: CanvasLayer = $MenuItems


func _ready() -> void:
	menuItems = [
		mainMenu,
		clientMenu,
		hostMenu,
	]
	
	
	
	_auto_mode_set()
	_change_menu_level(mainMenu)
	


func _on_host_pressed() -> void:
	_change_menu_level(hostMenu)
	
	pass
	
	#MultiplayerManager.start_server({})

func _auto_mode_set() -> void:
	if OS.has_feature("server") or OS.has_feature("dedicated_server"):
		print("Starting Dedicated Server Automaticlly")
		var data: Dictionary = {
			Enum.SERVER_DATA.LEVEL : Enum.MAPS.DEV,
			Enum.SERVER_DATA.PORT : MultiplayerManager.SERVER_PORT,
			Enum.SERVER_DATA.SPAWN_PLAYER : false,
		}
		
		MultiplayerManager.start_server.call_deferred(data)


func _on_play_pressed() -> void:
	_change_menu_level(clientMenu)



func _on_quit_pressed() -> void:
	get_tree().quit()


func _change_menu_level(newLevel : Control) -> void:
	for menu in menuItems:
		menu.hide()
	
	newLevel.show()
	backButton.visible = true if newLevel != mainMenu else false
	
	

func _on_quick_join_pressed() -> void:
	MultiplayerManager.join_server("127.0.0.1")
	set_canvas_items_visibility(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_canvas_items_visibility(newState : bool) -> void:
	displayElementsCanvasLayer.visible = newState
	menuItemsCanvasLayer.visible = newState


func _on_back_pressed() -> void:
	_change_menu_level(mainMenu)
