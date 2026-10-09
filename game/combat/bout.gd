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
const COMBO_STEP := 0.1
const COMBO_FLOOR := 0.3

var fighters: Array[Fighter] = []
var entities: Array[Entity] = []
## Summoned spirits: body-less copies of other fighters, each performing one
## move. They strike but have no hurtbox or pushbox.
var spirits: Array[Fighter] = []
var wins: Array[int] = [0, 0]
## Rounds needed to win the bout; a monster is fought in one long round.
var rounds_to_win := ROUNDS_TO_WIN
## Some monsters are fought in a circular arena this long, with no walls: run
## far enough one way and you come back round the other. Zero: the walled stage.
var arena_length := 0.0
## Frames a beaten giant stays down for its sealing.
var finish_frames := FINISH_FRAMES
var round_number := 1
var phase := Phase.FIGHT
var phase_frame := 0
## How long the "ROUND n" banner shows at the start of a round's fighting; the
## bell rings as it goes.
const BANNER_FRAMES := 60
## Index of the last round's winner, or -1 for a double KO.
var round_winner := -1
var hitstop := 0
## Consecutive hits each fighter has taken without recovering. Each further
## hit deals less damage, down to COMBO_FLOOR of its full value.
var combo: Array[int] = [0, 0]
## Frames per round before time runs out (0: no limit), and frames elapsed.
var time_limit := 0
var round_frame := 0
## Whether the deciding KO may lead to a finisher at all (a run turns it off
## where a spirit is granted without one).
var offer_finisher := true
## True once a finisher has sealed the loser's spirit.
var bound := false
## While positive, a throw is holding its victim and the fight is frozen. The
## thrower may be a fighter or a spirit.
var grab_frames := 0
var grab_thrower: Fighter = null
var grab_victim := -1
var _grab_input_start := 0


func _init(a: FighterDefinition, b: FighterDefinition,
		spirits_a: Array[SpiritBinding] = [], spirits_b: Array[SpiritBinding] = []) -> void:
	fighters.assign([Fighter.new(a, spirits_a), Fighter.new(b, spirits_b)])
	start_round()


## A bout between a fighter and a monster, in one long round, in the arena
## the monster asks for. When the monster falls it must be sealed; if the seal
## is missed its core reforms and the fight goes on.
static func versus_monster(a: FighterDefinition, spirits_a: Array[SpiritBinding], monster: Monster) -> Bout:
	var bout := Bout.new(a, monster.definition, spirits_a, [])
	bout.fighters[1] = monster
	bout.rounds_to_win = 1
	bout.arena_length = monster.monster.arena_length
	bout.finish_frames = roundi(FINISH_FRAMES * monster.seal_scale)
	bout.start_round()
	bout.fighters[0].free_facing = monster.monster.free_facing
	return bout


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
	combo = [0, 0]
	round_frame = 0


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
	if wins[0] >= rounds_to_win:
		return 0
	if wins[1] >= rounds_to_win:
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
	round_frame += 1
	for i in 2:
		var me := fighters[i]
		var them := fighters[1 - i]
		if not me.state in [Fighter.State.HITSTUN, Fighter.State.KNOCKDOWN, Fighter.State.GRABBED]:
			combo[i] = 0
		# Standing on a monster, or with free facing, a fighter faces where it
		# walks instead.
		if not me.on_raised_ground() and not me.free_facing:
			me.face_toward(them.position.x)
		me.threatened = _threatens(1 - i)
		me.spirit_threatened = _spirit_threatens(1 - i)
		# What is out there, and what first sent it (a wave counts as its jet).
		me.live_spawns = []
		for e in entities:
			if e.owner_index == i:
				me.live_spawns.append(e.move)
				me.live_spawns.append(e.origin)
	_update_surfaces()
	var monster_before := _monster_x()
	for f in fighters:
		f.step()
	_carry_riders(monster_before)
	for s in spirits:
		s.record(Intent.new())
		s.step()
	for e in entities:
		e.step()
	_carry_held()
	_spawn()
	_push_apart()
	_resolve_hits()
	for e in entities:
		# A tethered piece is withdrawn once its performer stops the move.
		if e.move.tethered:
			var performer := fighters[e.owner_index]
			if performer.state != Fighter.State.MOVE or performer.move == null or performer.move.spawn != e.move:
				if not e.from_spirit:
					e.spent = true
		if e.spent and e.holding:
			e.holding.release_hold()
	# What spent pieces leave behind on the ground.
	var left_behind: Array[Entity] = []
	for e in entities:
		if e.spent and e.move.leaves:
			var left := Entity.new(e.move.leaves, Vector2(e.position.x, Fighter.FLOOR_Y), e.facing, e.owner_index, e.from_spirit)
			left.origin = e.origin
			left_behind.append(left)
	entities.assign(entities.filter(func(e: Entity) -> bool: return not e.spent))
	entities.append_array(left_behind)
	spirits.assign(spirits.filter(func(s: Fighter) -> bool: return s.state == Fighter.State.MOVE))
	_wrap()
	if time_limit > 0 and round_frame >= time_limit:
		_time_up()
	_check_ko()


