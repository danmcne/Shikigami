class_name Fighter
extends RefCounted
## One fighter's simulation state. Pure logic: no nodes, no drawing, no input.
## Advanced exactly one frame per step() by the Bout that owns it.

enum State { STAND, WALK, CROUCH, JUMP, ATTACK, HITSTUN, BLOCKSTUN, KO }

const FLOOR_Y := 0.0
## A button press is remembered this many frames, so a press made slightly
## before the fighter can act still comes out.
const BUFFER_FRAMES := 5
## Deceleration of ground slide (knockback, blockback), in px/frame².
const SLIDE_DECEL := 0.5

var definition: FighterDefinition
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
var attack: AttackDefinition = null
var attack_connected := false
var airborne := false
var crouching := false
var holding_back := false
var air_attack_used := false
## Set by the Bout each frame: the opponent is mid-attack. Holding back while
## threatened guards in place instead of walking away.
var threatened := false

var _light_buffer := 0
var _heavy_buffer := 0


func _init(def: FighterDefinition) -> void:
	definition = def


func reset(x: float, face: int) -> void:
	position = Vector2(x, FLOOR_Y)
	velocity = Vector2.ZERO
	slide = 0.0
	facing = face
	health = definition.max_health
	state = State.STAND
	state_frame = 0
	stun = 0
	attack = null
	attack_connected = false
	airborne = false
	crouching = false
	holding_back = false
	air_attack_used = false
	threatened = false
	_light_buffer = 0
	_heavy_buffer = 0


func can_turn() -> bool:
	return not airborne and state in [State.STAND, State.WALK, State.CROUCH]


func face_toward(x: float) -> void:
	if can_turn() and x != position.x:
		facing = 1 if x > position.x else -1


func step(intent: Intent) -> void:
	state_frame += 1
	_light_buffer = BUFFER_FRAMES if intent.light else maxi(_light_buffer - 1, 0)
	_heavy_buffer = BUFFER_FRAMES if intent.heavy else maxi(_heavy_buffer - 1, 0)
	holding_back = intent.x == -facing
	if state in [State.STAND, State.WALK, State.CROUCH, State.BLOCKSTUN]:
		crouching = intent.down

	match state:
		State.STAND, State.WALK, State.CROUCH:
			_act_on_ground(intent)
		State.JUMP:
			_act_in_air()
		State.ATTACK:
			if state_frame >= attack.total_frames():
				attack = null
				_set_state(State.JUMP if airborne else State.STAND)
		State.HITSTUN, State.BLOCKSTUN:
			stun -= 1
			if stun <= 0 and not airborne:
				_set_state(State.STAND)
		State.KO:
			pass

	_integrate()


func receive(atk: AttackDefinition, from_facing: int) -> void:
	var guarding := not airborne and holding_back \
			and state in [State.STAND, State.WALK, State.CROUCH, State.BLOCKSTUN]
	var unguardable := AttackDefinition.Height.HIGH if crouching else AttackDefinition.Height.LOW
	attack = null
	if guarding and atk.height != unguardable:
		stun = atk.blockstun
		slide = from_facing * atk.knockback
		_set_state(State.BLOCKSTUN, true)
		return

	health = maxi(health - atk.damage, 0)
	stun = atk.hitstun
	if airborne:
		velocity = Vector2(from_facing * atk.knockback * 0.5, minf(velocity.y, -6.0))
	else:
		slide = from_facing * atk.knockback
	_set_state(State.KO if health == 0 else State.HITSTUN, true)


func hurtbox() -> Rect2:
	if airborne:
		return to_world(definition.air_hurtbox)
	return to_world(definition.crouch_hurtbox if crouching else definition.stand_hurtbox)


func pushbox() -> Rect2:
	return to_world(definition.pushbox)


func active_hitboxes() -> Array[Rect2]:
	var boxes: Array[Rect2] = []
	if state == State.ATTACK and not attack_connected and attack.is_active_on(state_frame):
		for box in attack.hitboxes:
			boxes.append(to_world(box))
	return boxes


func to_world(local: Rect2) -> Rect2:
	var x := local.position.x if facing == 1 else -local.position.x - local.size.x
	return Rect2(position + Vector2(x, local.position.y), local.size)


func _act_on_ground(intent: Intent) -> void:
	if _heavy_buffer > 0 or _light_buffer > 0:
		var button := "heavy" if _heavy_buffer > 0 else "light"
		_start_attack(("crouch_" if crouching else "stand_") + button)
		return
	if intent.up:
		crouching = false
		airborne = true
		air_attack_used = false
		velocity = Vector2(intent.x * definition.jump_forward, -definition.jump_velocity)
		_set_state(State.JUMP)
		return
	if crouching:
		_set_state(State.CROUCH)
	elif intent.x == 0 or (holding_back and threatened):
		_set_state(State.STAND)
	else:
		var speed := definition.walk_back if holding_back else definition.walk_forward
		position.x += intent.x * speed
		_set_state(State.WALK)


func _act_in_air() -> void:
	if air_attack_used:
		return
	if _heavy_buffer > 0 or _light_buffer > 0:
		air_attack_used = true
		_start_attack("jump_heavy" if _heavy_buffer > 0 else "jump_light")


func _start_attack(key: String) -> void:
	_light_buffer = 0
	_heavy_buffer = 0
	attack = definition.attacks[StringName(key)]
	attack_connected = false
	_set_state(State.ATTACK, true)


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
	if state == State.JUMP or state == State.ATTACK:
		attack = null
		_set_state(State.STAND)
	elif state == State.HITSTUN and stun <= 0:
		_set_state(State.STAND)


func _set_state(s: State, restart := false) -> void:
	if s != state or restart:
		state = s
		state_frame = 0
