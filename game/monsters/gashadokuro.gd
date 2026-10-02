extends RefCounted
## Gashadokuro, the giant skeleton raised from the bones of the unburied dead.
##
## It looms behind the stage, fifteen times a fighter's height, and has no
## body to bump into: you walk beneath it. It faces you and doesn't turn; its
## left and right hands are the stage's left and right. It drifts to keep you
## under one of them. Nothing of it can be struck at rest. A hand comes down
## to strike and stays on the ground a moment afterwards, open to attack and
## breakable. Its skull lowers to bite and stays low a moment, taking double
## damage. Each hand sweeps its own half of the stage; clapping needs both.
## Once a hand is broken, bones also rain down around you.
##
## Attacks, each telegraphed by its start-up:
##   Left / Right Slam  the hand on your side comes down from above on you: an
##                      overhead; step out, or guard standing
##   Skull Bite         from above, at its centre
##   Left / Right Sweep a wall of bone sweeps in from one edge to the centre,
##                      high and low at once: no guard stops it; be in the
##                      other half
##   High Clap          both hands sweep in from both edges at head height
##                      and meet in the middle: crouch under it, or guard standing
##   Low Clap           the same at the ankles: jump over it, or guard low
##   Bone Rain          once a hand is broken: three bones fall around you, at
##                      staggered heights, with gaps barely wide enough to stand in

const H := MoveDefinition.Height
const O := MoveDefinition.SpawnOrigin


static func definition() -> MonsterDefinition:
	var d := MonsterDefinition.new()
	var body := FighterDefinition.new()
	body.id = &"gashadokuro"
	body.display_name = "Gashadokuro"
	body.kind = FighterDefinition.Kind.MONSTER
	body.max_health = 2400
	# The narrow core it measures distance from; it has no pushbox.
	body.stand_hurtbox = Rect2(-40, -600, 80, 600)
	body.crouch_hurtbox = body.stand_hurtbox
	body.air_hurtbox = body.stand_hurtbox
	body.pushbox = Rect2()
	d.body = body
	d.colour = Color(0.86, 0.83, 0.72)
	d.turns = false
	d.walk_speed = 2.2
	d.rest = 50
	d.stagger = 80
	# It drifts until you are under one of its hands.
	d.close_gap = 160.0
	d.backdrop = [Rect2(-160, -600, 320, 300), Rect2(-25, -300, 50, 300),
			Rect2(-300, -560, 140, 50), Rect2(160, -560, 140, 50)]

	var raised := Vector2(0, -330)
	var left := MonsterDefinition.Part.new("left hand", Rect2(-270, -70, 140, 70), 1.0, 450, true)
	left.rest_offset = raised
	var right := MonsterDefinition.Part.new("right hand", Rect2(130, -70, 140, 70), 1.0, 450, true)
	right.rest_offset = raised
	var skull := MonsterDefinition.Part.new("skull", Rect2(-80, -235, 160, 115), 2.0, 0, true)
	skull.rest_offset = Vector2(0, -330)
	d.parts = [left, right, skull]

	var attacks: Array = []
	for hand in [["left", -1, Rect2(-270, -260, 140, 260), O.EDGE_LEFT],
			["right", 1, Rect2(130, -260, 140, 260), O.EDGE_RIGHT]]:
		var slam := MonsterDefinition.Attack.new()
		slam.move = _move({id = StringName("%s_slam" % hand[0]), startup = 40, active = 6, recovery = 70,
			damage = 110, knockdown = 50, knockback = 8.0, hitstop = 12, height = H.HIGH,
			hitboxes = [hand[2]]})
		slam.weight = 3.0
		slam.crippled_weight = 3.0
		slam.side = hand[1]
		slam.exposes = ["%s hand" % hand[0]]
		slam.requires = ["%s hand" % hand[0]]
		attacks.append(slam)

		var sweep := MonsterDefinition.Attack.new()
		sweep.move = _move({id = StringName("%s_sweep" % hand[0]), startup = 40, active = 2, recovery = 40,
			spawn_origin = hand[3],
			spawn = _move({id = &"bone_wall", startup = 0, active = 200, recovery = 0, motion = Vector2(10, 0),
				stops_at_centre = true, damage = 80, knockdown = 45, knockback = 8.0, hitstop = 10,
				height = H.HIGH_LOW, hitboxes = [Rect2(-60, -420, 120, 420)]})})
		sweep.weight = 1.5
		sweep.crippled_weight = 1.5
		sweep.stage_half = hand[1]
		sweep.requires = ["%s hand" % hand[0]]
		attacks.append(sweep)

	for clap in [["high_clap", Rect2(-50, -175, 100, 70), H.HIGH], ["low_clap", Rect2(-50, -55, 100, 55), H.LOW]]:
		var a := MonsterDefinition.Attack.new()
		a.move = _move({id = StringName(clap[0]), startup = 36, active = 2, recovery = 36,
			spawn_origin = O.EDGES_BOTH,
			spawn = _move({id = &"clapping_hand", startup = 0, active = 200, recovery = 0, motion = Vector2(9, 0),
				stops_at_centre = true, damage = 70, knockdown = 40, knockback = 6.0, hitstop = 10,
				height = clap[2], hitboxes = [clap[1]]})})
		a.weight = 1.5
		a.requires = ["left hand", "right hand"]
		attacks.append(a)

	var bite := MonsterDefinition.Attack.new()
	bite.move = _move({id = &"skull_bite", startup = 50, active = 6, recovery = 80,
		damage = 130, knockdown = 50, knockback = 9.0, hitstop = 14, height = H.MID,
		hitboxes = [Rect2(-90, -250, 180, 250)]})
	bite.weight = 2.0
	bite.crippled_weight = 2.0
	bite.max_gap = 60.0
	bite.exposes = ["skull"]
	attacks.append(bite)

	# Three bones, 90 wide with 70 between them (a fighter is 60 wide),
	# starting at different heights so they land one after another.
	var rain := MonsterDefinition.Attack.new()
	rain.move = _move({id = &"bone_rain", startup = 30, active = 2, recovery = 40,
		spawn_origin = O.TARGET,
		spawn_offsets = [Vector2(-160, -560), Vector2(0, -660), Vector2(160, -610)],
		spawn = _move({id = &"falling_bone", startup = 0, active = 90, recovery = 0, motion = Vector2(0, 9),
			damage = 60, hitstun = 18, blockstun = 12, knockback = 4.0, hitstop = 8, height = H.HIGH,
			hitboxes = [Rect2(-45, -40, 90, 40)]})})
	rain.weight = 0.0
	rain.crippled_weight = 3.0
	attacks.append(rain)

	d.attacks = attacks
	return d


static func _move(props: Dictionary) -> MoveDefinition:
	var m := MoveDefinition.new()
	for key in props:
		assert(key in m, "MoveDefinition has no property '%s'" % key)
		if key == "hitboxes" or key == "spawn_offsets":
			m.get(key).assign(props[key])
		else:
			m.set(key, props[key])
	return m