## Time out: whoever has the smaller share of their health falls; equal
## shares fall together.
func _time_up() -> void:
	var share := fighters.map(func(f: Fighter) -> float: return float(f.health) / f.definition.max_health)
	for i in 2:
		if share[i] <= share[1 - i]:
			fighters[i].collapse()


## A spirit of `index` standing in a counter stance, if any.
func _spirit_counter(index: int) -> Fighter:
	for s in spirits:
		if s.summoner == index and s.counter_ready():
			return s
	return null


func _spirit_threatens(index: int) -> bool:
	for e in entities:
		if e.owner_index == index and e.from_spirit and not e.spent:
			return true
	for s in spirits:
		if s.summoner == index and s.threatening():
			return true
	return false


## The pieces a move releases, at each spawn offset from the performer or
## from its target. A monster's volleys around its target spread wider on
## easier settings. Converging pieces head for the performer's centreline.
func _release(f: Fighter, side: int) -> Array[Entity]:
	var m := f.move
	var target := fighters[1 - side]
	var offsets: Array[Vector2] = m.spawn_offsets.duplicate()
	if offsets.is_empty():
		offsets.append(m.spawn_offset)
	var spread: float = (f as Monster).spread_scale if f is Monster else 1.0
	var out: Array[Entity] = []
	for offset in offsets:
		var at := f.position + Vector2(f.facing * offset.x, offset.y)
		if m.spawn_origin == MoveDefinition.SpawnOrigin.TARGET:
			# Over the opponent; over a giant's core, its heart.
			var over := target.position
			if target is Monster and (target as Monster).monster.core.has_area():
				over.x = target.to_world((target as Monster).monster.core).get_center().x
			if m.spawn_range > 0.0 and absf(over.x - f.position.x) > m.spawn_range:
				over.x = f.position.x + signf(over.x - f.position.x) * m.spawn_range
			at = over + Vector2(offset.x * spread, offset.y)
		var e := Entity.new(f.pending_spawn, at, f.facing, side, f.summoner >= 0)
		var k := out.size()
		if k < m.spawn_angles.size():
			var a := deg_to_rad(m.spawn_angles[k])
			e.velocity = Vector2(cos(a), -sin(a)) * f.pending_spawn.motion.length()
		# A seeking piece comes down where the opponent stands.
		e.seek(absf(target.position.x - at.x))
		if f.pending_spawn.converges:
			e.centre_x = f.position.x
			e.facing = 1 if e.centre_x > e.position.x else -1
		out.append(e)
	return out


## Each fighter's floor: the stage, or the top of a monster part beneath its
## feet. A monster learns whether it is being ridden.
func _update_surfaces() -> void:
	for i in 2:
		var f := fighters[i]
		var other := fighters[1 - i]
		if f is Monster:
			continue
		f.floor_y = Fighter.FLOOR_Y
		if other is Monster:
			var beast := other as Monster
			for top: Rect2 in beast.surfaces():
				var above: bool = f.position.y <= top.position.y + 1.0
				if above and f.position.x >= top.position.x and f.position.x <= top.end.x \
						and top.position.y < f.floor_y:
					f.floor_y = top.position.y
			beast.ridden = f.on_raised_ground()


## The monster's position before this frame's steps, if there is one.
func _monster_x() -> Vector2:
	for f in fighters:
		if f is Monster:
			return f.position
	return Vector2.ZERO


