class_name Intent
extends RefCounted
## What a controller wants on one frame. Human input and CPU logic both reduce
## to this, so a fighter never knows which is driving it.

## Screen-relative horizontal direction: -1, 0 or +1.
var x: int = 0
var up: bool = false
var down: bool = false
## Held, not pressed: guarding lasts as long as the button is down.
var guard: bool = false
## Button presses (edges, not holds) on this frame. In command notation these
## are A, B, C and D.
var light: bool = false
var heavy: bool = false
var special: bool = false
var spirit: bool = false


## An Intent from numpad notation relative to `facing`, pressing `buttons`
## (any of "ABCD") and holding guard if "G" is among them.
static func from_numpad(n: int, facing: int, buttons := "") -> Intent:
	var i := Intent.new()
	i.x = ((n - 1) % 3 - 1) * facing
	i.up = n >= 7
	i.down = n <= 3
	i.light = "A" in buttons
	i.heavy = "B" in buttons
	i.special = "C" in buttons
	i.spirit = "D" in buttons
	i.guard = "G" in buttons
	return i
