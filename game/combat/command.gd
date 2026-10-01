class_name Command
extends RefCounted
## A command pattern: directions in numpad notation relative to facing, then
## buttons.
##
##     7 8 9       6 is toward the opponent, 4 away from them,
##     4 5 6       2 down, 5 neutral.
##     1 2 3       Buttons: A light, B heavy, C special, D spirit.
##
## "236C"  down, down-forward, forward, then C
## "6C"    C while holding forward
## "C"     C in any direction
## "AB"    A and B together
## "656"   tap forward twice (no button)
##
## Directions must appear in order within a window (InputHistory's
## MOTION_WINDOW for commands with buttons, TAP_WINDOW for those without) but
## need not be contiguous, and a diagonal between two other directions may be
## skipped. The last one must be held when the buttons are pressed or, for a
## command without buttons, must have just been entered. When several commands
## match, one with buttons beats one without, then more directions beat fewer,
## then more buttons beat fewer.

const TAP_WINDOW := 12

var pattern: String
var dirs := PackedInt32Array()
var buttons := 0
## For commands without buttons only.
var window := TAP_WINDOW
var move: StringName


static func parse(text: String, move_id: StringName) -> Command:
	var c: Command = new()
	c.pattern = text
	c.move = move_id
	for ch in text:
		if ch >= "1" and ch <= "9":
			c.dirs.append(int(ch))
		else:
			var bit := "ABCD".find(ch)
			assert(bit >= 0, "bad character '%s' in command '%s'" % [ch, text])
			c.buttons |= 1 << bit
	return c


func rank() -> int:
	var count := 0
	for bit in 4:
		count += (buttons >> bit) & 1
	return (1000 if buttons != 0 else 0) + 10 * dirs.size() + count
