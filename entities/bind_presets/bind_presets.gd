extends Panel

var bind_spawner_scene := preload("res://entities/binds/bind_spawner.tscn")
@onready var bind_container: VBoxContainer = $ScrollContainer/Control

func _ready() -> void:
	var key_info_json = KeyInfoPresets.get_json()
	
	var unbind_spawner: BindSpawner = bind_spawner_scene.instantiate()
	unbind_spawner.initiate("", "Unbind", Color(0.5, 0.5, 0.5))
	bind_container.add_child(unbind_spawner)
	
	for keybind_category in key_info_json["Keybinds"]:
		var category_colour: Color
		
		if key_info_json["Keybinds"][keybind_category].size() <= 2 or typeof(key_info_json["Keybinds"][keybind_category]) != TYPE_DICTIONARY:
			continue
		
		var category_title: Label = Label.new()
		category_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		category_title.text = keybind_category
		bind_container.add_child(category_title)
		
		for data in key_info_json["Keybinds"][keybind_category]:
			if data == "Colour" or data == "Color":
				category_colour = Color(key_info_json["Keybinds"][keybind_category][data][0], key_info_json["Keybinds"][keybind_category][data][1], key_info_json["Keybinds"][keybind_category][data][2])
				continue
			
			var new_bind_spawner: BindSpawner = bind_spawner_scene.instantiate()
			new_bind_spawner.initiate(data, key_info_json["Keybinds"][keybind_category][data]["Name"], category_colour)
			bind_container.add_child(new_bind_spawner)
