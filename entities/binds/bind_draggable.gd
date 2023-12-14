class_name Bind
extends NinePatchRect

var given_text: String
var given_colour := Color(0.5,0.5,0.5,1)
var command := ""

@onready var text: Label = $Label
@onready var timeout_timer: Timer = $Timer
var rotation_tween: Tween

func _ready() -> void:
	update_visual()

func _process(delta) -> void:
	position = get_viewport().get_mouse_position() - size / 2

func _input(event):
	if event is InputEventMouseButton:
		# ignore any other inputs but left/right clicks
		if event.button_index != MOUSE_BUTTON_LEFT or event.is_pressed():
			return
		visible = false
		get_tree().call_group("Main", "apply_new_bind")
		await get_tree().process_frame
		queue_free()

func set_info(new_command: String, new_text: String, new_colour: Color):
	command = new_command
	given_text = new_text
	given_colour = new_colour

func update_visual() -> void:
	text.text = given_text
	self_modulate = given_colour
