class_name Bout
extends RefCounted
## Two fighters, their entities, one stage, a best-of-three. Owns the frame
## order:
##   record input -> (hitstop? stop) -> face, flag threats -> step fighters
##   -> step and spawn entities -> push apart, clamp -> resolve hits -> KO?
## Pure simulation; the view reads its state and draws it.

enum Phase { FIGHT, ROUND_OVER, BOUT_OVER }

const ROUNDS_TO_WIN := 2
const STAGE_LEFT := -600.0
const STAGE_RIGHT := 600.0
const START_OFFSET := 150.0
const ROUND_OVER_FRAMES := 120
const BOUT_OVER_FRAMES := 240
## Where a back throw puts the victim, measured behind the thrower.
const BACK_THROW_DISTANCE := 60.0

var fighters: Array[Fighter] = []
var entities: Array[Entity] = []
var wins: Array[int] = [0, 0]
var round_number := 1
var phase := Phase.FIGHT
var phase_frame := 0
## Index of the last round's winner, or -1 for a double KO.
var round_winner := -1
var hitstop := 0


func _init(a: FighterDefinition, b: FighterDefinition) -> void:
	fighters.assign([Fighter.new(a), Fighter.new(b)])
	start_round()


func start_round() -> void:
	fighters[0].reset(-START_OFFSET, 1)
	fighters[1].reset(START_OFFSET, -1)
	entities.clear()
	phase = Phase.FIGHT
	phase_frame = 0
	hitstop = 0


func restart() -> void:
	wins = [0, 0]
	round_number = 1
	start_round()


func step(intents: Array[Intent]) -> void:
	phase_frame += 1
	match phase:
		Phase.FIGHT:
			_fight_step(intents)
		Phase.ROUND_OVER:
			_settle_step()
			if phase_frame >= ROUND_OVER_FRAMES:
				if wins.max() >= ROUNDS_TO_WIN:
					_enter(Phase.BOUT_OVER)
				else:
					round_number += 1
					start_round()
		Phase.BOUT_OVER:
			_settle_step()
			if phase_frame >= BOUT_OVER_FRAMES:
				restart()


func winner() -> int:
	if wins[0] >= ROUNDS_TO_WIN:
		return 0
	if wins[1] >= ROUNDS_TO_WIN:
		return 1
	return -1


func _fight_step(intents: Array[Intent]) -> void:
	for i in 2:
		fighters[i].record(intents[i])
	if hitstop > 0:
		hitstop -= 1
		return
	for i in 2:
		var me := fighters[i]
		var them := fighters[1 - i]
		me.face_toward(them.position.x)
		me.threatened = them.threatening() or _has_entity(1 - i)
		me.has_projectile = _has_entity(i)
	for f in fighters:
		f.step()
	for e in entities:
		e.step()
	for i in 2:
		if fighters[i].pending_spawn:
			entities.append(Entity.new(fighters[i].pending_spawn, fighters[i], i))
	_push_apart()
	_resolve_hits()
	entities.assign(entities.filter(func(e: Entity) -> bool: return not e.spent))
	_check_ko()


## After a KO the fighters keep falling and sliding, but take no input.
func _settle_step() -> void:
	for f in fighters:
		f.record(Intent.new())
		f.step()
	_push_apart()


## Strikes are collected first and applied together, so two that land on the
## same frame trade. Throws are applied afterwards: a thrower struck on the
## same frame loses the throw, and two throws on the same frame cancel out.
func _resolve_hits() -> void:
	_clash_entities()
	var strikes: Array = []
	var throws: Array[int] = []
	for i in 2:
		var target := fighters[1 - i]
		if target.invulnerable():
			continue
		var hurt := target.hurtbox()
		var f := fighters[i]
		if _any_hit(f.active_hitboxes(), hurt):
			if f.move.throw:
				throws.append(i)
			else:
				strikes.append([i, f.move, f.facing, f])
		for e in entities:
			if e.owner_index == i and _any_hit(e.active_hitboxes(), hurt):
				strikes.append([i, e.move, e.facing, null])
				e.spent = true

	var struck := [false, false]
	for s in strikes:
		var m: MoveDefinition = s[1]
		var target := fighters[1 - s[0]]
		target.receive(m, s[2])
		struck[1 - s[0]] = true
		hitstop = maxi(hitstop, m.hitstop)
		var attacker: Fighter = s[3]
		if attacker:
			attacker.move_connected = true
			# A cornered defender cannot slide back, so the attacker recoils instead.
			if _against_wall(target, attacker.facing) and not attacker.airborne:
				attacker.slide = -attacker.facing * m.knockback

	if throws.size() == 2:
		for i in throws:
			fighters[i].move_connected = true
		return
	for i in throws:
		var thrower := fighters[i]
		var target := fighters[1 - i]
		if struck[i] or not target.throwable():
			continue
		thrower.move_connected = true
		var direction := thrower.facing
		if thrower.move_reversed:
			direction = -thrower.facing
			target.position.x = thrower.position.x - thrower.facing * BACK_THROW_DISTANCE
		target.receive(thrower.move, direction)
		hitstop = maxi(hitstop, thrower.move.hitstop)


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


func _has_entity(index: int) -> bool:
	for e in entities:
		if e.owner_index == index and not e.spent:
			return true
	return false


func _push_apart() -> void:
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
	_enter(Phase.ROUND_OVER)


func _enter(p: Phase) -> void:
	phase = p
	phase_frame = 0
