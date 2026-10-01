class_name Calibration
extends RefCounted
## Finds one player's chord window: the largest gap, in game frames, between
## two presses that should still count as "together".
##
## The player presses light and heavy together several times, then one after
## the other as quickly as they deliberately can. Gaps are measured in the
## same 60 Hz frames the game reads input in. The window is set between the
## widest "together" and the narrowest "quick sequence"; if the two overlap,
## togetherness wins and the overlap is reported.

const TRIALS := 8
## A second press later than this restarts the trial.
const GIVE_UP_FRAMES := 24
const MIN_WINDOW := 2
const MAX_WINDOW := 10

enum Stage { TOGETHER, SEQUENCE, DONE }

var together: Array[int] = []
var sequence: Array[int] = []
## Which player is calibrating; fixed by the first press.
var player := -1
var _first_frame := -1
var _first_button := ""
var _frame := 0


func stage() -> Stage:
	if together.size() < TRIALS:
		return Stage.TOGETHER
	if sequence.size() < TRIALS:
		return Stage.SEQUENCE
	return Stage.DONE


## Feeds one frame of both players' input.
func observe(intents: Array[Intent]) -> void:
	_frame += 1
	if stage() == Stage.DONE:
		return
	for index in intents.size():
		if player >= 0 and index != player:
			continue
		var i := intents[index]
		for button in ["light", "heavy"]:
			if i.get(button):
				player = index
				_press(button)


func window() -> int:
	return window_for(together, sequence)


func overlapping() -> bool:
	return not sequence.is_empty() and together.max() >= sequence.min()


static func window_for(t: Array[int], s: Array[int]) -> int:
	var widest: int = t.max()
	var w := widest + 1
	if not s.is_empty() and widest < s.min():
		w = ceili((widest + s.min()) / 2.0)
		w = maxi(w, widest + 1)
	return clampi(w, MIN_WINDOW, MAX_WINDOW)


func _press(button: String) -> void:
	if _first_frame < 0 or _frame - _first_frame > GIVE_UP_FRAMES or button == _first_button:
		_first_frame = _frame
		_first_button = button
		return
	var gap := _frame - _first_frame
	_first_frame = -1
	_first_button = ""
	if stage() == Stage.TOGETHER:
		together.append(gap)
	else:
		sequence.append(gap)
