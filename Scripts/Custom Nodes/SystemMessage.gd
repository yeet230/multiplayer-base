class_name SystemMessage extends Control

var descText: String = "Nothing just testing"
var reasonText: String = "Testing"


@onready var reason: Label = $PanelContainer/VBoxContainer/Reason
@onready var desc: Label = $PanelContainer/VBoxContainer/Desc
@onready var closeButton: Button = $PanelContainer/VBoxContainer/Button

func _ready() -> void:
	reason.text = reasonText
	desc.text = descText
	
	closeButton.pressed.connect(_close_pressed)


func _close_pressed() -> void:
	self.queue_free()
