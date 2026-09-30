class_name Fighter
extends RefCounted
## One fighter's simulation state. Pure logic: no nodes, no drawing, no input
## devices. The Bout records each frame's Intent, then steps the fighter.

enum State { STAND, WALK, CROUCH, JUMP, MOVE, HITSTUN, BLOCKSTUN, KNOCKDOWN, KO }

const FLOOR_Y := 0.0
## Deceleration of ground slide (knockback, blockback, dashes), in px/frame².
const SLIDE_DECEL := 0.5
## For this many frames after a normal starts, a throw or special that now
## matches replaces it. Buttons meant together need not land on one frame.
const LENIENCY := 2

var definition: FighterDefinition
var input := InputHistory.new()
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
## Set by the Bout each frame.
var threatened := false
var has_projectile := false
## Set by step() on the frame a move releases something for the Bout to spawn.
var pending_spawn: MoveDefinition = null

var _commands: Array[Command] = []
var _intent := Intent.new()
var _consumed := -1
var _from_normal := false
var _consumed_before_normal := -1


func _init(def: FighterDefinition) -> void:
	definition = def
	for pattern in def.commands:
		_commands.append(Command.parse(pattern, def.commands[pattern]))
	_commands.sort_custom(func(a: Command, b: Command) -> bool: return a.rank() > b.rank())


func reset(x: float, face: int) -> void:
	input = InputHistory.new()
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
	has_projectile = false
	pending_spawn = null
	_intent = Intent.new()
	_consumed = -1
	_from_normal = false


func can_turn() -> bool:
	return not airborne and state in [State.STAND, State.WALK, State.CROUCH]


func face_toward(x: float) -> void:
	if can_turn() and x != position.x:
		facing = 1 if x > position.x else -1


## Called every frame, including frames frozen by hitstop, so input made
## during hitstop is not lost.
func record(intent: Intent) -> void:
	_intent = intent
	input.push(intent)


func step() -> void:
	state_frame += 1
	pending_spawn = null
	holding_back = _intent.x == -facing
	if state in [State.STAND, State.WALK, State.CROUCH, State.BLOCKSTUN]:
		crouching = _intent.down

	match state:
		State.STAND, State.WALK, State.CROUCH:
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
		State.KO:
			pass

	if state == State.MOVE and move.spawn and state_frame == move.startup:
		pending_spawn = move.spawn
	_integrate()


func receive(m: MoveDefinition, from_facing: int) -> void:
	var guarding := not m.throw and not airborne and holding_back \
			and state in [State.STAND, State.WALK, State.CROUCH, State.BLOCKSTUN]
	var unguardable := MoveDefinition.Height.HIGH if crouching else MoveDefinition.Height.LOW
	move = null
	_from_normal = false
	if guarding and m.height != unguardable:
		stun = m.blockstun
		slide = from_facing * m.knockback
		_set_state(State.BLOCKSTUN, true)
		return

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


func invulnerable() -> bool:
	return state == State.KNOCKDOWN or (state == State.MOVE and state_frame < move.invulnerable)


func throwable() -> bool:
	return not airborne and not invulnerable() \
			and state in [State.STAND, State.WALK, State.CROUCH, State.MOVE]


## Whether this fighter's current move still has hits to come.
func threatening() -> bool:
	return state == State.MOVE and (not move.hitboxes.is_empty() or move.spawn != null) \
			and state_frame < move.startup + move.active


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
	var cmd := _matching_command(false, _consumed)
	if cmd:
		_start(cmd.move)
		return
	var button := _pressed_normal()
	if button != "":
		var prior := _consumed
		_start(StringName(("crouch_" if crouching else "stand_") + button))
		_from_normal = true
		_consumed_before_normal = prior
		return
	if _intent.up:
		crouching = false
		airborne = true
		air_move_used = false
		velocity = Vector2(_intent.x * definition.jump_forward, -definition.jump_velocity)
		_set_state(State.JUMP)
		return
	if crouching:
		_set_state(State.CROUCH)
	elif _intent.x == 0 or (holding_back and threatened):
		_set_state(State.STAND)
	else:
		var speed := definition.walk_back if holding_back else definition.walk_forward
		position.x += _intent.x * speed
		_set_state(State.WALK)


func _act_in_air() -> void:
	if air_move_used:
		return
	var button := _pressed_normal()
	if button != "":
		air_move_used = true
		_start(StringName("jump_" + button))


func _continue_move() -> void:
	if _from_normal and state_frame <= LENIENCY:
		var cmd := _matching_command(true, _consumed_before_normal)
		if cmd:
			_start(cmd.move)
			return
	if state_frame >= move.total_frames():
		move = null
		_set_state(State.JUMP if airborne else State.STAND)


func _matching_command(buttons_only: bool, after: int) -> Command:
	for cmd in _commands:
		if buttons_only and cmd.buttons == 0:
			continue
		var m: MoveDefinition = definition.moves[cmd.move]
		if m.spawn and has_projectile:
			continue
		if input.matches(cmd, facing, after):
			return cmd
	return null


func _pressed_normal() -> String:
	if input.chord(InputHistory.B, _consumed) >= 0:
		return "heavy"
	if input.chord(InputHistory.A, _consumed) >= 0:
		return "light"
	return ""


func _start(id: StringName) -> void:
	move = definition.moves[id]
	_consumed = input.frame
	_from_normal = false
	move_connected = false
	move_reversed = holding_back
	if move.motion.y < 0.0:
		airborne = true
		air_move_used = true
		crouching = false
		velocity = Vector2(facing * move.motion.x, move.motion.y)
	elif move.motion.x != 0.0 and not airborne:
		slide = facing * move.motion.x
	_set_state(State.MOVE, true)


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
