class_name Keyboard
extends Control

var key_scene := preload("res://entities/keyboard/key.tscn")
var key_size := Vector2(64, 64)
var key_distance := 2
var duplicated_keys := []

func _ready():
	generate_keys(generate_layout("res://properties/keyboard_layouts/standard_physcode.txt"))

# generates the keyboard's keys (organized with the given layout), aswell as assigning any binds
func generate_keys(layout, config = null):
	for key in get_children():
		key.queue_free()
	duplicated_keys = []
	
	var key_pos := Vector2.ZERO
	for row in layout:
		for keydata in row:
			var new_key = spawn_key(keydata[0], keydata[1])
			add_child(new_key)
			
			if config:
				if config["Keybinds"].has(keydata[0]):
					new_key.command = config["Keybinds"][keydata[0]]
					
					# set info data (colour, text, picture) according to the KeyInfoPresets data
					new_key.set_info( KeyInfoPresets.get_info_from_command(config["Keybinds"][keydata[0]]) )
			
			new_key.position = key_pos
			key_pos.x += new_key.size.x + key_distance
		key_pos.x = 0
		key_pos.y += key_size.y + key_distance

# used to find keys that appear twice (ctrl, alt, shift...)
static func get_key_instances(keys, target_keycode: int):
	var duplicate_keys = []
	
	for key in keys:
		if key.keycode == target_keycode:
			duplicate_keys.append(key)
	
	return duplicate_keys

# generates a layout for use in generate_keys
static func generate_layout(layout_location: String):
	var file := FileAccess.open(layout_location, FileAccess.READ)
	
	var keyboard_layout := []
	while not file.eof_reached():
		var keyboard_row := []
		
		var key_segment := file.get_csv_line(" ")
		if key_segment.size() < 2:
			break
		for key_info in key_segment:
			var values := key_info.split("-")
			keyboard_row.append([int(values[0]), float(values[1])])
		
		keyboard_layout.append(keyboard_row)
	return keyboard_layout

# instantiates a key node and assigns it the requested values
func spawn_key(keycode: int, size_multiplier: float, settings := {}):
	var new_key := key_scene.instantiate() as KeyboardKey
	new_key.keycode = keycode
	new_key.size.x *= size_multiplier
	
	for setting in settings:
		match settings:
			"Colour":
				new_key.self_modulate = settings["Colour"]
			"Text":
				new_key.set_text(settings["Text"])
			"Texture":
				# we gotta do picture loading here
				pass
			"Command":
				new_key.command = settings["Command"]
	return new_key

func get_keybinds() -> Dictionary:
	var keybind_dict := {}
	
	for key in get_children():
		keybind_dict[key.keycode] = key.command
	
	return keybind_dict
