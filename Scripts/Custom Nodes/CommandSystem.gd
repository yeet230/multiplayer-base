class_name CommandHandler extends Node


var clientCommands: Dictionary[String, Callable] = {}
var cmdAliases: PackedStringArray = []
var UIHandler: Panel


func _ready() -> void:
	Global.commandHandler = self
	
	register_command(["help"], _command_help)
	register_command(["tp", "teleport"], _command_player_teleport)
	register_command(["freecam", "noclip"], _command_player_freecam)
	register_command(["weapon-help", "help-w"], _command_weapon_help)
	register_command(["give"], _command_give_player_weapon)
	#register_command(["setHealth"], _command_set_player_health)



func log_text(text: String, colour : Color) -> void:
	UIHandler.log_text(text, colour)

#
func register_command(command_name: PackedStringArray, ClientSideCallable: Callable) -> void:
	for i in range(command_name.size()):
		clientCommands[command_name[i]] = ClientSideCallable
		
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


func call_command(command : String) -> void:
	clientCommands[command].call()

func call_command_with_args(command : String, args : PackedStringArray) -> void:
	clientCommands[command].call(args)



#region Commands

func _command_help() -> void:
	log_text("Available commands: \n(Aliases are listed on the same row)", Color.CYAN)
	for cmd in cmdAliases:
		log_text("- " + cmd, Color.CYAN)


func _command_weapon_help() -> void:
	log_text("Avaliable weapons:", Color.CYAN)
	for w in Enum.WEAPON_ID:
		var key: int = Enum.WEAPON_ID.get(w)
		log_text(str(w, " : ", key), Color.CYAN)
	

func _command_player_teleport(args : PackedStringArray) -> void:
	print(args)
	
	
	if args.size() != 3:
		log_text("Expected 3 float arguments for the command", Color.RED)
		return
	
	var new_pos : Vector3 = Vector3(float(args[0]), float(args[1]), float(args[2]))
	
	for i in 3:
		if args[i].contains("+") or args[i].contains("-"):
			new_pos[i] = Global.clientPlayer.global_position[i] + float(args[i])
	
	Global.clientPlayer.global_position = new_pos
	log_text("Successfully teleported the player to: " + str(new_pos), Color.CYAN)


func _command_player_freecam() -> void:
	pass
	#player.freecamActive = !player.freecamActive
	#log_text("Player freecam is now: " + str("Active" if player.freecamActive else "Inactive"), Color.CYAN)


func _command_give_player_weapon(args : PackedStringArray) -> void:
	if args.size() != 1:
		log_text(str("Expected 1 argument but recieved ", args.size(), " instead"), Color.RED)
		return
	
	var newWeapon: int = int(args[0])
	var keyName: String = Enum.WEAPON_ID.find_key(newWeapon)
	
	
	if Enum.WEAPON_ID.find_key(newWeapon):
		MultiplayerManager.player_request_weapon_change.rpc_id(1, newWeapon)
		
		
		log_text(str("Giving ", keyName," with the WEAPON_ID of ", newWeapon), Color.CYAN)
	else:
		log_text(str("Unkown weapon: ", newWeapon), Color.RED)


func _command_set_player_health(_args : PackedStringArray) -> void:
	pass


#endregion
