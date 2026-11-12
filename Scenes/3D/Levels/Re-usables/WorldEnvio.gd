@tool
extends WorldEnvironment

enum WORLD_ENVIO {
	MORNING = 0,
	DAY = 1,
	NIGHT = 2,
	SPACE = 3,
	ALIEN = 4
}


var loadedWorldEnvios: Dictionary[WORLD_ENVIO, Environment] = {
	WORLD_ENVIO.MORNING : preload("uid://lmn1xhxlak3g"),
	WORLD_ENVIO.DAY : preload("uid://btx2w8nu6etc8"),
	WORLD_ENVIO.NIGHT : preload("uid://kfidut20c74r"),
	WORLD_ENVIO.SPACE : preload("uid://bmicaqfrilceo"),
	WORLD_ENVIO.ALIEN : preload("uid://diwnbi45nw36r"),
}

##Editor Only Setting
@export var skyBoxRotateActive: bool = false:
	set(value):
		if value:
			editor_rotate()


@export var activeSkyBox: WORLD_ENVIO = WORLD_ENVIO.NIGHT

func _ready() -> void:
	environment = loadedWorldEnvios[activeSkyBox]
	

func editor_rotate() -> void:
	for envio in loadedWorldEnvios:
		if loadedWorldEnvios[envio] != null:
			environment = loadedWorldEnvios[envio]
			print(envio)
			await get_tree().create_timer(10).timeout
	skyBoxRotateActive = false
