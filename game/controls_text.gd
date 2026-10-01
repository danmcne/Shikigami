class_name ControlsText
extends RefCounted
## Turns command patterns into the keys a player actually presses, using the
## bindings in InputSetup and the fighter's current facing.
##   "236C" facing right, player 1  ->  "S, S+D, D + L"
## Command notation stays the data format; players only ever see keys.

const BUTTON_VERBS := {"A": "light", "B": "heavy", "C": "special", "D": "spirit", "G": "guard"}


static func describe(pattern: String, facing: int, prefix: String) -> String:
	var dirs: Array[String] = []
	var buttons: Array[String] = []
	for ch in pattern:
		if ch >= "1" and ch <= "9":
			dirs.append(direction(int(ch), facing, prefix))
		else:
			buttons.append(key(prefix, BUTTON_VERBS[ch]))
	var text := ", ".join(dirs)
	if not buttons.is_empty():
		text += (" + " if text != "" else "") + "+".join(buttons)
	return text


## Keys for a numpad direction relative to facing; 5 (neutral) reads "release".
static func direction(n: int, facing: int, prefix: String) -> String:
	var x := ((n - 1) % 3 - 1) * facing
	var parts: Array[String] = []
	if n >= 7:
		parts.append(key(prefix, "up"))
	elif n <= 3:
		parts.append(key(prefix, "down"))
	if x != 0:
		parts.append(key(prefix, "right" if x > 0 else "left"))
	return "+".join(parts) if not parts.is_empty() else "release"


static func key(prefix: String, verb: String) -> String:
	var code: int = InputSetup.KEYS[prefix][verb][0]
	return OS.get_keycode_string(code).replace("Kp ", "Num ")