## Whoever stands on a monster moves with it, up as well as along.
func _carry_riders(before: Vector2) -> void:
	for i in 2:
		var other := fighters[1 - i]
		if other is Monster and fighters[i].on_raised_ground():
			fighters[i].position += other.position - before
			fighters[i].floor_y = fighters[i].position.y


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
			entities.append_array(_release(f, side))
		if f.pending_heal > 0:
			fighters[side].heal(f.pending_heal)
		if f.pending_armor > 0:
			fighters[side].gain_armor(f.pending_armor)
		if f.pending_teleport > 0.0:
			var target := fighters[1 - side]
			var across := signf(target.position.x - f.position.x)
			if across == 0.0:
				across = f.facing
			var half := target.definition.pushbox.size.x / 2.0
			var gap := absf(target.position.x - f.position.x) - half
			if f.move.teleport_range > 0.0 and gap > f.move.teleport_range:
				# Out of range: only so far, landing before the opponent.
				f.position.x += across * f.move.teleport_range
				f.facing = int(across)
			else:
				f.position = Vector2(target.position.x + across * (half + f.pending_teleport), Fighter.FLOOR_Y)
				f.facing = -int(across)
			_clamp(f)
		if f.pending_summon >= 0:
			var binding := f.spirits[f.pending_summon]
			var s := Fighter.new(binding.source)
			s.reset(f.position.x + f.facing * binding.source.spirit_offset.x, f.facing)
			s.summoner = side
			s.perform(binding.move)
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
	_wrap()
	if winner_fighter.performing_finisher() and _any_hit(winner_fighter.active_hitboxes(), loser.hurtbox()):
		loser.seal()
		bound = true
	elif phase_frame >= finish_frames and loser is Monster:
		# The seal was missed: the giant's core reforms and the fight resumes.
		(loser as Monster).reform()
		winner_fighter.awaiting_finisher = false
		wins[round_winner] -= 1
		_enter(Phase.FIGHT)
		return
	elif phase_frame >= finish_frames:
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
		# A monster's body is several hurtboxes; where a strike lands decides
		# which part it hits. A piece tethered to the target is part of it.
		var hurt := target.hurtboxes()
		for e in entities:
			if e.owner_index == 1 - i and e.move.tethered and not e.from_spirit and not e.spent:
				hurt.append_array(e.boxes())
		var f := fighters[i]
		# A ward the target has set stops a blow that meets it.
		if _warded(f, 1 - i):
			f.move_connected = true
			continue
		var landed := _strike_contact(f.active_strikes(), hurt)
		var contact: Rect2 = landed[0]
		if contact.has_area():
			if f.move.throw:
				throwers.append(f)
			else:
				strikes.append([i, f.move, f.facing, f, false, contact, landed[1]])
		for e in entities:
			if e.owner_index != i or e.holding or e.pushing:
				continue
			contact = _contact(e.active_hitboxes(), hurt)
			if not contact.has_area():
				continue
			# A giant's hand: guarded, it pushes the guard along; unguarded, it seizes.
			if e.move.pushes_on_guard and target.guards_against(e.move, e.facing, e.from_spirit):
				target.receive(e.move, e.facing, e.from_spirit)
				e.pushing = target
				continue
			if e.move.grabs and not target.guards_against(e.move, e.facing, e.from_spirit):
				target.seized(e.move)
				e.holding = target
				continue
			strikes.append([i, e.move, e.facing, null, e.from_spirit, contact, 1.0])
			if e.move.returns:
				e.turn_back()
			else:
				e.spent = true
		for s in spirits:
			if s.summoner != i or s.state != Fighter.State.MOVE:
				continue
			var s_landed := _strike_contact(s.active_strikes(), hurt)
			contact = s_landed[0]
			if contact.has_area():
				if s.move.throw:
					throwers.append(s)
				else:
					strikes.append([i, s.move, s.facing, null, true, contact, s_landed[1]])
					s.move_connected = true

	var struck := [false, false]
	for s in strikes:
		var m: MoveDefinition = s[1]
		var side: int = 1 - s[0]
		var target := fighters[side]
		var attacker: Fighter = s[3]
		hitstop = maxi(hitstop, m.hitstop)
		if attacker:
			attacker.move_connected = true
		# A bound spirit in a counter stance takes the strike for its summoner
		# and answers from where the summoner stands.
		var guardian := _spirit_counter(side)
		if guardian:
			guardian.position = target.position
			guardian.facing = target.facing
			guardian.trigger_counter()
			target.show_notice("COUNTER")
			continue
		# Combo scaling, and where on the weapon it landed.
		var scale: float = maxf(COMBO_FLOOR, 1.0 - COMBO_STEP * combo[side]) * s[6]
		if not target.airborne and not target is Monster:
			scale *= m.grounded_scale
		target.receive(m, s[2], s[4], scale, s[5])
		struck[side] = true
		if target.state in [Fighter.State.HITSTUN, Fighter.State.KNOCKDOWN, Fighter.State.KO]:
			combo[side] += 1
		if attacker:
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


## Opposing entities that touch destroy each other, except tethered pieces,
## which are part of their performer and are struck instead.
func _clash_entities() -> void:
	for a in entities:
		for b in entities:
			if a.move.tethered or b.move.tethered:
				continue
			if a.owner_index < b.owner_index and not a.spent and not b.spent:
				for box in a.active_hitboxes():
					if _any_hit(b.active_hitboxes(), box):
						a.spent = true
						b.spent = true
						break


