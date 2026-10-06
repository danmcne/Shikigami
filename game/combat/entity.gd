class_name Entity
extends RefCounted
## A body-less performer of a single move: a projectile now, a bound spirit
## later. It travels at the move's constant motion, its hitboxes follow the
## move's frame timing, and it is spent when the move ends or when it hits.

var move: MoveDefinition
var owner_index: int
var position: Vector2
var facing: int
var frame := 0
var spent := false
## Current velocity: x along its facing, y downward.
var velocity := Vector2.ZERO
## The move that first sent this piece out: for a piece left behind (a jet's
## wave), the one that left it, so it still counts as that projectile.
var origin: MoveDefinition
## Released by a spirit: only spirit guard stops it.
var from_spirit := false
## For a converging piece: the centreline it travels to, and whether it has
## arrived.
var centre_x := 0.0
var arrived := false
## A fighter this piece has seized and carries, or is pushing while they guard.
var holding: Fighter = null
var pushing: Fighter = null
## A returning piece: heading back along the path it took.
var returning := false
var _centre := Vector2.ZERO
var _angle := 0.0
## Frames retraced per frame on the way back.
const RETURN_SPEED := 2
var _path := PackedVector2Array()


func _init(m: MoveDefinition, at: Vector2, face: int, index: int, spirit := false) -> void:
	move = m
	owner_index = index
	position = at
	facing = face
	from_spirit = spirit
	velocity = m.motion
	origin = m
	if m.orbit_radius > 0.0:
		_centre = at + Vector2(face * m.orbit_centre.x, m.orbit_centre.y)
		_angle = atan2(-m.orbit_centre.y, -m.orbit_centre.x)


func step() -> void:
	frame += 1
	if returning:
		for k in RETURN_SPEED:
			if _path.is_empty():
				spent = true
				return
			position = _path[_path.size() - 1]
			_path.remove_at(_path.size() - 1)
		return
	if move.returns:
		_path.append(position)
	if move.orbit_radius > 0.0:
		_angle += move.orbit_speed
		var was := position
		position = _centre + Vector2(facing * cos(_angle), sin(_angle)) * move.orbit_radius
		velocity = Vector2((position.x - was.x) * facing, position.y - was.y)
	elif not arrived:
		position += Vector2(facing * velocity.x, velocity.y)
		velocity.y += move.gravity
		if move.converges and (centre_x - position.x) * facing <= 0.0:
			position.x = centre_x
			arrived = true
	if frame >= move.total_frames():
		spent = true
	if move.returns and velocity.y > 0.0 and position.y >= move.turn_height:
		turn_back()
	elif (move.gravity > 0.0 or velocity.y > 0.0) and position.y >= 0.0:
		# Whatever falls or is driven downward ends on meeting the ground.
		spent = true


## Head back along the path taken.
func turn_back() -> void:
	returning = true


## Its boxes in the world whether or not they can strike now.
func boxes() -> Array[Rect2]:
	var out: Array[Rect2] = []
	for box in move.hitboxes:
		out.append(MoveDefinition.place(box, position, facing))
	return out


## How far it moved along x on its last step (zero once arrived).
func last_step_x() -> float:
	return 0.0 if arrived else facing * velocity.x


func active_hitboxes() -> Array[Rect2]:
	var boxes: Array[Rect2] = []
	if not spent and not returning and move.is_active_on(frame):
		for box in move.hitboxes:
			boxes.append(MoveDefinition.place(box, position, facing))
	return boxes
