class_name Calibration
extends RefCounted
## Finds one player's chord window from the inputs the game actually asks
## for: chords on one hand (throw, guard, spirit guard), a direction with a
## button across both hands (rush, second spirit), and quick deliberate
## sequences that must stay separate.
##
## Everything is measured in the same 60 Hz frames the game reads input in,
## with the player facing right. A direction held before its button is never
## late, because it is still held when the button lands; only a button that
## arrives before its direction needs slack, so only that gap is counted.
## The window is set between the widest "together" gap and the narrowest
## deliberate sequence; togetherness wins if they overlap.

const REPS := 5
## A trial that takes longer than this between its first and last input
## starts over.
const GIVE_UP_FRAMES := 30
const MIN_WINDOW := 2
const MAX_WINDOW := 10

enum Stage { CHOOSE, THROW, GUARD, SPIRIT_GUARD, TOWARD_SPECIAL, DOWN_SPIRIT, SEQUENCE, DONE }
## The inputs each chord stage waits for. Where a direction is involved, it
## comes first and the button second.
const CHORDS := {
	Stage.THROW: ["light", "heavy"],
	Stage.GUARD: ["light", "special"],
	Stage.SPIRIT_GUARD: ["light", "special", "spirit"],
	Stage.TOWARD_SPECIAL: ["toward", "special"],
	Stage.DOWN_SPIRIT: ["down", "spirit"],
}
const STEPS := 6

var player := -1
var stage := Stage.CHOOSE
## Completed repetitions in the current stage.
var count := 0
var chord_gaps: Array[int] = []
var sequence_gaps: Array[int] = []
var _seen := {}
var _frame := 0
var _prev := Intent.new()


## Feeds one frame of every player's input.
func observe(intents: Array[Intent]) -> void:
	_frame += 1
	if stage == Stage.CHOOSE:
		for k in intents.size():
			if intents[k].light:
				player = k
				_advance()
				_prev = intents[k]
				return
		return
	if stage == Stage.DONE:
		return
	var i := intents[player]
	var events := _events(i)
	_prev = i
	if stage == Stage.SEQUENCE:
		_sequence(events)
	else:
		_chord(events)


func chord_window() -> int:
	return window_for(chord_gaps, sequence_gaps)


func overlapping() -> bool:
	return not sequence_gaps.is_empty() and chord_gaps.max() >= sequence_gaps.min()


## The smallest window above every "together" gap, placed midway toward the
## narrowest sequence when the two do not overlap.
static func window_for(together: Array[int], sequence: Array[int]) -> int:
	var widest: int = together.max()
	var w := widest + 1
	if not sequence.is_empty() and widest < sequence.min():
		w = maxi(ceili((widest + sequence.min()) / 2.0), widest + 1)
	return clampi(w, MIN_WINDOW, MAX_WINDOW)


## Inputs that began on this frame.
func _events(i: Intent) -> Array[String]:
	var e: Array[String] = []
	for verb in ["light", "heavy", "special", "spirit"]:
		if i.get(verb):
			e.append(verb)
	if i.x == 1 and _prev.x != 1:
		e.append("toward")
	if i.down and not _prev.down:
		e.append("down")
	return e


func _chord(events: Array[String]) -> void:
	var wanted: Array = CHORDS[stage]
	if not _seen.is_empty() and _frame - _seen.values().min() > GIVE_UP_FRAMES:
		_seen.clear()
	for e in events:
		if e in wanted and not _seen.has(e):
			_seen[e] = _frame
	if _seen.size() == wanted.size():
		var gap: int = _seen.values().max() - _seen.values().min()
		for direction in ["toward", "down"]:
			if _seen.has(direction):
				gap = maxi(_seen[direction] - _seen[wanted[1]], 0)
		chord_gaps.append(gap)
		_seen.clear()
		_rep_done()


func _sequence(events: Array[String]) -> void:
	for e in events:
		if e != "light" and e != "heavy":
			continue
		if _seen.is_empty() or _frame - _seen.frame > GIVE_UP_FRAMES or e == _seen.button:
			_seen = {frame = _frame, button = e}
			continue
		sequence_gaps.append(_frame - _seen.frame)
		_seen.clear()
		_rep_done()


func _rep_done() -> void:
	count += 1
	if count >= REPS:
		_advance()


func _advance() -> void:
	stage = (stage + 1) as Stage
	count = 0
	_seen.clear()
