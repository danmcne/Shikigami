class_name Monster
extends Fighter
## A monster in a bout: a Fighter whose body is several parts and whose
## behaviour comes from its MonsterDefinition instead of from input.
##
## It does not flinch. Every hit lands on a part and costs health scaled by
## that part; breaking a part staggers it and may cripple it, slowing it and
## changing which attacks it uses. It cannot be thrown or bound.

var monster: MonsterDefinition
## Difficulty: multipliers on turning delay, rest between attacks, the spread
## of its volleys, and the time allowed to seal it.
var turn_scale := 1.0
var rest_scale := 1.0
var spread_scale := 1.0
var seal_scale := 1.0
var windup_scale := 1.0
var speed_scale := 1.0
## Its attacks as played at this pace, by original move.
var _paced := {}
var part_health: Array[int] = []
var attack: MonsterDefinition.Attack = null
var rng := RandomNumberGenerator.new()
## Someone is standing on it; set by the Bout each frame.
var ridden := false
var _rest := 0
var _target_x := 0.0
var _behind := 0


## `pace` is a difficulty table (CpuController.LEVELS); its monster_turn and
## monster_rest entries slow or quicken the monster.
func _init(def: MonsterDefinition, seed_value := 0, pace: Dictionary = {}) -> void:
	super(def.body)
	monster = def
	rng.seed = seed_value
	turn_scale = pace.get("monster_turn", 1.0)
	rest_scale = pace.get("monster_rest", 1.0)
	spread_scale = pace.get("monster_spread", 1.0)
	seal_scale = pace.get("monster_seal", 1.0)
	windup_scale = pace.get("monster_windup", 1.0)
	speed_scale = pace.get("monster_speed", 1.0)


func reset(x: float, face: int) -> void:
	super.reset(x, face if monster.turns else 1)
	part_health.assign(monster.parts.map(func(p: MonsterDefinition.Part) -> int: return p.health))
	if flying():
		position.y = -monster.altitude
	attack = null
	_rest = roundi(monster.rest * rest_scale)


## It turns round only after its opponent has stayed behind it for a while
## (its own attacks pause the count), and not at all while being ridden.
func face_toward(x: float) -> void:
	_target_x = x
	var side := 1 if x > position.x else -1
	if not monster.turns or ridden or side == facing:
		_behind = 0
		return
	if not can_turn():
		return
	_behind += 1
	if _behind >= roundi(monster.turn_delay * turn_scale):
		facing = side
		_behind = 0
		show_notice("TURNS")


## The tops of its standable parts, in world space.
func surfaces() -> Array[Rect2]:
	var out: Array[Rect2] = []
	for p in monster.parts:
		if p.standable:
			out.append(to_world(p.box))
	return out


## Flying: it can fly and its flight part is unbroken.
func flying() -> bool:
	return monster.altitude > 0.0 and not broken(monster.flight_part)


## A move as this monster plays it at its pace: longer start-up, and slower
## travel for whatever it sends out, on easier settings.
func paced(m: MoveDefinition) -> MoveDefinition:
	if is_equal_approx(windup_scale, 1.0) and is_equal_approx(speed_scale, 1.0):
		return m
	if not _paced.has(m):
		var copy: MoveDefinition = m.duplicate()
		copy.startup = ceili(m.startup * windup_scale)
		if m.spawn:
			var piece: MoveDefinition = m.spawn.duplicate()
			piece.motion = m.spawn.motion * speed_scale
			piece.startup = ceili(m.spawn.startup * windup_scale)
			piece.active = ceili(m.spawn.active / maxf(speed_scale, 0.1))
			copy.spawn = piece
		_paced[m] = copy
	return _paced[m]


func crippled() -> bool:
	for k in monster.parts.size():
		if monster.parts[k].health > 0 and part_health[k] <= 0:
			return true
	return false


func broken(part_name: String) -> bool:
	for k in monster.parts.size():
		if monster.parts[k].name == part_name:
			return monster.parts[k].health > 0 and part_health[k] <= 0
	return false


## Whether part k can be struck now.
func exposed(k: int) -> bool:
	var p: MonsterDefinition.Part = monster.parts[k]
	if not p.hidden:
		return true
	return state == State.MOVE and attack != null and p.name in attack.exposes \
			and state_frame >= move.startup + move.active


## Beaten and awaiting its seal, only its core can be struck.
func hurtbox() -> Rect2:
	if state == State.DAZED and monster.core.has_area():
		return to_world(monster.core)
	return super.hurtbox()


## The seal was missed: the core reforms and it fights on.
func reform() -> void:
	health = maxi(roundi(definition.max_health * monster.reform_fraction), 1)
	attack = null
	_halt()
	_rest = roundi(monster.rest * rest_scale)
	show_notice("THE CORE REFORMS")
	_set_state(State.STAND, true)


func hurtboxes() -> Array[Rect2]:
	if state == State.DAZED:
		var core: Array[Rect2] = [hurtbox()]
		return core
	var boxes: Array[Rect2] = []
	for k in monster.parts.size():
		if exposed(k):
			boxes.append(_strike_box(k))
	return boxes


## Where part k can be struck: its box, extended upward by its reach_above.
func _strike_box(k: int) -> Rect2:
	var p: MonsterDefinition.Part = monster.parts[k]
	var box := to_world(p.box)
	return Rect2(box.position.x, box.position.y - p.reach_above, box.size.x, box.size.y + p.reach_above)


