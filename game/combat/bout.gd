class_name Bout
extends RefCounted
## Two fighters, one stage, a best-of-three. Owns the frame order:
##   face -> step -> push apart -> clamp to stage -> resolve hits -> check KO.
## Pure simulation; the view reads its state and draws it.

enum Phase { FIGHT, ROUND_OVER, BOUT_OVER }

const ROUNDS_TO_WIN := 2
const STAGE_LEFT := -600.0
const STAGE_RIGHT := 600.0
const START_OFFSET := 150.0
const ROUND_OVER_FRAMES := 120
const BOUT_OVER_FRAMES := 240

var fighters: Array[Fighter] = []
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
	if hitstop > 0:
		hitstop -= 1
		return
	for i in 2:
		var me := fighters[i]
		var them := fighters[1 - i]
		me.face_toward(them.position.x)
		me.threatened = them.state == Fighter.State.ATTACK
	for i in 2:
		fighters[i].step(intents[i])
	_push_apart()
	_resolve_hits()
	_check_ko()


## After a KO the fighters keep falling and sliding, but take no input.
func _settle_step() -> void:
	for f in fighters:
		f.step(Intent.new())
	_push_apart()


## Hits are collected first and applied together, so two attacks that connect
## on the same frame trade instead of the first one cancelling the second.
func _resolve_hits() -> void:
	var hits: Array = []
	for i in 2:
		var hurt := fighters[1 - i].hurtbox()
		for box in fighters[i].active_hitboxes():
			if box.intersects(hurt):
				hits.append([i, fighters[i].attack])
				break
	for hit in hits:
		var attacker := fighters[hit[0]]
		var defender := fighters[1 - hit[0]]
		var atk: AttackDefinition = hit[1]
		attacker.attack_connected = true
		defender.receive(atk, attacker.facing)
		hitstop = maxi(hitstop, atk.hitstop)
		# A cornered defender cannot slide back, so the attacker recoils instead.
		if _against_wall(defender, attacker.facing) and not attacker.airborne:
			attacker.slide = -attacker.facing * atk.knockback


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
