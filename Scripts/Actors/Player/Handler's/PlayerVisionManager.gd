class_name VisionManager extends Node3D

const CROUCH_TRANSLATE: float = .7 ##How much to change the players height by
const HEADBOB_MOVE_AMOUNT: float = .06
const HEADBOB_FREQUENCY: float = 2.4

@export var localPlayer: Player
@export var cameraList: Array[Camera3D]
@export var playerHead: Node3D

var sensitivity = Global.mouseSens
var activeCameraIndex: int = 0
var headbobTime: float = 0.0


func _tick(delta : float) -> void:
	if !is_multiplayer_authority(): return
	
	if localPlayer.is_on_floor():
		_handle_headbob(delta)

func look_around(relative : Vector2) -> void:
	var activeCamera = get_camera()

	localPlayer.rotate_y(-relative.x * sensitivity)
	activeCamera.rotate_x(-relative.y * sensitivity)
	activeCamera.rotation_degrees.x = clampf(activeCamera.rotation_degrees.x, -90, 90)

func _handle_headbob(delta : float) -> void:
	var activeCamera = get_camera()
	
	headbobTime += delta * localPlayer.velocity.length()
	activeCamera.transform.origin = Vector3(
		cos(headbobTime * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbobTime * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
		0
	)

func apply_recoil(_amount : float) -> void:
	pass

func get_camera() -> Camera3D:
	var result = cameraList[activeCameraIndex]
	return result

func get_camera_position() -> Vector3:
	var result = get_camera().global_position
	return result
