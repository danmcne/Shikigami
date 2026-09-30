class_name AttackDefinition
extends Resource
## One attack, described entirely as data.
##
## Time is in frames (60 per second). Boxes are in the fighter's local space:
## origin at the feet, +x toward the opponent, -y upward.

## Which guard stops the attack. Standing guard stops MID and HIGH;
## crouching guard stops MID and LOW.
enum Height { HIGH, MID, LOW }

@export var id: StringName
## Frames before the first active frame.
@export var startup: int = 5
## Frames during which the hitboxes exist.
@export var active: int = 3
## Frames after the last active frame before the fighter can act again.
@export var recovery: int = 10
@export var damage: int = 50
@export var hitstun: int = 15
@export var blockstun: int = 10
## Initial ground-slide speed given to the defender, in px/frame.
@export var knockback: float = 6.0
## Frames both fighters freeze when this attack connects.
@export var hitstop: int = 6
@export var height: Height = Height.MID
@export var hitboxes: Array[Rect2] = []


func total_frames() -> int:
	return startup + active + recovery


func is_active_on(frame: int) -> bool:
	return frame >= startup and frame < startup + active
