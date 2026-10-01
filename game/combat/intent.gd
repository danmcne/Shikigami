class_name Intent
extends RefCounted
## What a controller wants on one frame. Human input and CPU logic both reduce
## to this, so a fighter never knows which is driving it.

## Button bits, also used in command notation as A, B, C and D.
const A := 1
const B := 2
const C := 4
const D := 8
## Held chords: guard is light + special; spirit guard adds the spirit button
## and also stops spirits' attacks, which plain guard does not.
const GUARD := A | C
const SPIRIT_GUARD := A | C | D

## Screen-relative horizontal direction: -1, 0 or +1.
var x: int = 0
var up: bool = false
var down: bool = false
## Button presses (edges) on this frame.
var light: bool = false
var heavy: bool = false
var special: bool = false
var spirit: bool = false
## Buttons currently held down (a pressed button is also held).
var held: int = 0


func pressed_mask() -> int:
	return int(light) * A | int(heavy) * B | int(special) * C | int(spirit) * D


## An Intent from numpad notation relative to `facing`. `buttons` are pressed
## this frame (any of "ABCD"); "G" holds the guard chord and "P" the spirit
## guard chord, without pressing them.
static func from_numpad(n: int, facing: int, buttons := "") -> Intent:
	var i: Intent = new()
	i.x = ((n - 1) % 3 - 1) * facing
	i.up = n >= 7
	i.down = n <= 3
	i.light = "A" in buttons
	i.heavy = "B" in buttons
	i.special = "C" in buttons
	i.spirit = "D" in buttons
	i.held = i.pressed_mask() | (GUARD if "G" in buttons else 0) | (SPIRIT_GUARD if "P" in buttons else 0)
	return i
