class_name Main
extends Control

@onready var mouse: Mouse = $Mouse
@onready var keyboard: Keyboard = $Keyboard
@onready var keyinfo_label: Label = $KeyInfo/VBoxContainer/Label
@onready var keyinfo_lineedit: LineEdit = $KeyInfo/VBoxContainer/LineEdit
@onready var selected_bind_parent: Control = $SelectedBind
@onready var version_label: Label = $VersionLabel

@onready var open_file_dialog: FileDialog = $LoadButton/OpenFileDialog
@onready var export_dialog: ConfirmationDialog = $SaveButton/ExportDialog
@onready var import_dialog: AcceptDialog = $LoadButton/ImportDialog

const DEFAULT_VCFG_PATH := "res://properties/user_keys_default.vcfg"
var selected_key: KeyboardKey

# Called when the node enters the scene tree for the first time.
func _ready():
	open_file_dialog.visible = true
	version_label.text = ProjectSettings.get_setting("application/config/name") + " " + ProjectSettings.get_setting("application/config/version")

func load_config(path: String) -> void:
	var lyt = Keyboard.generate_layout("res://properties/keyboard_layouts/standard_physcode.txt")
	var default_cfg: Dictionary = SourceConfigReader.get_config(DEFAULT_VCFG_PATH)
	var cfg: Dictionary = SourceConfigReader.merge_cfgs(default_cfg, SourceConfigReader.get_config(path))
	keyboard.generate_keys(lyt, cfg)
	mouse.set_binds(cfg)

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

func save_config(path: String) -> void:
	var keybind_dict = keyboard.get_keybinds()
	keybind_dict.merge(mouse.get_keybinds())
	
	(export_dialog.get_child(0) as TextEdit).text = SourceConfigReader.save_as_vcfg_web(keybind_dict)
	export_dialog.visible = true

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

func copy_exported_config_to_clipboard() -> void:
	DisplayServer.clipboard_set( (export_dialog.get_child(0) as TextEdit).text )

# TODO: this is silly and should be worked in with load_config()
func import_web_config() -> void:
	import_dialog.visible = false
	var rawtext_config: String = import_dialog.get_child(0).get_node("TextEdit").text
	
	var lyt = Keyboard.generate_layout("res://properties/keyboard_layouts/standard_physcode.txt")
	var default_cfg: Dictionary = SourceConfigReader.get_config(DEFAULT_VCFG_PATH)
	var cfg: Dictionary = SourceConfigReader.merge_cfgs(default_cfg, SourceConfigReader.load_vcfg(rawtext_config))
	keyboard.generate_keys(lyt, cfg)
	mouse.set_binds(cfg)
