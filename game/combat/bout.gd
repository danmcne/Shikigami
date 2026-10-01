class_name Bout
extends RefCounted
## Two fighters, their spirits and entities, one stage, a best-of-three.
## Owns the frame order:
##   record input -> (throw held? check escape, stop) -> (hitstop? stop)
##   -> face, flag threats -> step fighters and spirits -> spawn
##   -> push apart, clamp -> resolve hits -> KO?
## When the deciding KO leaves a loser the winner can bind, the bout enters
## FINISH: the loser stands dazed and the winner has a few seconds to perform
## their finisher. The bout ends in BOUT_OVER and does not restart itself.
## Pure simulation; the view reads its state and draws it.

enum Phase { FIGHT, ROUND_OVER, FINISH, BOUT_OVER }

const ROUNDS_TO_WIN := 2
const STAGE_LEFT := -600.0
const STAGE_RIGHT := 600.0
const START_OFFSET := 150.0
const ROUND_OVER_FRAMES := 120
const BOUT_OVER_FRAMES := 180
const FINISH_FRAMES := 300
## Where a back throw puts the victim, measured behind the thrower.
const BACK_THROW_DISTANCE := 60.0
## Frames a throw holds its victim before landing. Pressing A+B within this
## window (or just before it) escapes.
const TECH_WINDOW := 10
const TECH_PREBUFFER := 3

var fighters: Array[Fighter] = []
var entities: Array[Entity] = []
## Summoned spirits: body-less copies of other fighters, each performing one
## move. They strike but have no hurtbox or pushbox.
var spirits: Array[Fighter] = []
var wins: Array[int] = [0, 0]
var round_number := 1
var phase := Phase.FIGHT
var phase_frame := 0
## Index of the last round's winner, or -1 for a double KO.
var round_winner := -1
var hitstop := 0
## True once a finisher has sealed the loser's spirit.
var bound := false
## While positive, a throw is holding its victim and the fight is frozen. The
## thrower may be a fighter or a spirit.
var grab_frames := 0
var grab_thrower: Fighter = null
var grab_victim := -1
var _grab_input_start := 0


func _init(a: FighterDefinition, b: FighterDefinition,
		spirits_a: Array[FighterDefinition] = [], spirits_b: Array[FighterDefinition] = []) -> void:
	fighters.assign([Fighter.new(a, spirits_a), Fighter.new(b, spirits_b)])
	start_round()


func start_round() -> void:
	fighters[0].reset(-START_OFFSET, 1)
	fighters[1].reset(START_OFFSET, -1)
	entities.clear()
	spirits.clear()
	phase = Phase.FIGHT
	phase_frame = 0
	hitstop = 0
	grab_frames = 0
	grab_thrower = null


func restart() -> void:
	wins = [0, 0]
	round_number = 1
	bound = false
	start_round()


## True once the bout has been decided and its closing pause has passed.
func is_over() -> bool:
	return phase == Phase.BOUT_OVER and phase_frame >= BOUT_OVER_FRAMES


func step(intents: Array[Intent]) -> void:
	phase_frame += 1
	match phase:
		Phase.FIGHT:
			_fight_step(intents)
		Phase.ROUND_OVER:
			_settle_step()
			if phase_frame >= ROUND_OVER_FRAMES:
				round_number += 1
				start_round()
		Phase.FINISH:
			_finish_step(intents)
		Phase.BOUT_OVER:
			_settle_step()


func winner() -> int:
	if wins[0] >= ROUNDS_TO_WIN:
		return 0
	if wins[1] >= ROUNDS_TO_WIN:
		return 1
	return -1


func _fight_step(intents: Array[Intent]) -> void:
	for i in 2:
		fighters[i].record(intents[i])
	if grab_frames > 0:
		_hold_throw()
		return
	if hitstop > 0:
		hitstop -= 1
		return
	for i in 2:
		var me := fighters[i]
		var them := fighters[1 - i]
		me.face_toward(them.position.x)
		me.threatened = _threatens(1 - i)
		me.spirit_threatened = _spirit_threatens(1 - i)
		me.live_spawns = entities.filter(func(e: Entity) -> bool: return e.owner_index == i) \
				.map(func(e: Entity) -> MoveDefinition: return e.move)
	for f in fighters:
		f.step()
	for s in spirits:
		s.record(Intent.new())
		s.step()
	for e in entities:
		e.step()
	_spawn()
	_push_apart()
	_resolve_hits()
	entities.assign(entities.filter(func(e: Entity) -> bool: return not e.spent))
	spirits.assign(spirits.filter(func(s: Fighter) -> bool: return s.state == Fighter.State.MOVE))
	_check_ko()


