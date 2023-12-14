class_name Main
extends Control

@onready var mouse: Mouse = $Mouse
@onready var keyboard: Keyboard = $Keyboard
@onready var keyinfo_label: Label = $KeyInfo/VBoxContainer/Label
@onready var keyinfo_lineedit: LineEdit = $KeyInfo/VBoxContainer/LineEdit
@onready var selected_bind_parent: Control = $SelectedBind
@onready var save_file_dialog: FileDialog = $SaveButton/FileDialog
@onready var version_label: Label = $VersionLabel

var selected_key: KeyboardKey

var cfg_path := "C:/Program Files (x86)/Steam/steamapps/common/Counter-Strike Global Offensive/csgo/cfg/alex.cfg"
var vcfg_path := "C:/Program Files (x86)/Steam/userdata/86135819/730/local/cfg/cs2_user_keys_0_slot0.vcfg"
var default_vcfg_path := "C:/Program Files (x86)/Steam/steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg/user_keys_default.vcfg"

# Called when the node enters the scene tree for the first time.
func _ready():
	version_label.text = ProjectSettings.get_setting("application/config/name") + " " + ProjectSettings.get_setting("application/config/version")
	var lyt = Keyboard.generate_layout("res://properties/keyboard_layouts/standard_physcode.txt")
	
	var default_cfg: Dictionary = SourceConfigReader.get_config(default_vcfg_path)
	var cfg: Dictionary = SourceConfigReader.merge_cfgs(default_cfg, SourceConfigReader.get_config(vcfg_path))
	keyboard.generate_keys(lyt, cfg)
	mouse.set_binds(cfg)
	pass # Replace with function body.

func _unhandled_key_input(event):
	if event.is_echo() or keyinfo_lineedit.has_focus():
		return
	
	for keynode in keyboard.get_children():
		if keynode.keycode == event.physical_keycode:
			keynode.change_key_modulate(event.is_pressed())
			if event.is_pressed():
				change_selected_key(keynode)
			update_info()

func update_info() -> void:
	if !selected_key:
		return
	
	if selected_key.keycode < 0:
		match abs(selected_key.keycode):
			MOUSE_BUTTON_LEFT:
				keyinfo_label.text = "Left Click"
			MOUSE_BUTTON_RIGHT:
				keyinfo_label.text = "Right Click"
			MOUSE_BUTTON_MIDDLE:
				keyinfo_label.text = "Middle Click"
			MOUSE_BUTTON_WHEEL_UP:
				keyinfo_label.text = "Scroll Up"
			MOUSE_BUTTON_WHEEL_DOWN:
				keyinfo_label.text = "Scroll Down"
			MOUSE_BUTTON_XBUTTON1:
				keyinfo_label.text = "Mouse4"
			MOUSE_BUTTON_XBUTTON2:
				keyinfo_label.text = "Mouse5"
	else:
		keyinfo_label.text = OS.get_keycode_string(selected_key.keycode)
	keyinfo_lineedit.text = selected_key.command

func apply_new_bind() -> void:
	if selected_bind_parent.get_child_count() <= 0 or !selected_key:
		return
	
	var target_keys := []
	if selected_key.get_parent().is_in_group("Keyboard"):
		target_keys = keyboard.get_key_instances(keyboard.get_children(), selected_key.keycode)
	else:
		target_keys.append(selected_key)
	
	var selected_bind: Bind = selected_bind_parent.get_child(0)
	for key in target_keys:
		key.command = selected_bind.command
		if selected_bind.command.is_empty():
			key.set_info({"Text": "", "Colour": Color(0.5,0.5,0.5)})
			return
		key.set_info(KeyInfoPresets.get_info_from_command(selected_bind.command))

func save_config(end_directory: String) -> void:
	var keybind_dict = keyboard.get_keybinds()
	keybind_dict.merge(mouse.get_keybinds())
	if end_directory.ends_with(".vcfg"):
		SourceConfigReader.save_as_vcfg(keybind_dict, end_directory)
		return
	elif end_directory.ends_with(".cfg"):
		SourceConfigReader.save_as_autoexec(keybind_dict, end_directory)

func change_selected_key(key: KeyboardKey):
	selected_key = key

func change_selected_key_command(new_command: String):
	# get instances of key (if mouse, ignore and just use selected)
	var target_keys := []
	if selected_key.get_parent().is_in_group("Keyboard"):
		target_keys = keyboard.get_key_instances(keyboard.get_children(), selected_key.keycode)
	else:
		target_keys.append(selected_key)
	
	for key in target_keys:
		print("key ", key)
		key.command = new_command
		
		if new_command.is_empty():
			key.given_colour = Color(0.5,0.5,0.5,1)
			key.given_text = ""
		else:
			key.set_info(KeyInfoPresets.get_info_from_command(new_command))
		key.update_visual()