func pushbox() -> Rect2:
	if state == State.MOVE and attack and attack.pushless and move.is_active_on(state_frame):
		return Rect2()
	return super.pushbox()


func step() -> void:
	state_frame += 1
	pending_spawn = null
	pending_summon = -1
	pending_heal = 0
	pending_armor = 0
	pending_teleport = 0.0
	notice_frames = maxi(notice_frames - 1, 0)
	glow_frames = maxi(glow_frames - 1, 0)
	match state:
		State.STAND, State.WALK:
			_think()
		State.MOVE:
			if state_frame >= move.total_frames():
				var next := attack.follow_up if attack else null
				_halt()
				attack = null
				if next:
					attack = next
					_begin(paced(next.move))
				else:
					_rest = roundi(monster.rest * rest_scale * (1.5 if crippled() else 1.0))
					_set_state(State.STAND)
		State.HITSTUN:
			stun -= 1
			if stun <= 0:
				_set_state(State.STAND)
		_:
			pass
	if state == State.MOVE and state_frame == move.startup and move.spawn:
		pending_spawn = move.spawn
	if state == State.MOVE and attack and attack.travel != Vector2.ZERO and move.is_active_on(state_frame):
		position += Vector2(facing * attack.travel.x, attack.travel.y) * speed_scale
		position.y = minf(position.y, 0.0)
	_hover()
	_integrate()


## Between attacks a flying monster climbs back to its height; one that is
## grounded, beaten or staggered sinks to the ground.
func _hover() -> void:
	if state == State.MOVE:
		return
	var height := -monster.altitude if flying() and state in [State.STAND, State.WALK] else 0.0
	position.y = move_toward(position.y, height, monster.climb_speed)


## No gravity and no falling: a monster's height is its own business.
func _integrate() -> void:
	position.x += slide
	slide = move_toward(slide, 0.0, SLIDE_DECEL)


func receive(m: MoveDefinition, _from_facing: int, _from_spirit := false, scale := 1.0,
		contact := Rect2()) -> void:
	if state == State.KO:
		return
	var k := _part_at(contact)
	var part: MonsterDefinition.Part = monster.parts[k]
	var damage := roundi(m.damage * scale * part.damage_scale)
	if not invincible:
		health = maxi(health - damage, 0)
	if health == 0:
		_halt()
		attack = null
		_set_state(State.KO, true)
		return
	if part.health > 0 and part_health[k] > 0:
		part_health[k] -= damage
		if part_health[k] <= 0:
			show_notice("%s BROKEN" % part.name.to_upper())
			_halt()
			attack = null
			stun = monster.stagger
			_set_state(State.HITSTUN, true)


func invulnerable() -> bool:
	return state == State.KO


func throwable() -> bool:
	return false


## Between attacks it closes in, slowly when crippled; when rested it picks an
## attack that suits the distance.
func _think() -> void:
	var gap := absf(_target_x - position.x) - definition.stand_hurtbox.size.x / 2.0
	var ahead := (_target_x - position.x) * facing >= 0.0
	_rest -= 1
	if _rest > 0:
		if gap > monster.close_gap and (ahead or not monster.turns) and not ridden:
			position.x += signf(_target_x - position.x) * monster.walk_speed * (0.5 if crippled() else 1.0)
			_set_state(State.WALK)
		else:
			_set_state(State.STAND)
		return
	var choice := _choose(gap, ahead)
	if choice:
		attack = choice
		_begin(paced(choice.move))


## An attack for the moment. With its opponent behind it, only attacks that
## reach behind; while ridden, any, but those meant for riders first.
func _choose(gap: float, ahead: bool) -> MonsterDefinition.Attack:
	var usable: Array = []
	var weights := PackedFloat32Array()
	for a in monster.attacks:
		var attack_def: MonsterDefinition.Attack = a
		if attack_def.ridden_only and not ridden:
			continue
		if not ridden and (gap < attack_def.min_gap or gap > attack_def.max_gap):
			continue
		if monster.turns and not ahead and not ridden \
				and not attack_def.move.hitboxes.any(func(r: Rect2) -> bool: return r.position.x < 0.0):
			continue
		if attack_def.side != 0 and signf(_target_x - position.x) != attack_def.side:
			continue
		if attack_def.stage_half != 0 and signf(_target_x) != attack_def.stage_half:
			continue
		if attack_def.requires.any(func(name: String) -> bool: return broken(name)):
			continue
		if attack_def.needs_broken.any(func(name: String) -> bool: return not broken(name)):
			continue
		var w := attack_def.crippled_weight if crippled() else attack_def.weight
		if w > 0.0:
			usable.append(attack_def)
			weights.append(w)
	if usable.is_empty():
		return null
	return usable[rng.rand_weighted(weights)]


## The part a strike landed on: the exposed part whose box holds the contact's
## centre, or failing that the first exposed part it touches.
func _part_at(contact: Rect2) -> int:
	var centre := contact.get_center()
	var touched := -1
	for k in monster.parts.size():
		if not exposed(k):
			continue
		var box := _strike_box(k)
		if box.has_point(centre):
			return k
		if touched < 0 and box.intersects(contact.grow(0.5)):
			touched = k
	return maxi(touched, 0)