func _spirit_threatens(index: int) -> bool:
	for e in entities:
		if e.owner_index == index and e.from_spirit and not e.spent:
			return true
	for s in spirits:
		if s.summoner == index and s.threatening():
			return true
	return false


func _threatens(index: int) -> bool:
	if fighters[index].threatening():
		return true
	for e in entities:
		if e.owner_index == index and not e.spent:
			return true
	for s in spirits:
		if s.summoner == index and s.threatening():
			return true
	return false


## Carries out what moves asked for this frame: projectiles, summons, heals
## and teleports, from fighters and spirits alike. A spirit acts for its
## summoner: its projectiles are the summoner's and its heals heal them.
func _spawn() -> void:
	var performers: Array[Fighter] = []
	performers.assign(fighters + spirits)
	for f in performers:
		var side := f.summoner if f.summoner >= 0 else fighters.find(f)
		if f.pending_spawn:
			entities.append(Entity.new(f.pending_spawn, f, side))
		if f.pending_heal > 0:
			fighters[side].heal(f.pending_heal)
		if f.pending_teleport > 0.0:
			var target := fighters[1 - side]
			var across := signf(target.position.x - f.position.x)
			if across == 0.0:
				across = f.facing
			f.position = Vector2(target.position.x + across * f.pending_teleport, Fighter.FLOOR_Y)
			f.facing = -int(across)
			_clamp(f)
		if f.pending_summon >= 0:
			var source := f.spirits[f.pending_summon]
			var s := Fighter.new(source)
			s.reset(f.position.x + f.facing * source.spirit_offset.x, f.facing)
			s.summoner = side
			s.perform(source.signature)
			spirits.append(s)


## The fight is frozen while a throw holds its victim. The victim escapes by
## pressing A+B; otherwise the throw lands when the window closes.
func _hold_throw() -> void:
	grab_frames -= 1
	var thrower := grab_thrower
	var victim := fighters[grab_victim]
	var escape := InputHistory.A | InputHistory.B
	var since := _grab_input_start - TECH_PREBUFFER
	if victim.input.pressed(escape, since) >= 0 or victim.input.pressed_while_holding(escape, since) >= 0:
		grab_frames = 0
		thrower.release_from_throw(-thrower.facing)
		victim.release_from_throw(thrower.facing)
		return
	if grab_frames > 0:
		return
	var direction := thrower.facing
	if thrower.move_reversed:
		direction = -thrower.facing
		victim.position.x = thrower.position.x - thrower.facing * BACK_THROW_DISTANCE
	victim.receive(thrower.move, direction)
	hitstop = maxi(hitstop, thrower.move.hitstop)


## The loser stands dazed; the winner may walk and perform the finisher. If it
## connects, the loser's spirit is sealed; if time runs out, they collapse.
func _finish_step(intents: Array[Intent]) -> void:
	var winner_fighter := fighters[round_winner]
	var loser := fighters[1 - round_winner]
	for i in 2:
		fighters[i].record(intents[i])
	for f in fighters:
		f.step()
	_push_apart()
	if winner_fighter.performing_finisher() and _any_hit(winner_fighter.active_hitboxes(), loser.hurtbox()):
		loser.seal()
		bound = true
	elif phase_frame >= FINISH_FRAMES:
		loser.collapse()
	else:
		return
	winner_fighter.awaiting_finisher = false
	_enter(Phase.BOUT_OVER)


## After a KO the fighters keep falling and sliding, but take no input.
func _settle_step() -> void:
	for f in fighters:
		f.record(Intent.new())
		f.step()
	_push_apart()


