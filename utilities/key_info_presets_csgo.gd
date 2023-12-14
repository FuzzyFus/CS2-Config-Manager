# this file contains the csgo/cfg file version of the key info
class_name KeyInfoPresetsCSGO

# slot4 = cycle grenade
# slot5 = bomb???
# slot6 = nade
# slot7 = flash
# slot8 = smoke
# slot9 = decoy
# slot10 = molly

# menu - +showscores, toggleconsole, teammenu, etc.
# interact - +use, +lookatweapon, drop
const attack_commands := ["+reload", "-attack", "+attack"]
const weapon_commands := ["slot1", "slot2", "slot3", "slot4", "slot5", "lastinv"]
const movement_commands := ["+jump", "+forward", "+moveleft", "+back", "+moveright", "+duck", "+speed", "+left", "+right"]
const interact_commands := ["+use", "+lookatweapon", "drop"]
const communicate_commands := ["+voicerecord", "player_ping", "radio", "+radialradio", "messagemode", "messagemode2"]
const equipment_commands := ["slot6", "slot7", "slot8", "slot9", "slot10"]
const menu_commands := ["+showscores", "toggleconsole", "teammenu", "buymenu"]

const attack_names := ["Reload", "PrimaryFire", "SecondaryFire"]
const weapon_names := ["Primary", "Secondary", "Knife", "CycleNade", "Bomb", "Quickswap"]
const movement_names := ["Jump", "↑", "←", "↓", "→", "Crouch", "Walk", "TurnLeft", "TurnRight"]
const interact_names := ["Use", "Inspect", "Drop"]
const communicate_names := ["Voicechat", "Ping", "Radio", "Chatwheel", "TextChat", "TeamChat"]
const equipment_names := ["Grenade", "Flash", "Smoke", "Decoy", "Molly"]
const menu_names := ["Scoreboard", "Console", "SwitchTeam", "BuyMenu"]

const attack_colour := Color(1,0.5,0.5)  # red
const weapon_colour := Color(1,0.65,0.5)  # orange
const movement_colour := Color(1,0.9,0.5)  # yellow
const buy_colour := Color(0.5,1,0.6)  # green
const interact_colour := Color(0.5,1,0.75)  #tirquoice
const communicate_colour := Color(0.5,0.85,1)  # aqua
const equipment_colour := Color(0.5,0.5,1) # blue
const menu_colour := Color(0.7,0.5,1)  # purple
const say_colour := Color(1,0.5,0.9)  # pink
const unknown_colour := Color.WHITE # white

# red = attack
# orange = weapons
# yellow = movement
# green = buy bind
# tirquoice = interact
# aqua = communicate
# blue = equipment
# pink = say binds
# purple = menu
# white = unknown

static func get_info_from_command(command: String):
	var keyinfo = {}
	
	# try to crop the command to the first, if multiple exist
	if command.contains(";"):
		command = command.substr(0, command.find(";"))
	
	# find command's origin, set the colour and target_name_idx
	if attack_commands.has(command):
		keyinfo["Colour"] = attack_colour
		keyinfo["Text"] = attack_names[attack_commands.find(command)]
	
	elif weapon_commands.has(command):
		keyinfo["Colour"] = weapon_colour
		keyinfo["Text"] = weapon_names[weapon_commands.find(command)]
	
	elif movement_commands.has(command):
		keyinfo["Colour"] = movement_colour
		keyinfo["Text"] = movement_names[movement_commands.find(command)]
	
	elif interact_commands.has(command):
		keyinfo["Colour"] = interact_colour
		keyinfo["Text"] = interact_names[interact_commands.find(command)]
	
	elif communicate_commands.has(command):
		keyinfo["Colour"] = communicate_colour
		keyinfo["Text"] = communicate_names[communicate_commands.find(command)]
	
	elif equipment_commands.has(command):
		keyinfo["Colour"] = equipment_colour
		keyinfo["Text"] = equipment_names[equipment_commands.find(command)]
	
	elif menu_commands.has(command):
		keyinfo["Colour"] = menu_colour
		keyinfo["Text"] = menu_names[menu_commands.find(command)]
	
	# other origins
	elif command.begins_with("say "):
		keyinfo["Colour"] = say_colour
		keyinfo["Text"] = "Say"
	
	elif command.begins_with("buy"):
		keyinfo["Colour"] = buy_colour
		keyinfo["Text"] = "Buy"
	
	else:
		keyinfo["Colour"] = unknown_colour
		keyinfo["Text"] = "Unknown"
	
	return keyinfo
