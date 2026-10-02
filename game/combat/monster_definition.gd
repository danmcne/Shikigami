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

	func _init(part_name: String, local_box: Rect2, scale := 1.0, part_health := 0, is_hidden := false) -> void:
		name = part_name
		box = local_box
		damage_scale = scale
		health = part_health
		hidden = is_hidden


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
