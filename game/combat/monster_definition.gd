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
	## Its top edge is a surface fighters can land and stand on. Keep the
	## monster's pushbox below it, or it shoves off anyone landing there.
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
	## Velocity during the active frames: x along its facing, y downward (a
	## charge, a dive). It stops at the ground.
	var travel := Vector2.ZERO
	## No pushbox during the active frames, so it passes through or under.
	var pushless := false
	## Hidden parts this attack leaves open during its recovery.
	var exposes: Array[String] = []
	## Parts that must be unbroken for this attack to be used, and parts that
	## must be broken (a grounded phase).
	var requires: Array[String] = []
	var needs_broken: Array[String] = []
	## Used only while someone stands on the monster (to throw them off).
	var ridden_only := false
	## Used only with the opponent on this side of the monster (-1 left,
	## +1 right; 0 either), or in this half of the stage.
	var side := 0
	var stage_half := 0
	## Performed straight after this one, without rest (the mouth that comes
	## down after a hand has swept its catch beneath it).
	var follow_up: Attack = null


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
## Frames an opponent must stay behind it before it turns round. A monster
## that doesn't turn keeps facing right, so its parts' left and right are the
## stage's, and it drifts toward its opponent either way.
var turn_delay := 60
var turns := true
## Whoever fights it turns by input rather than to face it, and guard covers
## only the side they face.
var free_facing := false
## Fought in a circular arena this long (no walls); zero for the walled stage.
var arena_length := 0.0
## Struck by the finisher while it lies beaten: where its core is.
var core := Rect2()
## A flying monster hovers this high between attacks while its flight part is
## unbroken; once that part breaks it is grounded for good.
var altitude := 0.0
var flight_part := ""
var climb_speed := 4.0
## If the seal is missed, the core reforms with this share of its health.
var reform_fraction := 0.25
