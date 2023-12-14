class_name BindSpawner
extends NinePatchRect

var given_text: String
var given_colour: Color

var command := ""
var is_mouse_inside := false
var bind_draggable_scene := preload("res://entities/binds/bind_draggable.tscn")
@onready var timeout_timer: Timer = $Timer
@onready var command_popup: Panel = $CommandMessage
@onready var command_popup_label: Label = $CommandMessage/Label
@onready var bind_label: Label = $Label
var command_popup_tween: Tween

func _ready() -> void:
	update_visuals()

func change_mouse_inside(new_mouse_inside: bool):
	is_mouse_inside = new_mouse_inside
	if !new_mouse_inside:
		set_popup_visibility(false)
	
	timeout_timer.start()
	timeout_timer.paused = !new_mouse_inside
	update_visuals()

func set_popup_visibility(new_visible: bool):
	if command_popup_tween:
		command_popup_tween.kill()
	
	command_popup_tween = create_tween().set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	var new_modulate: float = 1.0 if new_visible else 0.0
	command_popup_tween.tween_property(command_popup, "modulate:a", new_modulate, 0.2)
	if !new_visible:
		command_popup_tween.finished.connect(update_visuals)

func initiate(new_command: String, new_text: String, new_colour: Color):
	command = new_command 
	given_text = new_text
	given_colour = new_colour

func update_visuals():
	bind_label.text = given_text
	self_modulate = given_colour
	
	command_popup_label.text = command
	if modulate.a <= 0.0:
		command_popup.visible = false
	else:
		command_popup.visible = true

func mouse_input(event):
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT or !event.is_pressed():
			return
		var new_bind_draggable: Bind = bind_draggable_scene.instantiate()
		new_bind_draggable.set_info(command, given_text, given_colour)
		get_tree().get_first_node_in_group("SelectedBind").add_child(new_bind_draggable)
