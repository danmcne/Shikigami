class_name MonsterDefinition
extends RefCounted
## A monster as data: a body made of parts, a set of attacks chosen by
## weight and distance, and how it moves between them. Monster interprets it.
##
## Attacks are ordinary MoveDefinitions, so a monster's start-up, active and
## recovery frames, hitboxes, heights, knockdowns and projectiles follow the
## same rules as a fighter's. Its start-up doubles as the telegraph: the view
## shows where the hitboxes will land before they do.


## One region of the body. Every hit lands on a part. A part with health can
## be broken, which may change what the monster can do; a hidden part can be
## struck only while an attack exposes it.
class Part:
	var name: String
	var box: Rect2
	var damage_scale := 1.0
	var health := 0
	var hidden := false
	## Its top edge is a surface fighters can land and stand on.
	var standable := false
	## How far above its box it can still be struck, so that a fighter
	## standing on it hits what it stands on.
	var reach_above := 0.0
	## For drawing only: where a hidden part is shown while it can't be struck
	## (a giant's hand raised out of reach).
	var rest_offset := Vector2.ZERO

	func _init(part_name: String, local_box: Rect2, scale := 1.0, part_health := 0, is_hidden := false,
			can_stand := false, above := 0.0) -> void:
		name = part_name
		box = local_box
		damage_scale = scale
		health = part_health
		hidden = is_hidden
		standable = can_stand
		reach_above = above


class Attack:
	var move: MoveDefinition
	## Relative likelihood when it can be used, and when the monster is crippled
	## (some breakable part broken).
	var weight := 1.0
	var crippled_weight := 1.0
	## Usable only with the opponent's distance from the body's edge in range.
	var min_gap := -INF
	var max_gap := INF
	## Speed along its facing during the active frames (a charge).
	var travel := 0.0
	## No pushbox during the active frames, so it passes through or under.
	var pushless := false
	## Hidden parts this attack leaves open during its recovery.
	var exposes: Array[String] = []
	## Parts that must be unbroken for this attack to be used.
	var requires: Array[String] = []
	## Used only while someone stands on the monster (to throw them off).
	var ridden_only := false


## The body as a fighter sees it: name, kind MONSTER, health, pushbox, and a
## stand hurtbox used for drawing and for health shares.
var body: FighterDefinition
var parts: Array = []
var attacks: Array = []
var walk_speed := 1.5
## Frames between attacks, and how long a broken part staggers it.
var rest := 40
var stagger := 60
## It stops walking closer than this gap.
var close_gap := 80.0
## For drawing only: faint shapes behind its parts (a giant's ribs and spine),
## and the colour of its parts.
var backdrop: Array[Rect2] = []
var colour := Color(0.55, 0.3, 0.2)
## Frames an opponent must stay behind it before it turns round.
var turn_delay := 60
