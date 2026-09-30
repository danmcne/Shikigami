class_name InputSetup
extends RefCounted
## All bindings, registered in code so they live in one readable place.
##
## The four buttons form a diamond, identical on keyboard and gamepad:
##
##            heavy                 I            8           Y / Triangle
##     light        special      J     L      4     6     X / Square   B / Circle
##            spirit                K            2           A / Cross
##
##                             player 1     player 2        gamepad
##
## Player 1 moves with WASD, player 2 with the arrow keys. Keys are physical
## positions, so non-US layouts keep the same shape. Gamepads: first pad is
## player 1, second is player 2; d-pad and left stick both move.

const KEYS := {
	"p1_": {left = [KEY_A], right = [KEY_D], up = [KEY_W], down = [KEY_S],
			light = [KEY_J], heavy = [KEY_I], special = [KEY_L], spirit = [KEY_K]},
	"p2_": {left = [KEY_LEFT], right = [KEY_RIGHT], up = [KEY_UP], down = [KEY_DOWN],
			light = [KEY_KP_4], heavy = [KEY_KP_8], special = [KEY_KP_6], spirit = [KEY_KP_2]},
}
const PAD_BUTTONS := {
	left = JOY_BUTTON_DPAD_LEFT, right = JOY_BUTTON_DPAD_RIGHT,
	up = JOY_BUTTON_DPAD_UP, down = JOY_BUTTON_DPAD_DOWN,
	light = JOY_BUTTON_X, heavy = JOY_BUTTON_Y, special = JOY_BUTTON_B, spirit = JOY_BUTTON_A,
}
const PAD_AXES := {
	left = [JOY_AXIS_LEFT_X, -1.0], right = [JOY_AXIS_LEFT_X, 1.0],
	up = [JOY_AXIS_LEFT_Y, -1.0], down = [JOY_AXIS_LEFT_Y, 1.0],
}


static func register() -> void:
	var device := 0
	for prefix in KEYS:
		for verb in KEYS[prefix]:
			var action: String = prefix + verb
			if InputMap.has_action(action):
				continue
			InputMap.add_action(action, 0.5)
			for code in KEYS[prefix][verb]:
				var k := InputEventKey.new()
				k.physical_keycode = code
				InputMap.action_add_event(action, k)
			var b := InputEventJoypadButton.new()
			b.device = device
			b.button_index = PAD_BUTTONS[verb]
			InputMap.action_add_event(action, b)
			if verb in PAD_AXES:
				var m := InputEventJoypadMotion.new()
				m.device = device
				m.axis = PAD_AXES[verb][0]
				m.axis_value = PAD_AXES[verb][1]
				InputMap.action_add_event(action, m)
		device += 1
