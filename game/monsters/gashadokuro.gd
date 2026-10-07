extends RefCounted
## Gashadokuro, the giant skeleton raised from the bones of the unburied dead.
##
## It looms over a circular arena two stage-lengths round, as if you were
## shut in a building and it outside: run far enough one way and you come
## round the other. It has no body to bump into; you walk beneath it. It faces
## you and doesn't turn, so its left and right hands are the stage's left and
## right, and it drifts to keep you under one of them.
##
## In this fight you turn by input, not to face it: hold back to turn and run.
## Guard covers only the side you face, so to block a hand you must face it.
##
## Nothing of it can be struck at rest. A hand comes down and lies open after a
## slam; the skull lowers after a bite. Its hands sweep and clap from half a
## stage out from its centreline, often beyond the screen, to just under its
## skull.
##
## Attacks, each telegraphed:
##   Left / Right Slam  the hand on your side comes down on you: an overhead
##   Skull Bite         from above, at its centre
##   Left / Right Grab  a hand sweeps in along the floor. Caught, you are
##                      carried under the skull and chewed. Guarding it,
##                      facing it, you are pushed there unhurt and let go; the
##                      jaws then come down, unguardable, giving you just
##                      enough time to get clear.
##   High / Low Clap    both hands sweep in and meet beneath it, at head height
##                      (crouch under) or at the ankles (jump over). Guarding
##                      the hand you face pushes you on into the other, which
##                      strikes your back. Clapping needs both hands.
##   Bone Rain          now and then, and often once a hand is broken: three
##                      bones fall around you, at staggered heights, with
##                      narrow gaps between them

const H := MoveDefinition.Height
const O := MoveDefinition.SpawnOrigin
## Where its hands start sweeping: half a stage-length from its centreline.
const REACH := 600.0


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
	d.free_facing = true
	d.arena_length = 2400.0
	d.walk_speed = 2.2
	d.rest = 50
	d.stagger = 80
	# It drifts until you are under one of its hands.
	d.close_gap = 160.0
	d.backdrop = [Rect2(-160, -600, 320, 300), Rect2(-25, -300, 50, 300),
			Rect2(-300, -560, 140, 50), Rect2(160, -560, 140, 50)]
	# Beaten, its skull rests on the ground: seal it there.
	d.core = Rect2(-90, -120, 180, 120)

	# Drawn raised just below its shoulders while they can't be struck.
	var raised := Vector2(0, -260)
	var left := MonsterDefinition.Part.new("left hand", Rect2(-270, -70, 140, 70), 1.0, 450, true)
	left.rest_offset = raised
	var right := MonsterDefinition.Part.new("right hand", Rect2(130, -70, 140, 70), 1.0, 450, true)
	right.rest_offset = raised
	var skull := MonsterDefinition.Part.new("skull", Rect2(-80, -235, 160, 115), 2.0, 0, true)
	skull.rest_offset = Vector2(0, -330)
	d.parts = [left, right, skull]

	var mouth := MonsterDefinition.Attack.new()
	mouth.move = _move({id = &"jaws", startup = 50, active = 8, recovery = 60,
		damage = 140, knockdown = 55, knockback = 6.0, hitstop = 16, height = H.HIGH_LOW,
		hitboxes = [Rect2(-80, -240, 160, 240)]})
	mouth.exposes = ["skull"]

	var attacks: Array = []
	for hand in [["left", -1, Rect2(-270, -260, 140, 260)], ["right", 1, Rect2(130, -260, 140, 260)]]:
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

		var grab := MonsterDefinition.Attack.new()
		grab.move = _move({id = StringName("%s_grab" % hand[0]), startup = 30, active = 2, recovery = 50,
			spawn_offsets = [Vector2(hand[1] * REACH, 0)],
			spawn = _move({id = &"grasping_hand", startup = 0, active = 120, recovery = 0, motion = Vector2(11, 0),
				converges = true, grabs = true, pushes_on_guard = true, damage = 30, blockstun = 12,
				height = H.MID, hitboxes = [Rect2(-60, -200, 120, 200)]})})
		grab.weight = 1.5
		grab.crippled_weight = 1.5
		grab.side = hand[1]
		grab.requires = ["%s hand" % hand[0]]
		grab.follow_up = mouth
		attacks.append(grab)

	# One clap, high: from just above the tallest crouch (115) to well over a
	# jump, so it catches anyone standing and anyone crouching passes under it.
	for clap in [["high_clap", Rect2(-50, -400, 100, 282), H.HIGH]]:
		var a := MonsterDefinition.Attack.new()
		a.move = _move({id = StringName(clap[0]), startup = 36, active = 2, recovery = 40,
			spawn_offsets = [Vector2(-REACH, 0), Vector2(REACH, 0)],
			spawn = _move({id = &"clapping_hand", startup = 0, active = 90, recovery = 0, motion = Vector2(10, 0),
				converges = true, pushes_on_guard = true, damage = 70, knockdown = 40, knockback = 6.0,
				blockstun = 12, hitstop = 10, height = clap[2], hitboxes = [clap[1]]})})
		a.weight = 2.0
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

	# Three bones, 90 wide with 70 between them on Normal (a fighter is 60
	# wide; easier settings spread them further), starting at different
	# heights so they land one after another.
	var rain := MonsterDefinition.Attack.new()
	rain.move = _move({id = &"bone_rain", startup = 30, active = 2, recovery = 40,
		spawn_origin = O.TARGET,
		spawn_offsets = [Vector2(-160, -560), Vector2(0, -660), Vector2(160, -610)],
		spawn = _move({id = &"falling_bone", startup = 0, active = 90, recovery = 0, motion = Vector2(0, 9),
			damage = 60, hitstun = 18, blockstun = 12, knockback = 4.0, hitstop = 8, height = H.HIGH,
			hitboxes = [Rect2(-45, -40, 90, 40)]})})
	rain.weight = 0.7
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
