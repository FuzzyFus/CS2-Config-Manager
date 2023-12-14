class_name KeyboardKey
extends NinePatchRect

const UNPRESSED_COLOUR_OFFSET := 0.25

@onready var picture = $TextureRect
@onready var text = $Label

var given_text: String
var given_colour := Color(0.5,0.5,0.5,1)
var command: String

# note: negative = mouse
@export var keycode: int

func _ready() -> void:
	update_visual()

func set_picture(new_texture: Texture2D) -> void:
	picture.texture = new_texture

func update_visual() -> void:
	change_key_modulate()
	
	if given_text.is_empty():
		if keycode < 0:
			match abs(keycode):
				MOUSE_BUTTON_LEFT:
					text.text = "Left"
				MOUSE_BUTTON_RIGHT:
					text.text = "Right"
				MOUSE_BUTTON_MIDDLE:
					text.text = "Middle"
				MOUSE_BUTTON_WHEEL_UP:
					text.text = "ScrUp"
				MOUSE_BUTTON_WHEEL_DOWN:
					text.text = "ScrDown"
				MOUSE_BUTTON_XBUTTON1:
					text.text = "Mouse4"
				MOUSE_BUTTON_XBUTTON2:
					text.text = "Mouse5"
			return
		
		text.text = OS.get_keycode_string(keycode)
		return
	
	text.text = given_text

func change_key_modulate(pressed := false) -> void:
	if pressed:
		self_modulate = given_colour
		return
	var too_dark = given_colour.v - UNPRESSED_COLOUR_OFFSET < .2
	var brightness = given_colour.v + UNPRESSED_COLOUR_OFFSET if too_dark else given_colour.v - UNPRESSED_COLOUR_OFFSET
	self_modulate = Color.from_hsv(given_colour.h, given_colour.s, brightness)

func mouse_input(event) -> void:
	if event is InputEventMouseButton:
		# ignore any other inputs but left/right clicks
		if event.button_index != MOUSE_BUTTON_LEFT and event.button_index != MOUSE_BUTTON_RIGHT:
			return
		
		change_mouse_active(event.is_pressed())

func change_mouse_active(new_mouse_active: bool) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and new_mouse_active:
		(get_tree().get_first_node_in_group("Main") as Main).change_selected_key(self)
		get_tree().call_group("Main", "update_info")
		change_key_modulate(true)
		return
	change_key_modulate(false)

func set_info(key_info: Dictionary):
	given_text = key_info["Text"]
	given_colour = key_info["Colour"]
	update_visual()
