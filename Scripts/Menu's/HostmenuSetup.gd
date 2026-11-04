extends Control

@onready var mapSelector: OptionButton = $VBoxContainer/Map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for map in Enum.MAPS:
		mapSelector.add_item(Enum.MAPS.find_key(map), map)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
