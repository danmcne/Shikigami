class_name FighterDefinition
extends Resource
## Everything that distinguishes one fighter from another. No behaviour lives
## here; the same definition drives campaign, versus and training.
##
## Boxes use the same local space as MoveDefinition. The pushbox is assumed
## symmetric about x = 0.

## Humans bind yokai spirits and yokai bind human spirits, never their own
## kind. Monsters are neither and are never bound.
enum Kind { HUMAN, YOKAI, MONSTER }

@export var id: StringName
@export var display_name: String
@export var kind: Kind = Kind.HUMAN
@export var max_health: int = 1000
## How far from the opponent this fighter prefers to fight (the computer plays
## it there); zero for fighting at close quarters. A trait of those built to
## fight at range.
@export var preferred_gap: float = 0.0
@export var walk_forward: float = 4.0
@export var walk_back: float = 3.0
@export var jump_velocity: float = 18.0
@export var jump_forward: float = 4.5
@export var gravity: float = 0.9
## Walking speed multipliers while crouching and while guarding.
@export var crawl_factor: float = 0.5
@export var guard_factor: float = 0.4
@export var stand_hurtbox: Rect2
@export var crouch_hurtbox: Rect2
@export var air_hurtbox: Rect2
@export var pushbox: Rect2
## All moves by id. Normals are found by stance and button:
## &"stand_light", &"crouch_heavy", &"jump_light", ...
@export var moves: Dictionary = {}
## Command pattern -> move id, e.g. {"236C": &"projectile", "AB": &"throw"}.
## Grammar in command.gd. Summon commands ("D", "2D") are added by the game.
@export var commands: Dictionary = {}

@export_group("Spirit")
## The gesture this fighter makes to summon a bound spirit. The spirit appears
## on its first active frame.
@export var summon_move: MoveDefinition
## This fighter's two specials, on special and on away + special. Both
## recharge. When this fighter is bound as a spirit, its binder chooses which
## of the two the spirit performs.
@export var specials: Array[StringName] = []
@export var spirit_cooldown: int = 300
## Where the copy appears, relative to the summoner (+x toward the opponent).
@export var spirit_offset: Vector2 = Vector2.ZERO

@export_group("Finisher")
## Performed (with the same input for everyone, Fighter.FINISHER_COMMAND) on a
## beaten opponent whose spirit this fighter can bind; if it connects, the
## spirit is bound. No move: no finisher.
@export var finisher_move: MoveDefinition


func binds(other: FighterDefinition) -> bool:
	return (kind == Kind.HUMAN and other.kind == Kind.YOKAI) or (kind == Kind.YOKAI and other.kind == Kind.HUMAN)
