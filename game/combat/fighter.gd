class_name Fighter
extends RefCounted
## One fighter's simulation state. Pure logic: no nodes, no drawing, no input
## devices. The Bout records each frame's Intent, then steps the fighter.
## A summoned spirit is also a Fighter, performing one move with no input.

enum State { STAND, WALK, CROUCH, GUARD, JUMP, MOVE, HITSTUN, BLOCKSTUN, KNOCKDOWN,
		GRABBED, DAZED, SEALED, KO }

const FLOOR_Y := 0.0
## Deceleration of ground slide (knockback, blockback, dashes), in px/frame².
const SLIDE_DECEL := 0.5
## Summoning is the same for everyone: D for the first bound spirit, 2D for
## the second.
const SUMMON_COMMANDS := ["D", "2D"]
## Frames of blockstun both fighters take when a throw is escaped.
const TECH_STUN := 14
const TECH_PUSH := 8.0
const FINISHER := &"finisher"

var definition: FighterDefinition
var input := InputHistory.new()
## This player's input timing (see InputHistory); survives round resets.
var chord_window := InputHistory.DEFAULT_CHORD
## A practice cheat: hits still land and stun, but take no health.
var invincible := false
var position := Vector2.ZERO
## Airborne velocity, px/frame.
var velocity := Vector2.ZERO
## Ground slide, signed world px/frame.
var slide := 0.0
## +1 faces right, -1 faces left.
var facing := 1
var health := 0
var state := State.STAND
## Frames since entering the current state; 0 on the entry frame.
var state_frame := 0
var stun := 0
var move: MoveDefinition = null
var move_connected := false
## The move was started while holding back (a throw then goes backward).
var move_reversed := false
var airborne := false
var crouching := false
var holding_back := false
var air_move_used := false
## Set by the Bout each frame. `threatened` is perception for controllers;
## `live_spawns` lists moves whose released entity is still alive, which
## cannot be repeated until it is gone.
var threatened := false
var spirit_threatened := false
var live_spawns: Array = []
## Set by the Bout when the opponent is beaten and this fighter may seal them:
## only walking and the finisher are possible.
var awaiting_finisher := false
## Set by step() on the frame a move releases something for the Bout to spawn.
var pending_spawn: MoveDefinition = null
## Set by step() on the frame a summon releases a spirit: the slot index.
var pending_summon := -1
## Set by step() on the frame a move heals, or teleports (the distance).
var pending_heal := 0
var pending_teleport := 0.0
## Recharge remaining on moves that have one, by move id.
var move_cooldowns: Dictionary = {}
## Bound spirits (the fighters they came from) and their cooldowns, by slot.
var spirits: Array[FighterDefinition] = []
var cooldowns: Array[int] = []
## For a spirit: the index of the fighter who summoned it; -1 for a fighter.
var summoner := -1

var _commands: Array[Command] = []
var _moves: Dictionary = {}
var _finisher: Command = null
var _summon_slot := -1
var _intent := Intent.new()
var _consumed := -1
## Rank of the input that started the current move (0 for a normal), or -1 if
## it cannot be replaced; and what had been consumed before it started.
var _started_rank := -1
var _consumed_before_start := -1


func _init(def: FighterDefinition, bound: Array[FighterDefinition] = []) -> void:
	definition = def
	spirits = bound
	for s in spirits:
		assert(def.binds(s), "%s cannot bind %s" % [def.display_name, s.display_name])
	_moves = def.moves.duplicate()
	for pattern in def.commands:
		_commands.append(Command.parse(pattern, def.commands[pattern]))
	for slot in mini(spirits.size(), SUMMON_COMMANDS.size()):
		var id := StringName("summon_%d" % slot)
		_moves[id] = def.summon_move
		_commands.append(Command.parse(SUMMON_COMMANDS[slot], id))
	_commands.sort_custom(func(a: Command, b: Command) -> bool: return a.rank() > b.rank())
	if def.finisher_command != "":
		_moves[FINISHER] = def.finisher_move
		_finisher = Command.parse(def.finisher_command, FINISHER)


