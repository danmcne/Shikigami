class_name InputHistory
extends RefCounted
## The last few dozen frames of one fighter's input, stored screen-relative,
## and the queries that commands and normals need. Frames are absolute counts.
## Every query takes `after`: input on or before that frame was already spent
## on an earlier move and is ignored.

const CAPACITY := 40
## A press stays usable for this many frames.
const BUFFER := 5
const DEFAULT_CHORD := 3
const A := Intent.A
const B := Intent.B
const C := Intent.C
const D := Intent.D
## Frames a multi-direction pattern may span. The game's fighters use only
## single directions and double taps; the grammar keeps general support.
const MOTION_WINDOW := 18

## Presses fewer than this many frames apart count as together, and a
## direction this close to a button press counts as held with it. Set per
## player by calibration.
var chord := DEFAULT_CHORD
var frame := -1
var _dirs := PackedInt32Array()
var _presses := PackedInt32Array()
var _held := PackedInt32Array()


func push(intent: Intent) -> void:
	frame += 1
	var y := 1 if intent.up else (-1 if intent.down else 0)
	_dirs.append(5 + intent.x + 3 * y)
	_presses.append(intent.pressed_mask())
	_held.append(intent.held | intent.pressed_mask())
	if _dirs.size() > CAPACITY:
		_dirs.remove_at(0)
		_presses.remove_at(0)
		_held.remove_at(0)


## Numpad direction held on frame `f`, relative to `facing`.
func direction(f: int, facing: int) -> int:
	var n := _dirs[_index(f)]
	return n if facing == 1 else n - 2 * ((n - 1) % 3 - 1)


func matches(cmd: Command, facing: int, after: int) -> bool:
	var end := pressed(cmd.buttons, after) if cmd.buttons != 0 else _entered(after)
	if end < 0:
		return false
	if cmd.dirs.is_empty():
		return true
	# The final direction may be entered slightly before or after the buttons.
	var slop := chord - 1 if cmd.buttons != 0 else 0
	var held_at := -1
	for f in range(maxi(end - slop, _first(after)), mini(end + slop, frame) + 1):
		if direction(f, facing) == cmd.dirs[-1]:
			held_at = f
	if held_at < 0:
		return false
	var window := cmd.window if cmd.buttons == 0 else MOTION_WINDOW
	var runs: Array[int] = []
	for f in range(maxi(held_at - window, _first(after)), held_at + 1):
		var d := direction(f, facing)
		if runs.is_empty() or runs[-1] != d:
			runs.append(d)
	# Walk back through the pattern. A diagonal between two other directions
	# may be skipped: rolling from down to toward on a keyboard does not always
	# register the down-toward in between.
	var k := cmd.dirs.size() - 2
	for i in range(runs.size() - 2, -1, -1):
		if k < 0:
			break
		if runs[i] == cmd.dirs[k]:
			k -= 1
		elif k > 0 and _diagonal(cmd.dirs[k]) and runs[i] == cmd.dirs[k - 1]:
			k -= 2
	return k < 0


## Latest frame on which every button in `mask` has been pressed, all fewer
## than `chord` frames apart and the latest within BUFFER; -1 if none.
func pressed(mask: int, after: int) -> int:
	var first := maxi(_first(after), frame - BUFFER - chord + 2)
	var latest := -1
	var earliest := frame + 1
	for bit in 4:
		if mask & (1 << bit) == 0:
			continue
		var f := _last_press(1 << bit, first)
		if f < 0:
			return -1
		latest = maxi(latest, f)
		earliest = mini(earliest, f)
	if latest <= frame - BUFFER or latest - earliest >= chord:
		return -1
	return latest


## Latest fresh frame on which a button in `mask` was pressed while all of
## `mask` was held. Unlike pressed(), the others may have been held for any
## length of time. Used where no sequence of presses can be meant, such as
## escaping a throw while still holding guard.
func pressed_while_holding(mask: int, after: int) -> int:
	for f in range(frame, maxi(_first(after), frame - BUFFER + 1) - 1, -1):
		var i := _index(f)
		if _presses[i] & mask and (_held[i] & mask) == mask:
			return f
	return -1


static func _diagonal(n: int) -> bool:
	return n in [1, 3, 7, 9]


## Frame on which the currently held direction was entered, if within BUFFER
## and after `after`; -1 otherwise.
func _entered(after: int) -> int:
	var recorded := frame - _dirs.size() + 1
	var held := _dirs[_index(frame)]
	var f := frame
	while f > recorded and _dirs[_index(f - 1)] == held:
		f -= 1
	if f == recorded or f <= after or f <= frame - BUFFER:
		return -1
	return f


func _last_press(bit: int, first: int) -> int:
	for f in range(frame, first - 1, -1):
		if _presses[_index(f)] & bit:
			return f
	return -1


func _first(after: int) -> int:
	return maxi(frame - _dirs.size() + 1, after + 1)


func _index(f: int) -> int:
	return _dirs.size() - 1 - (frame - f)
