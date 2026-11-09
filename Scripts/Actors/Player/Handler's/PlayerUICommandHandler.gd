extends Panel

@onready var consoleOutput: RichTextLabel = $ConsoleOutput
@onready var consoleInput: LineEdit = $ConsoleInput

var previousInputs : Array[String] = []
var index : int = -1


func _ready() -> void:
	visible = false
	Global.commandHandler.UIHandler = self
	

func toggle() -> void:
	visible = !visible
	consoleInput.grab_focus(!visible)
	consoleInput.clear()

func _update_log() -> void:
	pass

func log_text(text: String, colour : Color) -> void:
	consoleOutput.push_color(colour)
	consoleOutput.append_text(text + "\n")

func _on_console_input_text_submitted(userCommand: String) -> void:
	consoleInput.clear()
	consoleInput.grab_focus()
	previousInputs.push_front(userCommand)
	index = -1
	
	if userCommand.strip_edges() == "":
		return
	
	log_text("> " + userCommand, Color.YELLOW)
	
	var parts : PackedStringArray = userCommand.split(" ")
	var command : String = parts[0].to_lower()
	
	if !Global.commandHandler.has_command(command):
		log_text("Unknown command: " + command, Color.RED)
		return
	
	if parts.size() == 1:
		if Global.commandHandler.get_command_arg_count(command) != parts.size() - 1:
			log_text("Incorrect number of arguments for the command: " + command, Color.RED)
			return
		else:
			Global.commandHandler.call_command(command, [""])
	else:
		var args : PackedStringArray = parts.slice(1)
		Global.commandHandler.call_command(command, args)

func cycle_up_command() -> void:
	if previousInputs.is_empty(): return
	index += 1
	index = clampi(index, 0, previousInputs.size() - 1)
	consoleInput.text = previousInputs[index]

func cycle_down_command() -> void:
	index -= 1
	index = clampi(index, -1, previousInputs.size() - 1)
	if index == -1:
		consoleInput.clear()
	else:
		consoleInput.text = previousInputs[index]
