class_name FighterDefinition
extends Resource
## Everything that distinguishes one fighter from another. No behaviour lives
## here; the same definition drives campaign, versus and training.
##
## Boxes use the same local space as MoveDefinition. The pushbox is assumed
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
## What this fighter does when bound as someone else's spirit: one of its own
## moves, performed by a body-less copy of it.
@export var spirit_move: StringName
@export var spirit_cooldown: int = 300
## Where the copy appears, relative to the summoner (+x toward the opponent).
@export var spirit_offset: Vector2 = Vector2.ZERO
