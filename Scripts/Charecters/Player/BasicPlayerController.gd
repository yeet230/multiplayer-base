class_name Player extends CharacterBase 

@onready var inputHandler: PlayerInputHandler = $InputHandler
@onready var movementController: PlayerMovementController = $PlayerMovementController
@onready var visionManager: VisionManager = $VisionManager
@onready var weaponManager: WeaponManager = $WeaponManager




func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	inputHandler.tick()
	movementController.tick(delta)
