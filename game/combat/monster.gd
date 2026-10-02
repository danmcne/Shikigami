class_name Monster
extends Fighter
## A monster in a bout: a Fighter whose body is several parts and whose
## behaviour comes from its MonsterDefinition instead of from input.
##
## It does not flinch. Every hit lands on a part and costs health scaled by
## that part; breaking a part staggers it and may cripple it, slowing it and
## changing which attacks it uses. It cannot be thrown or bound.

var monster: MonsterDefinition
var part_health: Array[int] = []
var attack: MonsterDefinition.Attack = null
var rng := RandomNumberGenerator.new()
var _rest := 0
var _target_x := 0.0


func _init(def: MonsterDefinition, seed_value := 0) -> void:
	super(def.body)
	monster = def
	rng.seed = seed_value


func reset(x: float, face: int) -> void:
	super.reset(x, face)
	part_health.assign(monster.parts.map(func(p: MonsterDefinition.Part) -> int: return p.health))
	attack = null
	_rest = monster.rest


func face_toward(x: float) -> void:
	_target_x = x
	super.face_toward(x)


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


func hurtboxes() -> Array[Rect2]:
	var boxes: Array[Rect2] = []
	for k in monster.parts.size():
		if exposed(k):
			boxes.append(to_world(monster.parts[k].box))
	return boxes


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
				_halt()
				attack = null
				_rest = roundi(monster.rest * (1.5 if crippled() else 1.0))
				_set_state(State.STAND)
		State.HITSTUN:
			stun -= 1
			if stun <= 0:
				_set_state(State.STAND)
		_:
			pass
	if state == State.MOVE and state_frame == move.startup and move.spawn:
		pending_spawn = move.spawn
	if state == State.MOVE and attack and attack.travel != 0.0 and move.is_active_on(state_frame):
		position.x += facing * attack.travel
	_integrate()


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
	_rest -= 1
	if _rest > 0:
		if gap > monster.close_gap:
			position.x += facing * monster.walk_speed * (0.5 if crippled() else 1.0)
			_set_state(State.WALK)
		else:
			_set_state(State.STAND)
		return
	var choice := _choose(gap)
	if choice:
		attack = choice
		_begin(choice.move)


func _choose(gap: float) -> MonsterDefinition.Attack:
	var usable: Array = []
	var weights := PackedFloat32Array()
	for a in monster.attacks:
		var attack_def: MonsterDefinition.Attack = a
		if gap < attack_def.min_gap or gap > attack_def.max_gap:
			continue
		if attack_def.requires.any(func(name: String) -> bool: return broken(name)):
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
		var box := to_world(monster.parts[k].box)
		if box.has_point(centre):
			return k
		if touched < 0 and box.intersects(contact.grow(0.5)):
			touched = k
	return maxi(touched, 0)
