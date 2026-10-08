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
	utility = 0.05,       # chance to use a counter or trap when it fits
	heal_chance = 0.5,    # chance to heal at a safe moment when hurt
	# Monsters read the same table: multipliers on how long they take to turn
	# round and how long they rest between attacks.
	monster_turn = 3.0,
	monster_rest = 2.0,
	monster_spread = 1.5,  # wider gaps in a monster's volleys
	monster_seal = 2.0,    # longer to seal a beaten giant
	monster_windup = 1.5,  # longer start-up (telegraph) on its attacks
	monster_speed = 0.7,   # slower travel of what it sends at you
}
const EASY := {
	think = 18, aggression = 0.4, guard_chance = 0.3, guard_delay = 8, low_read = 0.5, spirit_read = 0.5,
	escape_chance = 0.2, summon_chance = 0.15, jump_chance = 0.05,
	punish = 0.2, anti_air = 0.2, utility = 0.15, heal_chance = 0.6, monster_turn = 2.0, monster_rest = 1.6,
	monster_spread = 1.35, monster_seal = 1.5, monster_windup = 1.3, monster_speed = 0.8,
}
const NORMAL := {
	think = 10, aggression = 0.6, guard_chance = 0.55, guard_delay = 5, low_read = 0.8, spirit_read = 0.8,
	escape_chance = 0.4, summon_chance = 0.25, jump_chance = 0.05,
	punish = 0.5, anti_air = 0.5, utility = 0.3, heal_chance = 0.7, monster_turn = 1.0, monster_rest = 1.0,
	monster_spread = 1.0, monster_seal = 1.0, monster_windup = 1.0, monster_speed = 1.0,
}
const HARD := {
	think = 6, aggression = 0.65, guard_chance = 0.8, guard_delay = 3, low_read = 0.9, spirit_read = 0.9,
	escape_chance = 0.6, summon_chance = 0.3, jump_chance = 0.03,
	punish = 0.85, anti_air = 0.75, utility = 0.4, heal_chance = 0.8, monster_turn = 0.85, monster_rest = 0.85,
	monster_spread = 0.95, monster_seal = 1.0, monster_windup = 1.0, monster_speed = 1.0,
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


## The last few moves chosen: a move used recently is less likely to be chosen
## again, so no one move is leaned on whatever the opponent does.
var _recent: Array[String] = []
const MEMORY := 6


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

	# In the air against a flying giant: throw what can be thrown from there,
	# near the top of the jump.
	if _queue.is_empty() and me.state == Fighter.State.JUMP and them is Monster and absf(me.velocity.y) < 3.0:
		var thrown := _air_throw(me)
		if thrown != "":
			_use(thrown, me)
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
	if them is Monster and _against_giant(me, them as Monster):
		return
	var heal := _heal_pattern(me)
	if heal != "" and _safe_to_heal(them, gap, _move_for(me.definition, heal)) and rng.randf() < p.heal_chance:
		_queue = inputs_for(heal, me.facing)
		return
	if them.airborne and gap < 170.0 and rng.randf() < p.anti_air and _ready(me, "2C") and _fresh("2C"):
		_use("2C", me)
		return
	if them.state == Fighter.State.MOVE and them.state_frame >= them.move.startup + them.move.active \
			and rng.randf() < p.punish:
		var punisher := _fastest(me, gap, them.move.total_frames() - them.state_frame)
		if punisher != "" and _fresh(punisher):
			_use(punisher, me)
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
			_use(_varied(options), me)
			return
	if rng.randf() < p.jump_chance:
		_queue = inputs_for("9", me.facing)
		return
	# Each fighter keeps to the distance at which it does its damage.
	var at: float = me.definition.preferred_gap if me.definition.preferred_gap > 0.0 else 80.0
	var wanted := rng.randf_range(maxf(20.0, at - 50.0), at + 50.0)
	if gap > wanted + 20.0:
		_hold.x = me.facing
	elif gap < wanted - 40.0:
		_hold.x = -me.facing


## Against a giant: seal it when beaten (go to its open core and perform the
## finisher); under a flying giant, strike up at it, or jump to throw at it.
## True if this decided what to do.
func _against_giant(me: Fighter, giant: Monster) -> bool:
	if giant.state == Fighter.State.DAZED:
		var core_x := giant.to_world(giant.monster.core).get_center().x
		if absf(core_x - me.position.x) < 70.0:
			_use(Fighter.FINISHER_COMMAND, me)
		else:
			_hold.x = signf(core_x - me.position.x)
		return true
	if giant.flying() and giant.position.y < -150.0:
		var across := absf(giant.position.x - me.position.x)
		if across < 90.0 and _ready(me, "2C") and rng.randf() < 0.5:
			_use("2C", me)
			return true
		if _air_throw(me) != "" and rng.randf() < 0.5:
			_use("9" if across > 60.0 else "8", me)
			return true
	# Go for the nearest part that can be struck (not the giant's middle,
	# which may be empty air); if none can be, keep clear and wait.
	var boxes := giant.hurtboxes()
	if boxes.is_empty():
		var away := signf(me.position.x - giant.position.x)
		if absf(me.position.x - giant.position.x) < 260.0:
			_hold.x = away if away != 0.0 else 1.0
		return true
	var nearest: Rect2 = boxes[0]
	var nearest_gap := INF
	for box in boxes:
		var g := maxf(maxf(box.position.x - me.position.x, me.position.x - box.end.x), 0.0)
		if g < nearest_gap:
			nearest_gap = g
			nearest = box
	var toward := signf(nearest.get_center().x - me.position.x)
	var options := _reachable(me, nearest_gap)
	if not options.is_empty() and toward == me.facing and rng.randf() < p.aggression:
		_use(_varied(options), me)
	elif nearest_gap > 30.0 or toward != me.facing:
		_hold.x = toward
	return true


## A ready special that can be thrown from the air, or "".
func _air_throw(me: Fighter) -> String:
	for pattern in me.definition.commands:
		var m := _move_for(me.definition, pattern)
		if m and m.air and m.spawn and _ready(me, pattern):
			return pattern
	return ""


func _use(pattern: String, me: Fighter) -> void:
	_queue = inputs_for(pattern, me.facing)
	_recent.append(pattern)
	if _recent.size() > MEMORY:
		_recent.pop_front()


## Whether a reflex (anti-air, punish) may fire again: less likely the more it
## has been used of late.
func _fresh(pattern: String) -> bool:
	return rng.randf() < 1.0 / (1.0 + 0.6 * _recent.count(pattern))


## One of `options`, weighted against those used recently.
func _varied(options: Array[String]) -> String:
	var weights: Array[float] = []
	var total := 0.0
	for o in options:
		var w := 1.0 / pow(1.0 + _recent.count(o), 2.0)
		weights.append(w)
		total += w
	var roll := rng.randf() * total
	for k in options.size():
		roll -= weights[k]
		if roll <= 0.0:
			return options[k]
	return options[-1]


## Input patterns for every ready normal or command whose move can reach `gap`.
func _reachable(me: Fighter, gap: float) -> Array[String]:
	var options: Array[String] = []
	for pattern in _patterns(me.definition):
		var m := _move_for(me.definition, pattern)
		if m and _reach(m) >= gap and _ready(me, pattern):
			options.append(pattern)
	return options


## A ready move that reaches `gap` and becomes active in fewer than `frames`
## frames, chosen among all that would (weighted by damage, and against those
## used recently), not always the quickest; "" if none.
func _fastest(me: Fighter, gap: float, frames: int) -> String:
	var options: Array[String] = []
	var weights: Array[float] = []
	var total := 0.0
	for pattern in _patterns(me.definition):
		var m := _move_for(me.definition, pattern)
		if m and m.spawn == null and _reach(m) >= gap and m.startup < frames and _ready(me, pattern):
			var w := float(maxi(m.damage, 1)) / pow(1.0 + _recent.count(pattern), 2.0)
			options.append(pattern)
			weights.append(w)
			total += w
	if options.is_empty():
		return ""
	var roll := rng.randf() * total
	for k in options.size():
		roll -= weights[k]
		if roll <= 0.0:
			return options[k]
	return options[-1]


## A special that is not an attack but fits the moment, or "".
func _utility(me: Fighter, them: Fighter, gap: float) -> String:
	for pattern in me.definition.commands:
		var m := _move_for(me.definition, pattern)
		if not _ready(me, pattern):
			continue
		if m.counter and them.threatening() and gap < 160.0:
			return pattern
		if m.spawn and m.spawn.motion == Vector2.ZERO and gap > 200.0:
			return pattern
	return ""


## A ready healing special if this fighter is hurt enough to want it, or "".
func _heal_pattern(me: Fighter) -> String:
	if me.health >= me.definition.max_health * HEAL_BELOW:
		return ""
	for pattern in me.definition.commands:
		var m := _move_for(me.definition, pattern)
		if m.heal > 0 and _ready(me, pattern):
			return pattern
	return ""


## A moment when the exposed `heal` is unlikely to be punished: the opponent
## is lying down at some distance, still recovering for longer than the heal
## takes, or far away with no projectile ready.
func _safe_to_heal(them: Fighter, gap: float, heal: MoveDefinition) -> bool:
	if them.state == Fighter.State.KNOCKDOWN and not them.airborne and gap > 120.0:
		return true
	if them.state == Fighter.State.MOVE and them.move.total_frames() - them.state_frame > heal.startup:
		return true
	return gap > 260.0 and not _projectile_ready(them)


func _projectile_ready(them: Fighter) -> bool:
	for pattern in them.definition.commands:
		var m := _move_for(them.definition, pattern)
		if m.spawn and m.spawn.motion != Vector2.ZERO and _ready(them, pattern):
			return true
	return false


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


## The top of a standing body, for judging what a move can reach.
const BODY_TOP := -165.0


static func _reach(m: MoveDefinition) -> float:
	# A projectile travels, and a teleport arrives beside the opponent wherever
	# they are: either reaches any distance.
	if m.spawn or m.teleport_frame >= 0:
		return INF
	if m.hitboxes.is_empty():
		return -1.0
	# Only boxes at a standing body's height count: a swing traced from a
	# weapon passes through boxes far overhead that would reach no one, as
	# does an anti-air's.
	var reach := -INF
	for box in m.hitboxes:
		if box.end.y > BODY_TOP and box.position.y < 0.0:
			reach = maxf(reach, box.end.x)
	if reach == -INF:
		return -1.0
	if m.motion.y == 0.0:
		# A slide decelerating at Fighter.SLIDE_DECEL covers v²/(2·decel).
		reach += m.motion.x * m.motion.x / (2.0 * Fighter.SLIDE_DECEL)
	return reach
