class_name FighterDefinition
extends Resource
## Everything that distinguishes one fighter from another. No behaviour lives
## here; the same definition drives campaign, versus and training.
##
## Boxes use the same local space as AttackDefinition. The pushbox is assumed
## symmetric about x = 0.

@export var id: StringName
@export var display_name: String
@export var max_health: int = 1000
@export var walk_forward: float = 4.0
@export var walk_back: float = 3.0
@export var jump_velocity: float = 18.0
@export var jump_forward: float = 4.5
@export var gravity: float = 0.9
@export var stand_hurtbox: Rect2
@export var crouch_hurtbox: Rect2
@export var air_hurtbox: Rect2
@export var pushbox: Rect2
## Keyed by stance and button: &"stand_light", &"crouch_heavy", &"jump_light", ...
@export var attacks: Dictionary = {}
