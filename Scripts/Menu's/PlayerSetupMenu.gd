extends Control


@onready var primary: OptionButton = $Options/Primary
@onready var secondary: OptionButton = $Options/Secondary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for p in Global.primaryWeapons:
		primary.add_item(Global.WEAPON_ID.find_key(p), p)
	
	var itemCount = primary.item_count