func reset(x: float, face: int) -> void:
	input = InputHistory.new()
	input.chord = chord_window
	position = Vector2(x, FLOOR_Y)
	velocity = Vector2.ZERO
	slide = 0.0
	facing = face
	health = definition.max_health
	state = State.STAND
	state_frame = 0
	stun = 0
	move = null
	move_connected = false
	move_reversed = false
	airborne = false
	crouching = false
	holding_back = false
	air_move_used = false
	threatened = false
	live_spawns = []
	awaiting_finisher = false
	pending_spawn = null
	pending_summon = -1
	pending_heal = 0
	pending_teleport = 0.0
	move_cooldowns.clear()
	spirit_threatened = false
	cooldowns.assign(spirits.map(func(_s: FighterDefinition) -> int: return 0))
	_summon_slot = -1
	_intent = Intent.new()
	_consumed = -1
	_started_rank = -1


func set_chord_window(frames: int) -> void:
	chord_window = frames
	input.chord = frames


func guard_held() -> bool:
	return (_intent.held & Intent.GUARD) == Intent.GUARD


func spirit_guard_held() -> bool:
	return (_intent.held & Intent.SPIRIT_GUARD) == Intent.SPIRIT_GUARD


func heal(amount: int) -> void:
	health = mini(health + amount, definition.max_health)


func can_turn() -> bool:
	return not airborne and state in [State.STAND, State.WALK, State.CROUCH, State.GUARD]


func actionable() -> bool:
	return can_turn()


func face_toward(x: float) -> void:
	if can_turn() and x != position.x:
		facing = 1 if x > position.x else -1


## Called every frame, including frames frozen by hitstop, so input made
## during hitstop is not lost.
func record(intent: Intent) -> void:
	_intent = intent
	input.push(intent)


## Starts a move directly, as a spirit does when summoned.
func perform(id: StringName) -> void:
	_start(id)


func step() -> void:
	state_frame += 1
	pending_spawn = null
	pending_summon = -1
	pending_heal = 0
	pending_teleport = 0.0
	for slot in cooldowns.size():
		cooldowns[slot] = maxi(cooldowns[slot] - 1, 0)
	for id in move_cooldowns:
		move_cooldowns[id] = maxi(move_cooldowns[id] - 1, 0)
	holding_back = _intent.x == -facing
	if state in [State.STAND, State.WALK, State.CROUCH, State.GUARD, State.BLOCKSTUN]:
		crouching = _intent.down

	match state:
		State.STAND, State.WALK, State.CROUCH, State.GUARD:
			_act_on_ground()
		State.JUMP:
			_act_in_air()
		State.MOVE:
			_continue_move()
		State.HITSTUN, State.BLOCKSTUN:
			stun -= 1
			if stun <= 0 and not airborne:
				_set_state(State.STAND)
		State.KNOCKDOWN:
			if not airborne:
				stun -= 1
				if stun <= 0:
					_set_state(State.STAND)
		State.GRABBED, State.DAZED, State.SEALED, State.KO:
			pass

	if state == State.MOVE and state_frame == move.startup:
		if move.spawn:
			pending_spawn = move.spawn
		if _summon_slot >= 0:
			pending_summon = _summon_slot
			cooldowns[_summon_slot] = spirits[_summon_slot].spirit_cooldown
		pending_heal = move.heal
	if state == State.MOVE and state_frame == move.teleport_frame:
		pending_teleport = move.teleport_distance
	_integrate()


