extends Node

var deadzone = 0.2
var sensMult = 10
var player : Node
var dialogue : Node
var give_up : Node
var CONFIG_NAME = "controller_bindings.json"
var toggle_sprint = true

var BUTTON_NAMES = {
	"A": JOY_XBOX_A,
	"CROSS": JOY_XBOX_A,
	"B": JOY_XBOX_B,
	"CIRCLE": JOY_XBOX_B,
	"X": JOY_XBOX_X,
	"SQUARE": JOY_XBOX_X,
	"Y": JOY_XBOX_Y,
	"TRIANGLE": JOY_XBOX_Y,
	"LB": JOY_L,
	"L1": JOY_L,
	"RB": JOY_R,
	"R1": JOY_R,
	"LT": JOY_L2,
	"L2": JOY_L2,
	"RT": JOY_R2,
	"R2": JOY_R2,
	"LS": JOY_L3,
	"L3": JOY_L3,
	"RS": JOY_R3,
	"R3": JOY_R3,
	"START": JOY_START,
	"SELECT": JOY_SELECT,
	"DPAD_UP": JOY_DPAD_UP,
	"DPAD_DOWN": JOY_DPAD_DOWN,
	"DPAD_LEFT": JOY_DPAD_LEFT,
	"DPAD_RIGHT": JOY_DPAD_RIGHT,
}

# List of aliases for actions which can be used in the config file
var ACTION_SUBS = {
	"pause":"ui_cancel"
}

# Mapping from actions to buttons. Populated with default controls but will be overwritten by config file if present
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

func _ready():
	# Adjust movement deadzones to be suitable for controller
	InputMap.action_set_deadzone("move_left", 0.2)
	InputMap.action_set_deadzone("move_right", 0.2)
	InputMap.action_set_deadzone("move_forward", 0.2)
	InputMap.action_set_deadzone("move_backward", 0.2)

	# Dialogue advance is not an action which the game defines, so we define it here and handle it ourselves.
	# Normally the game check the 'action' action for advancing dialogue, but for controller it's desirable to have
	# a seperate binding
	InputMap.add_action("dialogue_advance")
	InputMap.add_action("move_toggle_sprint")

	# Add left stick movements to movement actions
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
	
	# Register mappings
	for action in button_actions:
		for button in button_actions[action]:
			ev = InputEventJoypadButton.new()
			ev.button_index = button
			ev.pressed = true
			if action == "move_sprint" and toggle_sprint:
				InputMap.action_add_event("move_toggle_sprint", ev)
			else:	
				InputMap.action_add_event(action, ev)

	# By default, JOY_XBOX_B is registered under the ui_cancel action. The game uses this action to pause, so we need to
	# remove this button from the action so that the game doesn't pause when the player presses B.
	ev = InputEventJoypadButton.new()
	ev.button_index = JOY_XBOX_B
	InputMap.action_erase_event("ui_cancel", ev)


# Attempt to load controller bindings from file
func load_bindings():
	# Need to set path differently depending on whether we're in a testing or production environment
	var path = ""
	if OS.has_feature("editor"):
		path = "res://mods/" + CONFIG_NAME
	else:
		path = OS.get_executable_path().get_base_dir().plus_file("mods/" + CONFIG_NAME)
		
	var file : File = File.new()
	if file.open(path, File.READ) == OK:
		var json = file.get_as_text()
		file.close()
		var data = JSON.parse(json)
		if data.error == OK:
			if typeof(data.result) == TYPE_DICTIONARY:
				for action in data.result:
					# Handle sens_mult/toggle_sprint seperately
					if action == "sens_mult":
						if typeof(data.result[action]) != TYPE_REAL or data.result[action] <= 0:
							printerr("Value for sens_mult must be a positive number")
							continue
						sensMult = data.result[action]
						continue
					if action == "toggle_sprint":
						if typeof(data.result[action]) != TYPE_BOOL:
							printerr("Value for toggle_sprint must be a boolean")
							continue
						toggle_sprint = data.result[action]
						continue
					# This var stores the actual action name after alias substitution has potentially happened
					# The original string is still used to reference the json
					var subbed_action = action
					if action in ACTION_SUBS:
						subbed_action = ACTION_SUBS[action]
					if not (subbed_action in button_actions):
						printerr("Unknown action: " + action)
						continue
					if typeof(data.result[action]) == TYPE_ARRAY:
						button_actions[subbed_action] = []
						for button in data.result[action]:
							# Determine which button has been specified (or error and skip if invalid), and add it to the bindings dict
							var btnVal
							if typeof(button) == TYPE_REAL:
								if int(button) >= 0 and int(button) < JOY_BUTTON_MAX:
									btnVal = int(button)
								else:
									printerr("Error reading bindings for action " + action + ": " + button + " is not a valid button number")
									continue
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
	# Refresh node references in case the scene changed
	var vpcont = get_tree().current_scene.get_node_or_null("ViewportContainer")
	if vpcont != null:
		player = vpcont.get_node_or_null("Viewport/Player")
		dialogue = vpcont.get_node_or_null("dialogue")
		give_up = vpcont.get_node_or_null("give up ")

	# If no player exists in the current scene there's nothing to do here
	if player == null:
		return

	# If player isn't processing then aim shouldn't be handled right now
	if not player.is_processing():
		return

	# Detect right stick movement and pass it on to the player to handle like mouse movement
	if Input.get_connected_joypads().size() > 0:
		var joy_axis = Vector2(Input.get_joy_axis(0, JOY_AXIS_2), Input.get_joy_axis(0, JOY_AXIS_3))
		if joy_axis.length() > deadzone:
			player.mouse_axis = joy_axis * sensMult
			player.camera_rotation()

	if player.move_axis.length() == 0:
		Input.action_release("move_sprint")


func _input(event):
	# Handle our custom dialogue_advance action
	if event.is_action_pressed("dialogue_advance"):
		if dialogue != null and dialogue.catchClick:
			dialogue.advance()
			dialogue.catchClick = false

	# Handle the 'give up tool' screen
	if give_up != null and give_up.visible:
		if event.is_action_pressed("equipPogo") and give_up.pogo.visible:
			give_up._on_pogo_pressed()
		elif event.is_action_pressed("equipHammer") and give_up.hammer.visible:
			give_up._on_hammer_pressed()
		elif event.is_action_pressed("equipCoin") and give_up.coin.visible:
			give_up._on_coin_pressed()
		elif event.is_action_pressed("equipDust") and give_up.spray.visible:
			give_up._on_bottle_pressed()

	if event.is_action_pressed("move_toggle_sprint"):
		if event.pressed:
			Input.action_press("move_sprint")

			
