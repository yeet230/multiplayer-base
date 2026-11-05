extends Control

@onready var ipInput: LineEdit = $MainVboxContainer/VBoxContainer/IpInput
@onready var portInput: LineEdit = $MainVboxContainer/VBoxContainer/PortInput

func _on_join_pressed() -> void:
	var port: int = int(portInput.text)
	var ip: String = ipInput.text
	var dots: int = 3
	
	#for i in range(4):
		#if ip.find(".", 0):
			#dots += 1
	
	if dots != 3:
		ipInput.clear()
		return
	
	MultiplayerManager.join_server.call_deferred(ip, port)
	
