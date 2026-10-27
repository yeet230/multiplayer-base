class_name InputHandler extends Node

@export var localPlayer: Player = get_parent()

var isJumpPressed: bool = false
var isSprintPressed: bool = false
var isCrouchPressed: bool = false
var isDashPressed: bool = false
var moveDir: Vector2

var toggleChat: bool = false
var isEnterPressed: bool = false
var isBackPressed: bool = false

var isShootPressed: bool = false
var isReloadPressed: bool = false
var isShootReleased: bool = false

func tick(delta : float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return

	
	if event is InputEventMouseMotion:
		pass
	elif event is InputEventMouseButton:
		pass    
	elif event is InputEventKey:
		pass