## Where any of `boxes` first overlaps any of `targets`; an empty rect if
## nowhere.
## Where a set of strikes ([box, damage scale] pairs) lands on `targets`, and
## the strongest zone that touched: [contact, scale], or an empty contact.
func _warded(f: Fighter, defender: int) -> bool:
	for e in entities:
		if e.owner_index != defender or not e.move.wards or e.spent:
			continue
		for strike in f.active_strikes():
			var box: Rect2 = strike[0] if strike is Array else strike
			for ward in e.boxes():
				if box.intersects(ward):
					return true
	return false


func _strike_contact(strikes: Array, targets: Array[Rect2]) -> Array:
	var best := [Rect2(), 0.0]
	for strike in strikes:
		for t in targets:
			if strike[0].intersects(t) and strike[1] > best[1]:
				best = [strike[0].intersection(t), strike[1]]
	return best


func _contact(boxes: Array[Rect2], targets: Array[Rect2]) -> Rect2:
	for box in boxes:
		for t in targets:
			if box.intersects(t):
				return box.intersection(t)
	return Rect2()


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
	# A fighter can't shove a monster; it gives way entirely.
	var l_share := 1.0 if r is Monster else (0.0 if l is Monster else 0.5)
	l.position.x -= overlap * l_share
	r.position.x += overlap * (1.0 - l_share)
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
	# A body without a pushbox (a giant looming behind the stage) blocks nothing.
	if not a.has_area() or not b.has_area() or not a.intersects(b):
		return 0.0
	return a.end.x - b.position.x


func _clamp(f: Fighter) -> void:
	if arena_length > 0.0:
		return
	var half := f.definition.pushbox.size.x / 2.0
	f.position.x = clampf(f.position.x, STAGE_LEFT + half, STAGE_RIGHT - half)


## Pieces carry whoever they hold, and push whoever guards against them, until
## they stop; then the guard is let go.
func _carry_held() -> void:
	for e in entities:
		if e.holding:
			if e.holding.state == Fighter.State.GRABBED:
				e.holding.position.x = e.position.x
			else:
				e.holding = null
		if e.pushing:
			var t := e.pushing
			if e.arrived or not t.state in [Fighter.State.BLOCKSTUN, Fighter.State.GUARD]:
				e.pushing = null
				continue
			t.position.x += e.last_step_x()
			t.stun = maxi(t.stun, 2)


## In a circular arena, every position is kept on the shortest way round from
## the first fighter, who is kept within one lap of the origin. Hits, pushes
## and spawns can then use ordinary distances.
func _wrap() -> void:
	if arena_length <= 0.0:
		return
	var anchor := fighters[0]
	var laps := roundf(anchor.position.x / arena_length)
	var bodies: Array = fighters + spirits
	for body in bodies:
		body.position.x -= laps * arena_length
	for e in entities:
		e.position.x -= laps * arena_length
		e.centre_x -= laps * arena_length
	var origin := anchor.position.x
	for body in bodies:
		if body != anchor:
			body.position.x = origin + wrapf(body.position.x - origin, -arena_length / 2.0, arena_length / 2.0)
	for e in entities:
		var shift: float = origin + wrapf(e.position.x - origin, -arena_length / 2.0, arena_length / 2.0) - e.position.x
		e.position.x += shift
		e.centre_x += shift


func _against_wall(f: Fighter, direction: int) -> bool:
	if arena_length > 0.0:
		return false
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
	if round_winner < 0 or wins[round_winner] < rounds_to_win:
		_enter(Phase.ROUND_OVER)
		return
	var w := fighters[round_winner]
	var loser := fighters[1 - round_winner]
	# A beaten giant must always be sealed, though it yields nothing.
	if loser is Monster or (offer_finisher and w.definition.finisher_move and finisher_would_gain(w, loser)):
		loser.daze()
		w.awaiting_finisher = true
		_enter(Phase.FINISH)
	else:
		_enter(Phase.BOUT_OVER)


## Whether sealing `loser` would give `winner` anything: the loser's own
## spirit if the winner can bind its kind, or any spirit the loser carries
## that the winner could bind. Spirits the winner already holds don't count.
static func finisher_would_gain(winner: Fighter, loser: Fighter) -> bool:
	var held := winner.spirits.map(func(b: SpiritBinding) -> StringName: return b.source.id)
	var new_to := func(d: FighterDefinition) -> bool: return winner.definition.binds(d) and not d.id in held
	return new_to.call(loser.definition) or loser.spirits.any(func(b: SpiritBinding) -> bool: return new_to.call(b.source))


func _enter(p: Phase) -> void:
	phase = p
	phase_frame = 0