## `from_spirit`: the hit comes from a spirit or a spirit's projectile, and
## only spirit guard stops it.
func receive(m: MoveDefinition, from_facing: int, from_spirit := false) -> void:
	var held := spirit_guard_held() if from_spirit else guard_held()
	var guarding := not m.throw and not airborne and held \
			and state in [State.GUARD, State.BLOCKSTUN]
	var unguardable := MoveDefinition.Height.HIGH if crouching else MoveDefinition.Height.LOW
	move = null
	_started_rank = -1
	if guarding and m.height != unguardable:
		stun = m.blockstun
		slide = from_facing * m.knockback
		_set_state(State.BLOCKSTUN, true)
		return

	if not invincible:
		health = maxi(health - m.damage, 0)
	if airborne:
		velocity = Vector2(from_facing * m.knockback * 0.5, minf(velocity.y, -6.0))
	else:
		slide = from_facing * m.knockback
	if health == 0:
		_set_state(State.KO, true)
	elif m.knockdown > 0:
		stun = m.knockdown
		_set_state(State.KNOCKDOWN, true)
	else:
		stun = m.hitstun
		_set_state(State.HITSTUN, true)


## Held by a throw while the victim may still escape it.
func grabbed() -> void:
	_halt()
	_set_state(State.GRABBED, true)


## Both fighters separate after an escaped throw.
func release_from_throw(away: int) -> void:
	_halt()
	stun = TECH_STUN
	slide = away * TECH_PUSH
	_set_state(State.BLOCKSTUN, true)


## Beaten in the deciding round by someone who may seal this fighter's spirit.
func daze() -> void:
	_halt()
	crouching = false
	_set_state(State.DAZED, true)


func seal() -> void:
	_halt()
	_set_state(State.SEALED, true)


func collapse() -> void:
	_halt()
	_set_state(State.KO, true)


func invulnerable() -> bool:
	return state in [State.KNOCKDOWN, State.DAZED, State.SEALED] \
			or (state == State.MOVE and state_frame < move.invulnerable)


func throwable() -> bool:
	return not airborne and not invulnerable() \
			and state in [State.STAND, State.WALK, State.CROUCH, State.GUARD, State.MOVE]


## Whether this fighter's current move still has hits to come.
func threatening() -> bool:
	return state == State.MOVE and (not move.hitboxes.is_empty() or move.spawn != null) \
			and state_frame < move.startup + move.active


func performing_finisher() -> bool:
	return state == State.MOVE and _finisher != null and move == _moves[FINISHER]


func hurtbox() -> Rect2:
	if airborne:
		return to_world(definition.air_hurtbox)
	return to_world(definition.crouch_hurtbox if crouching else definition.stand_hurtbox)


func pushbox() -> Rect2:
	return to_world(definition.pushbox)


func active_hitboxes() -> Array[Rect2]:
	var boxes: Array[Rect2] = []
	if state == State.MOVE and not move_connected and move.is_active_on(state_frame):
		for box in move.hitboxes:
			boxes.append(to_world(box))
	return boxes


func to_world(local: Rect2) -> Rect2:
	return MoveDefinition.place(local, position, facing)


func _act_on_ground() -> void:
	if awaiting_finisher:
		if input.matches(_finisher, facing, _consumed):
			_start(FINISHER)
		else:
			_walk(1.0)
			_set_state(State.WALK if _intent.x != 0 else State.STAND)
		return
	if guard_held():
		_guard()
		return
	var cmd := _matching_command(false, _consumed, -1)
	if cmd:
		if _available(cmd):
			_start_by(cmd.move, cmd.rank(), _consumed)
		else:
			# Asking for something unavailable spends the input; it does not
			# fall through to a lesser command.
			_consumed = input.frame
		return
	var button := _pressed_normal()
	if button != "":
		_start_by(StringName(("crouch_" if crouching else "stand_") + button), 0, _consumed)
		return
	if _intent.up:
		crouching = false
		airborne = true
		air_move_used = false
		velocity = Vector2(_intent.x * definition.jump_forward, -definition.jump_velocity)
		_set_state(State.JUMP)
		return
	if crouching:
		_walk(definition.crawl_factor)
		_set_state(State.CROUCH)
	else:
		_walk(1.0)
		_set_state(State.WALK if _intent.x != 0 else State.STAND)


