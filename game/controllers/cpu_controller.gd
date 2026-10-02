class_name CpuController
extends RefCounted
## The computer opponent. Like a player, it sees both fighters and answers
## with an Intent each frame. It knows nothing about particular characters:
## it reads the fighter's own moves (reach, start-up, recharge, effects) and
## enters them as a player would, frame by frame.
##
## Every few frames it decides, in this order: anti-air a nearby jumper;
## punish a move still recovering within reach; use a utility special (heal
## when hurt and far, a counter stance against an attack, a trap at range);
## summon a ready spirit; attack with something that reaches; jump; or adjust
## its distance. Between decisions it reacts to threats by guarding, at a
## height and against fighter or spirit it may or may not read correctly.
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
	punish = 0.0,         # chance to punish a recovering move in reach
	anti_air = 0.0,       # chance to anti-air a nearby jumper
	utility = 0.05,       # chance to use a heal, counter or trap when it fits
}
const EASY := {
	think = 18, aggression = 0.4, guard_chance = 0.3, guard_delay = 8, low_read = 0.5, spirit_read = 0.5,
	escape_chance = 0.2, summon_chance = 0.15, jump_chance = 0.05,
	punish = 0.2, anti_air = 0.2, utility = 0.15,
}
const NORMAL := {
	think = 10, aggression = 0.6, guard_chance = 0.55, guard_delay = 5, low_read = 0.8, spirit_read = 0.8,
	escape_chance = 0.4, summon_chance = 0.25, jump_chance = 0.05,
	punish = 0.5, anti_air = 0.5, utility = 0.3,
}
const HARD := {
	think = 6, aggression = 0.65, guard_chance = 0.8, guard_delay = 3, low_read = 0.9, spirit_read = 0.9,
	escape_chance = 0.6, summon_chance = 0.3, jump_chance = 0.03,
	punish = 0.85, anti_air = 0.75, utility = 0.4,
}
const LEVELS := [["Practice", PRACTICE], ["Easy", EASY], ["Normal", NORMAL], ["Hard", HARD]]
## Healing is considered below this share of health.
const HEAL_BELOW := 0.6
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
		var low := them.threatens_low()
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
	if them.airborne and gap < 170.0 and rng.randf() < p.anti_air and _ready(me, "2C"):
		_queue = inputs_for("2C", me.facing)
		return
	if them.state == Fighter.State.MOVE and them.state_frame >= them.move.startup + them.move.active \
			and rng.randf() < p.punish:
		var punisher := _fastest(me, gap, them.move.total_frames() - them.state_frame)
		if punisher != "":
			_queue = inputs_for(punisher, me.facing)
			return
	var utility := _utility(me, them, gap)
	if utility != "" and rng.randf() < p.utility:
		_queue = inputs_for(utility, me.facing)
		return
	for slot in me.spirits.size():
		if me.cooldowns[slot] == 0 and rng.randf() < p.summon_chance:
			_queue = inputs_for(Fighter.SUMMON_COMMANDS[slot], me.facing)
			return
	if rng.randf() < p.aggression:
		var options := _reachable(me, gap)
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


## Input patterns for every ready normal or command whose move can reach `gap`.
func _reachable(me: Fighter, gap: float) -> Array[String]:
	var options: Array[String] = []
	for pattern in _patterns(me.definition):
		var m := _move_for(me.definition, pattern)
		if m and _reach(m) >= gap and _ready(me, pattern):
			options.append(pattern)
	return options


## The quickest ready move that reaches `gap` and becomes active in fewer
## than `frames` frames; "" if none.
func _fastest(me: Fighter, gap: float, frames: int) -> String:
	var best := ""
	var best_startup := frames
	for pattern in _patterns(me.definition):
		var m := _move_for(me.definition, pattern)
		if m and m.spawn == null and _reach(m) >= gap and m.startup < best_startup and _ready(me, pattern):
			best = pattern
			best_startup = m.startup
	return best


## A special that is not an attack but fits the moment, or "".
func _utility(me: Fighter, them: Fighter, gap: float) -> String:
	for pattern in me.definition.commands:
		var m := _move_for(me.definition, pattern)
		if not _ready(me, pattern):
			continue
		if m.heal > 0 and gap > 220.0 and me.health < me.definition.max_health * HEAL_BELOW:
			return pattern
		if m.counter and them.threatening() and gap < 160.0:
			return pattern
		if m.spawn and m.spawn.motion == Vector2.ZERO and gap > 200.0:
			return pattern
	return ""


func _patterns(d: FighterDefinition) -> Array:
	return NORMALS.keys() + d.commands.keys()


func _move_for(d: FighterDefinition, pattern: String) -> MoveDefinition:
	var id: StringName = NORMALS.get(pattern, d.commands.get(pattern, &""))
	return d.moves.get(id)


## Whether the move behind `pattern` exists and is not recharging.
func _ready(me: Fighter, pattern: String) -> bool:
	var m := _move_for(me.definition, pattern)
	return m != null and me.move_cooldowns.get(m.id, 0) == 0 \
			and not (m.spawn and m.spawn in me.live_spawns)


static func _reach(m: MoveDefinition) -> float:
	# A projectile travels, and a teleport arrives beside the opponent wherever
	# they are: either reaches any distance.
	if m.spawn or m.teleport_frame >= 0:
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
