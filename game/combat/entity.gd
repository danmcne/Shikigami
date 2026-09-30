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


func _init(m: MoveDefinition, source: Fighter, index: int) -> void:
	move = m
	owner_index = index
	facing = source.facing
	var offset := source.move.spawn_offset
	position = source.position + Vector2(facing * offset.x, offset.y)


func step() -> void:
	frame += 1
	position += Vector2(facing * move.motion.x, move.motion.y)
	if frame >= move.total_frames():
		spent = true


func active_hitboxes() -> Array[Rect2]:
	var boxes: Array[Rect2] = []
	if not spent and move.is_active_on(frame):
		for box in move.hitboxes:
			boxes.append(MoveDefinition.place(box, position, facing))
	return boxes
