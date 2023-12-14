class_name KeyTranslator

const godot_special  = ["QuoteLeft", "Minus", "Equal", "BracketLeft", "BracketRight", "BackSlash", "Apostrophe", "Period", "Comma", "Slash", "Menu"]
const source_special = ["`", "-", "=", "[", "]", "\\", "'", ".", ",", "/", "apps"]

const source_mouse = ["unused", "mouse1", "mouse2", "mouse3", "mwheelup", "mwheeldown", "unused-mwleft", "unused-mwright", "mouse4", "mouse5"]

static func key_godot_to_source(keycode: int) -> String:
	var key_name = OS.get_keycode_string(keycode)
	
	# mouse input
	if keycode < 0:
		key_name = source_mouse[abs(keycode)]
	
	# special (shift, ctrl, etc)
	elif godot_special.find(key_name) != -1:
		key_name = source_special[godot_special.find(key_name)]
	
	if key_name.length() > 1:
		return key_name.to_upper()
	return key_name.to_lower()

static func key_source_to_godot(key_name: String) -> int:
	# mouse input
	if source_mouse.has(key_name.to_lower()):
		return source_mouse.find(key_name.to_lower()) * -1
	
	# special (shift, ctrl, etc)
	elif source_special.has(key_name):
		key_name = godot_special[source_special.find(key_name)]
	
	return OS.find_keycode_from_string(key_name)

static func mouse_godot_to_source(mousecode: int) -> String:
	match mousecode:
		1:
			return "mouse1"
		2:
			return "mouse2"
		3:
			return "mouse3"
		4:
			return "mwheelup"
		5:
			return "mwheeldown"
		6:
			return "mouse4"
		7:
			return "mouse5"
		_:
			return ""
