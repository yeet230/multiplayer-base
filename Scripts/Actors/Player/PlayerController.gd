class_name Player extends CharacterBase 

var ui: PlayerUi

@onready var inputHandler: PlayerInputHandler = $InputHandler
@onready var movementController: PlayerMovementController = $PlayerMovementController
@onready var visionManager: VisionManager = $VisionManager
@onready var weaponManager: WeaponManager = $WeaponManager
@onready var playerHealthManager: PlayerHealthManager = $PlayerHealthManager


func _ready() -> void:
	if !is_multiplayer_authority(): return
	Global.clientPlayer = self
	_instantiate_UI()
	
	weaponManager._equip_new_weapon(Enum.WEAPON_ID.AK_47)

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	inputHandler.tick()
	movementController.tick(delta)
	weaponManager.tick()
	
	ui.tick()

func _instantiate_UI() -> void:
	var uiScene = preload("res://Scenes/2D/Player/PlayerUi.tscn")
	ui = uiScene.instantiate()
	ui.set_multiplayer_authority(get_multiplayer_authority())
	ui.localPlayer = self
	$PlayerUI.add_child(ui)
