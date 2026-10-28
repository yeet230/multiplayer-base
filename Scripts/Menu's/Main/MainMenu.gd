extends Node

@onready var mainMenu: VBoxContainer = $MenuItems/Menu/MainMenu
@onready var clientMenu: Control = $MenuItems/Menu/ClientMenu
@onready var displayElementsCanvasLayer: CanvasLayer = $DisplayElements
@onready var menuItemsCanvasLayer: CanvasLayer = $MenuItems

func _ready() -> void:
	_auto_mode_set()


func _on_host_pressed() -> void:
	MultiplayerManager.start_server({})

func _auto_mode_set() -> void:
	if OS.has_feature("dedicated_server"):
		print("Starting Dedicated Server Automaticlly")
		push_warning("I am the server")
		var data: Dictionary = {
			MultiplayerManager.SERVER_DATA.LEVEL : Global.MAPS.DEV,
			MultiplayerManager.SERVER_DATA.PORT : MultiplayerManager.SERVER_PORT,
		}
		
		MultiplayerManager.start_server.call_deferred(data)


func _on_play_pressed() -> void:
	clientMenu.show()
	mainMenu.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_quick_join_pressed() -> void:
	MultiplayerManager.join_server("127.0.0.1")
	set_canvas_items_visibility(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_canvas_items_visibility(newState : bool) -> void:
	displayElementsCanvasLayer.visible = newState
	menuItemsCanvasLayer.visible = newState
