class_name SourceConfigReader

const default_export_path := "res://exports/"

static func get_config(config_path: String):
	var file := FileAccess.open(config_path, FileAccess.READ)
	var config: Dictionary
	
	# get config file
	if config_path.ends_with(".cfg"):
		config = load_cfg(file)
	elif config_path.ends_with(".vcfg"):
		config = load_vcfg(file)
	else:
		print("SourceConfigReader: Config filetype not supported!")
		return null
	
	if config:
		return remove_unbound_flags(config)

static func load_cfg(config_file) -> Dictionary:
	var keybinds := {}
	var unknown := []
	while not config_file.eof_reached():
		var line = config_file.get_line()
		
		if line.begins_with("bind"):
			var first_quote_idx: int = line.find('"') + 1
			var second_quote_idx: int = line.find('"', first_quote_idx)
			
			var key: String = line.substr(first_quote_idx, second_quote_idx - first_quote_idx)
			
			var requested_command: String = line.substr(second_quote_idx + 1).strip_edges()  # separate command and strip whitespace
			requested_command = requested_command.substr(1, requested_command.length() - 2)  # get rid of quotes
			
			#print("adding ", key, " (",OS.get_keycode_string(KeyTranslator.key_source_to_godot(key)), ")")
			keybinds[KeyTranslator.key_source_to_godot(key)] = requested_command
		else:
			unknown.append(line)
	
	return { "Keybinds" = keybinds, "Unknown" = unknown}

static func load_vcfg(config_file) -> Dictionary:
	var keybinds := {}
	var unknown := []
	while not config_file.eof_reached():
		var line: String = config_file.get_line().strip_edges()
		
		if line.count('"') <= 2:
			continue
		
		elif line.begins_with('"'):
			var first_quote_idx: int = line.substr(1).find('"')
			var second_quote_idx: int = line.find('"', first_quote_idx)
			
			var key: String = line.substr(1, first_quote_idx)
			
			var requested_command: String = line.substr(key.length() + 2).strip_edges()  # get rid of keybind
			requested_command = requested_command.substr(1, requested_command.length() - 2)  # get rid of quotes
			
			#print("adding ", key, " (",OS.get_keycode_string(KeyTranslator.key_source_to_godot(key)), ")")
			keybinds[KeyTranslator.key_source_to_godot(key)] = requested_command
	
	return { "Keybinds" = keybinds, "Unknown" = unknown}

# takes config_core as a base, and then adds/overrights settings from config_additions
static func merge_cfgs(config_core: Dictionary, config_additions: Dictionary) -> Dictionary:
	for keybind in config_additions["Keybinds"]:
		config_core["Keybinds"][keybind] = config_additions["Keybinds"][keybind]
	for unknown_setting in config_additions["Unknown"]:
		config_core["Unknown"][unknown_setting] = config_additions["Unknown"][unknown_setting]
	
	return config_core

static func remove_unbound_flags(config_file) -> Dictionary:
	for keybind in config_file["Keybinds"]:
		if config_file["Keybinds"][keybind] == "<unbound>":
			# TODO: this doesnt erase for some reason?? it stays :s
			config_file["Keybinds"].erase(keybind)
	
	return config_file

static func save_as_autoexec(keybinds: Dictionary, path := ""):
	if path.is_empty():
		path = default_export_path
	var file_name := "cs2cm-export.cfg"
	print(path + file_name)
	var file := FileAccess.open(path + file_name, FileAccess.WRITE)
	
	
	file.store_line("echo \"cs2cm config :^D\"")
	file.store_line("unbindall")
	
	for keybind in keybinds:
		if !keybinds[keybind].is_empty():
			file.store_line("bind \"" + KeyTranslator.key_godot_to_source(keybind) + "\" \"" + keybinds[keybind] + "\"")
	
	print("SourceConfigReader: config saved at ", path)
	pass

static func save_as_vcfg(keybinds: Dictionary, path := ""):
	if path.is_empty():
		path = default_export_path 
	var file_name := "cs2cm-export.vcfg"
	var file := FileAccess.open(path, FileAccess.WRITE)
	
	file.store_line("\"config\"\n{")
	file.store_line("\t\"bindings\"\n\t{")
	
	for keybind in keybinds:
		if !keybinds[keybind].is_empty():
			file.store_line("\t\t\"" + KeyTranslator.key_godot_to_source(keybind) + "\"\t\"" + keybinds[keybind] + "\"")
	
	file.store_line("\t}\n}")
	print("SourceConfigReader: config saved at ", path)
	pass
	
static func save_as_vcfg_web(keybinds: Dictionary):
	var file := ""
	
	file += ("\"config\"\n{")
	file += ("\t\"bindings\"\n\t{")
	
	for keybind in keybinds:
		if !keybinds[keybind].is_empty():
			file += ("\n\t\t\"" + KeyTranslator.key_godot_to_source(keybind) + "\"\t\"" + keybinds[keybind] + "\"")
	
	file += ("\n\t}\n}")
	return file
