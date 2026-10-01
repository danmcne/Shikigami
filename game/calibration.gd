class_name Calibration
extends RefCounted
## Finds one player's input timing from the inputs the game actually asks for:
## two-button chords on one hand (throw, guard), a direction with a button
## across both hands (rush, second spirit), the projectile's roll, and quick
## deliberate sequences that must stay separate.
##
## Everything is measured in the same 60 Hz frames the game reads input in,
## with the player facing right. A direction held before its button is never
## late, because it is still held when the button lands; only a button that
## arrives before its direction needs slack, so only that gap is counted.
## Results:
##   chord window   between the widest "together" gap and the narrowest
##                  deliberate sequence (togetherness wins if they overlap);
##   motion window  the longest roll, plus a margin.

const REPS := 5
## A trial that takes longer than this between its first and last input
## starts over.
const GIVE_UP_FRAMES := 30
const MIN_WINDOW := 2
const MAX_WINDOW := 10
const MIN_MOTION := 12
const MAX_MOTION := 30
const MOTION_MARGIN := 4

enum Stage { CHOOSE, THROW, GUARD, TOWARD_SPECIAL, DOWN_SPIRIT, MOTION, SEQUENCE, DONE }
## The inputs each chord stage waits for.
const CHORDS := {
	Stage.THROW: ["light", "heavy"],
	Stage.GUARD: ["light", "special"],
	Stage.TOWARD_SPECIAL: ["toward", "special"],
	Stage.DOWN_SPIRIT: ["down", "spirit"],
}

var player := -1
var stage := Stage.CHOOSE
## Completed repetitions in the current stage.
var count := 0
var chord_gaps: Array[int] = []
var sequence_gaps: Array[int] = []
var motion_spans: Array[int] = []
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
	match stage:
		Stage.MOTION:
			_motion(events)
		Stage.SEQUENCE:
			_sequence(events)
		_:
			_chord(events)


func chord_window() -> int:
	return window_for(chord_gaps, sequence_gaps)


func motion_window() -> int:
	return clampi(motion_spans.max() + MOTION_MARGIN, MIN_MOTION, MAX_MOTION)


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
	if i.x == 1 and not i.down and not (_prev.x == 1 and not _prev.down):
		e.append("toward_alone")
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


## Down starts a roll; it completes when toward (without down) and special
## have both arrived, in either order.
func _motion(events: Array[String]) -> void:
	if "down" in events:
		_seen = {start = _frame}
	if not _seen.has("start"):
		return
	if _frame - _seen.start > 2 * GIVE_UP_FRAMES:
		_seen.clear()
		return
	if "toward_alone" in events and not _seen.has("toward"):
		_seen.toward = _frame
	if "special" in events and not _seen.has("button"):
		_seen.button = _frame
	if _seen.has("toward") and _seen.has("button"):
		motion_spans.append(maxi(_seen.toward, _seen.button) - _seen.start)
		chord_gaps.append(maxi(_seen.toward - _seen.button, 0))
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
