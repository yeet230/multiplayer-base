class_name CommandHandler extends Node


var clientCommands: Dictionary[String, Callable] = {}
var serverCommands: Dictionary[String, Callable]
var cmdAliases: PackedStringArray = []
var UIHandler: Panel


func _ready() -> void:
	Global.commandHandler = self
	
	register_command(["help"], _command_help)
	register_command(["tp", "teleport"], _command_player_teleport)
	register_command(["freecam", "noclip"], _command_player_freecam)
	#register_command(["give"], _command_give_player_weapon)
	#register_command(["setHealth"], _command_set_player_health)
	
	

func log_text(text: String, colour : Color) -> void:
	UIHandler.log_text(text, colour)

#
func register_command(command_name: PackedStringArray, ClientSideCallable: Callable, serverSideCallable : Callable = Callable()) -> void:
	for i in range(command_name.size()):
		clientCommands[command_name[i]] = ClientSideCallable
		
		if serverSideCallable.is_valid():
			serverCommands[command_name[i]] = serverSideCallable
		
	cmdAliases.push_back(str(command_name))

func has_command(command : String) -> bool:
	var result: bool = clientCommands.has(command)
	return result

func get_command_arg_count(command : String) -> int:
	var result: int = clientCommands[command].get_argument_count()
	return result

func does_command_have_args(command : String) -> bool:
	var argCount: int = clientCommands[command].get_argument_count()
	var result = true if argCount >= 1 else false
	return result


func call_command(command : String, args : PackedStringArray) -> void:
	if does_command_have_args(command):
		clientCommands[command].call(args)
	else:
		clientCommands[command].call()


#region Commands

func _command_help() -> void:
	if multiplayer.is_server():
		return
	else:
		pass
		log_text("Available commands: \n(Aliases are listed on the same row)", Color.CYAN)
		for cmd in cmdAliases:
			log_text("- " + cmd, Color.CYAN)
#
#
func _command_player_teleport(_args : PackedStringArray) -> void:
	pass
	
	#if args.size() != 3:
		#log_text("Expected 3 integer arguments for the command: tp", Color.RED)
		#return
	#
	#var new_pos : Vector3 = Vector3(float(args[0]), float(args[1]), float(args[2]))
	#
	#for i in 3:
		#if args[i].contains("+") or args[i].contains("-"):
			#new_pos[i] = player.global_position[i] + float(args[i])
	#
	#player.global_position = new_pos
	#log_text("Successfully teleported the player to: " + str(new_pos), Color.CYAN)


func _command_player_freecam() -> void:
	pass
	#player.freecamActive = !player.freecamActive
	#log_text("Player freecam is now: " + str("Active" if player.freecamActive else "Inactive"), Color.CYAN)


func _command_give_player_weapon(_args : PackedStringArray) -> void:
	pass


func _command_set_player_health(_args : PackedStringArray) -> void:
	pass


#endregion
