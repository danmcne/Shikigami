class_name CpuController
extends RefCounted
## A deliberately easy computer opponent. Like a player, it sees both fighters
## and answers with an Intent each frame. It knows nothing about particular
## characters: it chooses among the fighter's own normals and commands by
## whether they can reach, and enters them as a player would, frame by frame.
##
## Difficulty is a table of numbers. LEVELS lists them, easiest first.

const PRACTICE := {
	think = 45,           # frames between decisions
	aggression = 0.15,    # chance per decision to attack if something reaches
	guard_chance = 0.1,   # chance to guard a threat it sees
	guard_delay = 20,     # reaction time before that guard goes up
	low_read = 0.3,       # chance of guarding a low attack at the right height
	spirit_read = 0.2,    # chance of using spirit guard against a spirit
	escape_chance = 0.05, # chance to escape a throw
	summon_chance = 0.05, # chance per decision to summon a ready spirit
	jump_chance = 0.02,
}
const EASY := {
	think = 18, aggression = 0.4, guard_chance = 0.3, guard_delay = 8, low_read = 0.5, spirit_read = 0.5,
	escape_chance = 0.2, summon_chance = 0.15, jump_chance = 0.05,
}
const NORMAL := {
	think = 10, aggression = 0.6, guard_chance = 0.55, guard_delay = 5, low_read = 0.8, spirit_read = 0.8,
	escape_chance = 0.4, summon_chance = 0.25, jump_chance = 0.05,
}
const LEVELS := [["Practice", PRACTICE], ["Easy", EASY], ["Normal", NORMAL]]
## Normals by input; their move ids follow the engine's stance_button rule.
const NORMALS := {"A": &"stand_light", "B": &"stand_heavy", "2A": &"crouch_light", "2B": &"crouch_heavy"}

var p: Dictionary
var rng := RandomNumberGenerator.new()
var _queue: Array[Intent] = []
var _hold := Intent.new()
var _think := 0
var _guard_wait := -1
var _guard_frames := 0
var _guard_low := false
var _guard_chord := "G"
var _was_threatened := false
var _was_grabbed := false


func _init(params: Dictionary = EASY, seed_value := 0) -> void:
	p = params
	rng.seed = seed_value


func read(me: Fighter, them: Fighter) -> Intent:
	var grabbed := me.state == Fighter.State.GRABBED
	if grabbed and not _was_grabbed and rng.randf() < p.escape_chance:
		_queue = [Intent.from_numpad(5, me.facing, "AB")]
	_was_grabbed = grabbed

	if me.threatened and not _was_threatened and rng.randf() < p.guard_chance:
		_guard_wait = p.guard_delay
		var low := them.state == Fighter.State.MOVE and them.move.height == MoveDefinition.Height.LOW
		_guard_low = low if rng.randf() < p.low_read else not low
		_guard_chord = "P" if me.spirit_threatened and rng.randf() < p.spirit_read else "G"
	_was_threatened = me.threatened
	if _guard_wait >= 0:
		_guard_wait -= 1
		if _guard_wait < 0:
			_guard_frames = 24
	if _guard_frames > 0 and _queue.is_empty():
		_guard_frames -= 1
		return Intent.from_numpad(2 if _guard_low else 5, me.facing, _guard_chord)

	if _queue.is_empty():
		_think -= 1
		if _think <= 0:
			_think = p.think
			_decide(me, them)
	if not _queue.is_empty():
		return _queue.pop_front()
	return _hold


## The keys for a command pattern, one frame per direction, buttons on the last.
static func inputs_for(pattern: String, facing: int) -> Array[Intent]:
	var dirs: Array[int] = []
	var buttons := ""
	for ch in pattern:
		if ch >= "1" and ch <= "9":
			dirs.append(int(ch))
		else:
			buttons += ch
	if dirs.is_empty():
		dirs.append(5)
	var out: Array[Intent] = []
	for k in dirs.size():
		out.append(Intent.from_numpad(dirs[k], facing, buttons if k == dirs.size() - 1 else ""))
	return out


func _decide(me: Fighter, them: Fighter) -> void:
	_hold = Intent.new()
	if not me.actionable():
		return
	var gap := absf(them.position.x - me.position.x) - them.definition.stand_hurtbox.size.x / 2.0
	for slot in me.spirits.size():
		if me.cooldowns[slot] == 0 and rng.randf() < p.summon_chance:
			_queue = inputs_for(Fighter.SUMMON_COMMANDS[slot], me.facing)
			return
	if rng.randf() < p.aggression:
		var options := _reachable(me.definition, gap)
		if not options.is_empty():
			_queue = inputs_for(options[rng.randi() % options.size()], me.facing)
			return
	if rng.randf() < p.jump_chance:
		_queue = inputs_for("9", me.facing)
		return
	var wanted := rng.randf_range(40.0, 200.0)
	if gap > wanted + 20.0:
		_hold.x = me.facing
	elif gap < wanted - 40.0:
		_hold.x = -me.facing


## Input patterns for every normal or command whose move can reach `gap`.
func _reachable(d: FighterDefinition, gap: float) -> Array[String]:
	var options: Array[String] = []
	var by_pattern := NORMALS.duplicate()
	by_pattern.merge(d.commands)
	for pattern in by_pattern:
		var m: MoveDefinition = d.moves.get(by_pattern[pattern])
		if m and _reach(m) >= gap:
			options.append(pattern)
	return options


static func _reach(m: MoveDefinition) -> float:
	if m.spawn:
		return INF
	if m.hitboxes.is_empty():
		return -1.0
	var reach := -INF
	for box in m.hitboxes:
		reach = maxf(reach, box.end.x)
	if m.motion.y == 0.0:
		# A slide decelerating at Fighter.SLIDE_DECEL covers v²/(2·decel).
		reach += m.motion.x * m.motion.x / (2.0 * Fighter.SLIDE_DECEL)
	return reach
