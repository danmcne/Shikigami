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
## Released by a spirit: only spirit guard stops it.
var from_spirit := false
## For a converging piece: the centreline it travels to, and whether it has
## arrived.
var centre_x := 0.0
var arrived := false
## A fighter this piece has seized and carries, or is pushing while they guard.
var holding: Fighter = null
var pushing: Fighter = null


func _init(m: MoveDefinition, at: Vector2, face: int, index: int, spirit := false) -> void:
	move = m
	owner_index = index
	position = at
	facing = face
	from_spirit = spirit
	velocity = m.motion


func step() -> void:
	frame += 1
	if not arrived:
		position += Vector2(facing * velocity.x, velocity.y)
		velocity.y += move.gravity
		if move.converges and (centre_x - position.x) * facing <= 0.0:
			position.x = centre_x
			arrived = true
	if frame >= move.total_frames():
		spent = true
	if move.gravity > 0.0 and position.y >= 0.0:
		spent = true


## How far it moved along x on its last step (zero once arrived).
func last_step_x() -> float:
	return 0.0 if arrived else facing * velocity.x


func active_hitboxes() -> Array[Rect2]:
	var boxes: Array[Rect2] = []
	if not spent and move.is_active_on(frame):
		for box in move.hitboxes:
			boxes.append(MoveDefinition.place(box, position, facing))
	return boxes
