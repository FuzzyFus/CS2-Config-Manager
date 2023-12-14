class_name Mouse
extends Control

@onready var key_container: Control = $Keys

func set_binds(config: Dictionary) -> void:
	for key in key_container.get_children():
		if config["Keybinds"].has(key.keycode):
			key.command = config["Keybinds"][key.keycode]
			
			# set info data (colour, text, picture) according to the KeyInfoPresets data
			key.set_info( KeyInfoPresets.get_info_from_command(config["Keybinds"][key.keycode]) )

func get_keybinds() -> Dictionary:
	var keybind_dict := {}
	
	for key in key_container.get_children():
		keybind_dict[key.keycode] = key.command
	
	return keybind_dict
