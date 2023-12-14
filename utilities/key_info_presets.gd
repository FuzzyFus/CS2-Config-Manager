class_name KeyInfoPresets

# red = attack
# orange = weapons
# yellow = movement
# green = buy bind
# tirquoice = interact
# aqua = communicate
# blue = equipment
# pink = say binds
# purple = menu
# white = unknown

static func get_json():
	var file = FileAccess.open("res://properties/cs2-keyinfo.json", FileAccess.READ)
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	if error == OK:
		var data_recieved = json.data
		if typeof(data_recieved) == TYPE_DICTIONARY:
			return data_recieved 
		print("Unexpected data!")
		return
	print("JSON Parse Error: ", json.get_error_message(), " in file at line ", json.get_error_line())
	return

static func get_info_from_command(command: String):
	var preset_json = get_json()
	var keyinfo = {}
	
	if !(preset_json is Dictionary):
		print("KeyInfoPresets: json file was not parsed correctly! aborting")
		return
	
	# try to crop the command to the first, if multiple exist
	if command.contains(";"):
		command = command.substr(0, command.find(";"))
	
	# find command's origin, set the colour and target_name_idx
	for command_category in preset_json["Keybinds"]:
		if preset_json["Keybinds"][command_category].has(command):
			keyinfo["Colour"] = Color(preset_json["Keybinds"][command_category]["Colour"][0], preset_json["Keybinds"][command_category]["Colour"][1], preset_json["Keybinds"][command_category]["Colour"][2])
			keyinfo["Text"] = preset_json["Keybinds"][command_category][command]["Name"]
			return keyinfo
		
		if preset_json["Keybinds"][command_category].has("Prefix"):
			if command.begins_with(preset_json["Keybinds"][command_category]["Prefix"]):
				keyinfo["Colour"] = Color(preset_json["Keybinds"][command_category]["Colour"][0], preset_json["Keybinds"][command_category]["Colour"][1], preset_json["Keybinds"][command_category]["Colour"][2])
				keyinfo["Text"] = command_category
	
	if keyinfo.is_empty():
		keyinfo["Colour"] = Color(preset_json["Keybinds"]["UnknownColour"][0], preset_json["Keybinds"]["UnknownColour"][1], preset_json["Keybinds"]["UnknownColour"][2])
		keyinfo["Text"] = "Unknown"
	
	return keyinfo