func _walk(factor: float) -> void:
	if _intent.x != 0:
		var speed := definition.walk_back if holding_back else definition.walk_forward
		position.x += _intent.x * speed * factor


func _act_in_air() -> void:
	if air_move_used:
		return
	var button := _pressed_normal()
	if button != "":
		air_move_used = true
		_start(StringName("jump_" + button))


## Guarding spends any attack presses made while the chord is held, so
## nothing fires on release.
func _guard() -> void:
	_consumed = input.frame
	_walk(definition.guard_factor)
	_set_state(State.GUARD)


## While a move started from input has not yet become active, and within the
## chord window, completing the guard chord or a higher-ranked command
## replaces it. Buttons and directions meant together need not land on one
## frame.
func _continue_move() -> void:
	if _started_rank >= 0 and state_frame < input.chord and state_frame < move.startup:
		if guard_held():
			_halt()
			_guard()
			return
		var cmd := _matching_command(true, _consumed_before_start, _started_rank)
		if cmd and _available(cmd):
			_start_by(cmd.move, cmd.rank(), _consumed_before_start)
			return
	if state_frame >= move.total_frames():
		move = null
		_set_state(State.JUMP if airborne else State.STAND)


## The highest-ranked command matching the input, above `above_rank`.
func _matching_command(buttons_only: bool, after: int, above_rank: int) -> Command:
	for cmd in _commands:
		if cmd.rank() <= above_rank:
			break
		if buttons_only and cmd.buttons == 0:
			continue
		if input.matches(cmd, facing, after):
			return cmd
	return null


func _available(cmd: Command) -> bool:
	var m: MoveDefinition = _moves[cmd.move]
	if m.spawn and m.spawn in live_spawns:
		return false
	if move_cooldowns.get(m.id, 0) > 0:
		return false
	var slot := _summon_ids().find(cmd.move)
	return slot < 0 or cooldowns[slot] == 0


func _pressed_normal() -> String:
	if input.pressed(InputHistory.B, _consumed) >= 0:
		return "heavy"
	if input.pressed(InputHistory.A, _consumed) >= 0:
		return "light"
	return ""


func _summon_ids() -> Array:
	return range(cooldowns.size()).map(func(slot: int) -> StringName: return StringName("summon_%d" % slot))


func _start_by(id: StringName, rank: int, consumed_before: int) -> void:
	_start(id)
	_started_rank = rank
	_consumed_before_start = consumed_before


func _start(id: StringName) -> void:
	move = _moves[id]
	_summon_slot = _summon_ids().find(id)
	_consumed = input.frame
	_started_rank = -1
	move_connected = false
	move_reversed = holding_back
	if move.cooldown > 0:
		move_cooldowns[move.id] = move.cooldown
	if move.motion.y < 0.0:
		airborne = true
		air_move_used = true
		crouching = false
		velocity = Vector2(facing * move.motion.x, move.motion.y)
	elif move.motion.x != 0.0 and not airborne:
		slide = facing * move.motion.x
	_set_state(State.MOVE, true)


func _halt() -> void:
	move = null
	_started_rank = -1
	slide = 0.0


func _integrate() -> void:
	if airborne:
		velocity.y += definition.gravity
		position += velocity
		if position.y >= FLOOR_Y:
			position.y = FLOOR_Y
			velocity = Vector2.ZERO
			airborne = false
			_on_land()
	else:
		position.x += slide
		slide = move_toward(slide, 0.0, SLIDE_DECEL)


func _on_land() -> void:
	var launched := state == State.MOVE and move.motion.y < 0.0
	if state == State.JUMP or (state == State.MOVE and not launched):
		move = null
		_set_state(State.STAND)
	elif state == State.HITSTUN and stun <= 0:
		_set_state(State.STAND)


func _set_state(s: State, restart := false) -> void:
	if s != state or restart:
		state = s
		state_frame = 0
