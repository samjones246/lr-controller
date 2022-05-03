extends Node

var deadzone = 0.2
var sensMult = 5
var player : Node
var input_swapped = false
var CONFIG_NAME = "controller_bindings.json"

var BUTTON_NAMES = {
	"A": JOY_XBOX_A,
	"B": JOY_XBOX_B,
	"X": JOY_XBOX_X,
	"Y": JOY_XBOX_Y,
	"L1": JOY_L,
	"R1": JOY_R,
	"L2": JOY_L2,
	"R2": JOY_R2,
	"L3": JOY_L3,
	"R3": JOY_R3,
	"START": JOY_START,
	"SELECT": JOY_SELECT,
	"DPAD_UP": JOY_DPAD_UP,
	"DPAD_DOWN": JOY_DPAD_DOWN,
	"DPAD_LEFT": JOY_DPAD_LEFT,
	"DPAD_RIGHT": JOY_DPAD_RIGHT,
}

var ACTION_SUBS = {
	"pause":"ui_cancel"
}

var button_actions = {
	"ui_cancel": [JOY_START],
	"objective": [JOY_SELECT],
	"move_jump": [JOY_XBOX_A],
	"reload": [JOY_XBOX_B],
	"Interact": [JOY_XBOX_X],
	"respawn": [JOY_XBOX_Y],
	"equipPogo": [JOY_DPAD_UP],
	"equipHammer": [JOY_DPAD_LEFT],
	"equipCoin": [JOY_DPAD_RIGHT],
	"equipDust": [JOY_DPAD_DOWN],
	"action": [JOY_R, JOY_R2],
	"altAction": [JOY_L, JOY_L2],
	"move_sprint": [JOY_L3],
	"dialogue_advance": [JOY_XBOX_A]
}



var action_queue = []

func _ready():
	InputMap.action_set_deadzone("move_left", 0.2)
	InputMap.action_set_deadzone("move_right", 0.2)
	InputMap.action_set_deadzone("move_forward", 0.2)
	InputMap.action_set_deadzone("move_backward", 0.2)

	InputMap.add_action("dialogue_advance")

	var ev = InputEventJoypadMotion.new()
	ev.axis = JOY_AXIS_0
	ev.axis_value = - 1.0
	InputMap.action_add_event("move_left", ev)

	ev = InputEventJoypadMotion.new()
	ev.axis = JOY_AXIS_0
	ev.axis_value = 1.0
	InputMap.action_add_event("move_right", ev)

	ev = InputEventJoypadMotion.new()
	ev.axis = JOY_AXIS_1
	ev.axis_value = -1.0
	InputMap.action_add_event("move_forward", ev)

	ev = InputEventJoypadMotion.new()
	ev.axis = JOY_AXIS_1
	ev.axis_value = 1.0
	InputMap.action_add_event("move_backward", ev)

	load_bindings()
	
	for action in button_actions:
		for button in button_actions[action]:
			ev = InputEventJoypadButton.new()
			ev.button_index = button
			ev.pressed = true
			InputMap.action_add_event(action, ev)

	ev = InputEventJoypadButton.new()
	ev.button_index = JOY_BUTTON_1
	InputMap.action_erase_event("ui_cancel", ev)

func load_bindings():
	var path = ""
	if OS.has_feature("editor"):
		path = "res://mods/" + CONFIG_NAME
	else:
		path = OS.get_executable_path().get_base_dir().plus_file("mods/" + CONFIG_NAME)
	var file : File = File.new()
	if file.open(path, File.READ) == OK:
		var json = file.get_as_text()
		var data = JSON.parse(json)
		if data.error == OK:
			if typeof(data.result) == TYPE_DICTIONARY:
				for action in data.result:
					if action == "sens_mult":
						if typeof(data.result[action]) != TYPE_REAL or data.result[action] <= 0:
							printerr("Value for sens_mult must be a positive number")
							continue
						sensMult = data.result[action]
						continue
					var subbed_action = action
					if action in ACTION_SUBS:
						subbed_action = ACTION_SUBS[action]
					if not (subbed_action in button_actions):
						printerr("Unknown action: " + action)
						continue
					if typeof(data.result[action]) == TYPE_ARRAY:
						button_actions[subbed_action] = []
						for button in data.result[action]:
							var btnVal
							if typeof(button) == TYPE_REAL:
								if int(button) >= 0 and int(button) < JOY_BUTTON_MAX:
									btnVal = int(button)
								else:
									printerr("Error reading bindings for action " + action + ": " + button + " is not a valid button number")
							elif typeof(button) == TYPE_STRING:
								if button in BUTTON_NAMES:
									btnVal = BUTTON_NAMES[button]
								else:
									printerr("Error reading bindings for action " + action + ": " + button + " is not a valid button name")
									continue
							else:
								printerr("Error reading bindings for action " + action + ": Expected string or number, got " + typeof(button))
								continue
							button_actions[subbed_action].append(btnVal)
					else:
						printerr("Value for action " + action + " must be a list of button")
			else:
				printerr("Error reading controller bindings: File contents is not a JSON Object")
		else:
			printerr("Error reading controller bindings: Unable to parse JSON")
	else:
		printerr("Error reading controller bindings: File does not exist or could not be read")


func _process(_delta):
	player = null
	player = get_tree().current_scene.get_node_or_null("ViewportContainer/Viewport/Player")
	if player == null:
		return

	if not player.is_processing():
		return
	if Input.get_connected_joypads().size() > 0:
		var joy_axis = Vector2(Input.get_joy_axis(0, JOY_AXIS_2), Input.get_joy_axis(0, JOY_AXIS_3))
		if joy_axis.length() > deadzone:
			camera_rotation(joy_axis)

func camera_rotation(joy_axis : Vector2):
	if joy_axis.length() > deadzone:
		var horizontal = - joy_axis.x * (Global.playerSensitivity / 100) * sensMult
		var vertical = - joy_axis.y * (Global.playerSensitivity / 100) * sensMult

		player.rotate_y(deg2rad(horizontal) / (10 / Global.sens))
		player.head.rotate_x(deg2rad(vertical) / (10 / Global.sens))
		
		
		var temp_rot:Vector3 = player.head.rotation_degrees
		temp_rot.x = clamp(temp_rot.x, - 90, 90)
		player.head.rotation_degrees = temp_rot

func _input(event):
	if event.is_action_pressed("dialogue_advance"):
		var dialogue = get_tree().current_scene.get_node_or_null("ViewportContainer/dialogue")
		if dialogue != null and dialogue.catchClick:
			dialogue.advance()
			dialogue.catchClick = false

			
