extends Node

var deadzone = 0.2
var sensMult = 5
var player : Node

var button_actions = {
	JOY_START: "ui_cancel",
	JOY_SELECT: "objective",
	JOY_XBOX_A: "move_jump",
	JOY_XBOX_B: "reload",
	JOY_XBOX_X: "Interact",
	JOY_XBOX_Y: "respawn",
	JOY_DPAD_UP: "equipPogo",
	JOY_DPAD_LEFT: "equipHammer",
	JOY_DPAD_RIGHT: "equipCoin",
	JOY_DPAD_DOWN: "equipDust",
	JOY_R: "action",
	JOY_R2: "action",
	JOY_L: "altAction",
	JOY_L2: "altAction",
	JOY_L3: "move_sprint"
}

func _ready():
	InputMap.action_set_deadzone("move_left", 0.2)
	InputMap.action_set_deadzone("move_right", 0.2)
	InputMap.action_set_deadzone("move_forward", 0.2)
	InputMap.action_set_deadzone("move_backward", 0.2)

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

	for axis in button_actions:
		ev = InputEventJoypadButton.new()
		ev.button_index = axis
		ev.pressed = true
		InputMap.action_add_event(button_actions[axis], ev)

	ev = InputEventJoypadButton.new()
	ev.button_index = JOY_BUTTON_1
	InputMap.action_erase_event("ui_cancel", ev)

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

func equip(action):
	var ev = InputEventAction.new()
	ev.action = action
	ev.pressed = true
	print("Sending " + ev.action)
	Input.parse_input_event(ev)

func _input(event):
	if event is InputEventJoypadButton:
		if not event.pressed:
			return
			
