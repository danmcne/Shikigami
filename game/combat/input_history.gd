class_name InputHistory
extends RefCounted
## The last few dozen frames of one fighter's input, stored screen-relative,
## and the queries that commands and normals need. Frames are absolute counts.
## Every query takes `after`: input on or before that frame was already spent
## on an earlier move and is ignored.

const CAPACITY := 40
## A press stays usable for this many frames.
const BUFFER := 5
## Buttons pressed within this many frames of each other count as together.
const CHORD := 3
const A := 1
const B := 2
const C := 4
const D := 8

var frame := -1
var _dirs := PackedInt32Array()
var _presses := PackedInt32Array()


func push(intent: Intent) -> void:
	frame += 1
	var y := 1 if intent.up else (-1 if intent.down else 0)
	_dirs.append(5 + intent.x + 3 * y)
	_presses.append(int(intent.light) * A | int(intent.heavy) * B
			| int(intent.special) * C | int(intent.spirit) * D)
	if _dirs.size() > CAPACITY:
		_dirs.remove_at(0)
		_presses.remove_at(0)


## Numpad direction held on frame `f`, relative to `facing`.
func direction(f: int, facing: int) -> int:
	var n := _dirs[_index(f)]
	return n if facing == 1 else n - 2 * ((n - 1) % 3 - 1)


func matches(cmd: Command, facing: int, after: int) -> bool:
	var end := chord(cmd.buttons, after) if cmd.buttons != 0 else _entered(after)
	if end < 0:
		return false
	if cmd.dirs.is_empty():
		return true
	if direction(end, facing) != cmd.dirs[-1]:
		return false
	var runs: Array[int] = []
	for f in range(maxi(end - cmd.window, _first(after)), end + 1):
		var d := direction(f, facing)
		if runs.is_empty() or runs[-1] != d:
			runs.append(d)
	var k := cmd.dirs.size() - 2
	for i in range(runs.size() - 2, -1, -1):
		if k < 0:
			break
		if runs[i] == cmd.dirs[k]:
			k -= 1
	return k < 0


## Latest frame on which every button in `mask` has been pressed, all within
## CHORD frames of each other and the latest within BUFFER; -1 if none.
func chord(mask: int, after: int) -> int:
	var first := maxi(_first(after), frame - BUFFER - CHORD + 2)
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
	if latest <= frame - BUFFER or latest - earliest >= CHORD:
		return -1
	return latest


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