## Strikes are collected first and applied together, so two that land on the
## same frame trade. Throws are applied afterwards: a thrower struck on the
## same frame loses the throw, two throws on the same frame cancel out, and a
## throw that connects holds its victim for the escape window.
func _resolve_hits() -> void:
	_clash_entities()
	var strikes: Array = []
	var throwers: Array[Fighter] = []
	for i in 2:
		var target := fighters[1 - i]
		if target.invulnerable():
			continue
		var hurt := target.hurtbox()
		var f := fighters[i]
		if _any_hit(f.active_hitboxes(), hurt):
			if f.move.throw:
				throwers.append(f)
			else:
				strikes.append([i, f.move, f.facing, f, false])
		for e in entities:
			if e.owner_index == i and _any_hit(e.active_hitboxes(), hurt):
				strikes.append([i, e.move, e.facing, null, e.from_spirit])
				e.spent = true
		for s in spirits:
			if s.summoner == i and s.state == Fighter.State.MOVE and _any_hit(s.active_hitboxes(), hurt):
				if s.move.throw:
					throwers.append(s)
				else:
					strikes.append([i, s.move, s.facing, null, true])
					s.move_connected = true

	var struck := [false, false]
	for s in strikes:
		var m: MoveDefinition = s[1]
		var target := fighters[1 - s[0]]
		target.receive(m, s[2], s[4])
		struck[1 - s[0]] = true
		hitstop = maxi(hitstop, m.hitstop)
		var attacker: Fighter = s[3]
		if attacker:
			attacker.move_connected = true
			# A cornered defender cannot slide back, so the attacker recoils instead.
			if _against_wall(target, attacker.facing) and not attacker.airborne:
				attacker.slide = -attacker.facing * m.knockback

	# Two fighters throwing each other on the same frame cancel out.
	if fighters.all(func(f: Fighter) -> bool: return f in throwers):
		for f in fighters:
			f.move_connected = true
			throwers.erase(f)
	for thrower in throwers:
		var side := thrower.summoner if thrower.summoner >= 0 else fighters.find(thrower)
		var target := fighters[1 - side]
		var thrower_struck: bool = thrower.summoner < 0 and struck[side]
		if thrower_struck or grab_frames > 0 or not target.throwable():
			continue
		thrower.move_connected = true
		target.grabbed()
		grab_thrower = thrower
		grab_victim = 1 - side
		grab_frames = TECH_WINDOW
		_grab_input_start = target.input.frame


## Opposing entities that touch destroy each other.
func _clash_entities() -> void:
	for a in entities:
		for b in entities:
			if a.owner_index < b.owner_index and not a.spent and not b.spent:
				for box in a.active_hitboxes():
					if _any_hit(b.active_hitboxes(), box):
						a.spent = true
						b.spent = true
						break


func _any_hit(boxes: Array[Rect2], target: Rect2) -> bool:
	for box in boxes:
		if box.intersects(target):
			return true
	return false


func _push_apart() -> void:
	for s in spirits:
		_clamp(s)
	for f in fighters:
		_clamp(f)
	var l := fighters[0]
	var r := fighters[1]
	if l.position.x > r.position.x or (l.position.x == r.position.x and l.facing < r.facing):
		var t := l
		l = r
		r = t
	var overlap := _overlap(l, r)
	if overlap <= 0.0:
		return
	l.position.x -= overlap / 2.0
	r.position.x += overlap / 2.0
	_clamp(l)
	_clamp(r)
	overlap = _overlap(l, r)
	if overlap > 0.0:
		if _against_wall(l, -1):
			r.position.x += overlap
		else:
			l.position.x -= overlap


func _overlap(l: Fighter, r: Fighter) -> float:
	var a := l.pushbox()
	var b := r.pushbox()
	if not a.intersects(b):
		return 0.0
	return a.end.x - b.position.x


func _clamp(f: Fighter) -> void:
	var half := f.definition.pushbox.size.x / 2.0
	f.position.x = clampf(f.position.x, STAGE_LEFT + half, STAGE_RIGHT - half)


func _against_wall(f: Fighter, direction: int) -> bool:
	var half := f.definition.pushbox.size.x / 2.0
	if direction > 0:
		return f.position.x >= STAGE_RIGHT - half - 0.5
	return f.position.x <= STAGE_LEFT + half + 0.5


func _check_ko() -> void:
	var down := fighters.map(func(f: Fighter) -> bool: return f.state == Fighter.State.KO)
	if not (down[0] or down[1]):
		return
	round_winner = -1 if (down[0] and down[1]) else (1 if down[0] else 0)
	if round_winner >= 0:
		wins[round_winner] += 1
	entities.clear()
	spirits.clear()
	if round_winner < 0 or wins[round_winner] < ROUNDS_TO_WIN:
		_enter(Phase.ROUND_OVER)
		return
	var w := fighters[round_winner]
	var loser := fighters[1 - round_winner]
	# A spirit already held cannot be sealed again.
	var held := w.spirits.any(func(d: FighterDefinition) -> bool: return d.id == loser.definition.id)
	if w.definition.binds(loser.definition) and w.definition.finisher_command != "" and not held:
		loser.daze()
		w.awaiting_finisher = true
		_enter(Phase.FINISH)
	else:
		_enter(Phase.BOUT_OVER)


func _enter(p: Phase) -> void:
	phase = p
	phase_frame = 0
