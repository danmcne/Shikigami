class_name MoveDefinition
extends Resource
## One action, described entirely as data: a normal, a special, a throw, a
## dash, or what a projectile does once released.
##
## Time is in frames (60 per second). Boxes and vectors are in the performer's
## local space: origin at the feet, +x toward the opponent, -y upward.

## Which guard stops the move. Standing guard stops MID and HIGH;
## crouching guard stops MID and LOW; nothing stops HIGH_LOW, which strikes
## high and low together.
enum Height { HIGH, MID, LOW, HIGH_LOW }

@export var id: StringName
## Frames before the first active frame.
@export var startup: int = 5
## Frames during which the hitboxes exist.
@export var active: int = 3
## Frames after the last active frame before the performer can act again.
@export var recovery: int = 10
@export var damage: int = 50
@export var hitstun: int = 15
@export var blockstun: int = 10
## Initial ground-slide speed given to the defender, in px/frame.
@export var knockback: float = 6.0
## Frames both fighters freeze when this move connects.
@export var hitstop: int = 6
@export var height: Height = Height.MID
@export var hitboxes: Array[Rect2] = []
## Grabs instead of striking: cannot be guarded, connects only with a grounded
## opponent who is not stunned, and loses to a strike landing on the same frame.
@export var throw: bool = false
## Nonzero: the defender is knocked down for this many frames (counted once
## grounded, invulnerable throughout) instead of taking hitstun.
@export var knockdown: int = 0
## Frames from the start during which the performer has no hurtbox.
@export var invulnerable: int = 0
## Velocity given on the first frame. For a fighter, x becomes a decelerating
## ground slide and negative y launches it into the air; a launched move keeps
## running after landing, so its recovery happens on the ground. For a spawned
## entity, this is a constant velocity.
@export var motion: Vector2 = Vector2.ZERO
## Released on the first active frame, at spawn_offset: a projectile now,
## a bound spirit later.
@export var spawn: MoveDefinition
@export var spawn_offset: Vector2 = Vector2.ZERO
## Health restored on the first active frame: to the performer, or, for a
## spirit, to the fighter who summoned it.
@export var heal: int = 0
## On this frame the performer reappears `teleport_distance` behind its
## opponent, facing them. -1: no teleport.
@export var teleport_frame: int = -1
@export var teleport_distance: float = 70.0
## Frames before this move can be used again. Zero: no recharge.
@export var cooldown: int = 0
## Frames of armour granted when the move starts: hits still deal damage but
## do not interrupt. Throws ignore armour. A spirit's armour goes to its
## summoner.
@export var armor: int = 0
## On a hit that is not guarded, slows the target's walking and jumping for
## this many frames.
@export var slows: int = 0
## A counter stance: if struck by a strike while this move is active, the hit
## is ignored and the performer does `counter` instead.
@export var counter: MoveDefinition
## May be performed in the air as well as on the ground.
@export var air: bool = false


func total_frames() -> int:
	return startup + active + recovery


func is_active_on(frame: int) -> bool:
	return frame >= startup and frame < startup + active


## A local box placed in the world for a performer at `origin` facing `facing`.
static func place(local: Rect2, origin: Vector2, facing: int) -> Rect2:
	var x := local.position.x if facing == 1 else -local.position.x - local.size.x
	return Rect2(origin + Vector2(x, local.position.y), local.size)
