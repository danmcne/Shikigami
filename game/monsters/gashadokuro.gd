extends RefCounted
## Gashadokuro, the giant skeleton raised from the bones of the unburied dead.
##
## It looms behind the stage, fifteen times a fighter's height, and has no
## body to bump into: you walk beneath it. It drifts to keep you under one of
## its hands. Nothing of it can be struck at rest. Its hands come down to
## strike and stay on the ground a moment afterwards, open to attack and
## breakable. Its skull lowers to bite and stays low a moment, taking double
## damage. Break a hand and it rains bones from above instead.
##
## Attacks, each telegraphed by its start-up:
##   Hand Slam     a hand comes down from above on whoever stands under it;
##                 an overhead: step out, or guard standing
##   Far Slam      the other hand, on the far side: for those who slip past
##   Skull Bite    from above, at its centre
##   Bone Sweep    a hand sweeps in along the floor from the stage edge behind
##                 you: jump it, or guard low
##   Bone Rain     once a hand is broken: bones fall on your head; guard standing

const H := MoveDefinition.Height


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
	d.walk_speed = 2.2
	d.rest = 50
	d.stagger = 80
	# It drifts until you are under its near hand.
	d.close_gap = 160.0
	d.turn_delay = 90
	d.backdrop = [Rect2(-160, -600, 320, 300), Rect2(-25, -300, 50, 300),
			Rect2(-300, -560, 140, 50), Rect2(160, -560, 140, 50)]

	var raised := Vector2(0, -330)
	var near := MonsterDefinition.Part.new("near hand", Rect2(130, -70, 140, 70), 1.0, 450, true)
	near.rest_offset = raised
	var far := MonsterDefinition.Part.new("far hand", Rect2(-270, -70, 140, 70), 1.0, 450, true)
	far.rest_offset = raised
	var skull := MonsterDefinition.Part.new("skull", Rect2(-80, -235, 160, 115), 2.0, 0, true)
	skull.rest_offset = Vector2(0, -330)
	d.parts = [near, far, skull]

	var slam := MonsterDefinition.Attack.new()
	slam.move = _move({id = &"hand_slam", startup = 40, active = 6, recovery = 70,
		damage = 110, knockdown = 50, knockback = 8.0, hitstop = 12, height = H.HIGH,
		hitboxes = [Rect2(130, -260, 140, 260)]})
	slam.weight = 3.0
	slam.crippled_weight = 2.0
	slam.exposes = ["near hand"]
	slam.requires = ["near hand"]

	var far_slam := MonsterDefinition.Attack.new()
	far_slam.move = _move({id = &"far_slam", startup = 40, active = 6, recovery = 70,
		damage = 110, knockdown = 50, knockback = 8.0, hitstop = 12, height = H.HIGH,
		hitboxes = [Rect2(-270, -260, 140, 260)]})
	far_slam.weight = 1.0
	far_slam.crippled_weight = 1.0
	far_slam.exposes = ["far hand"]
	far_slam.requires = ["far hand"]

	var bite := MonsterDefinition.Attack.new()
	bite.move = _move({id = &"skull_bite", startup = 50, active = 6, recovery = 80,
		damage = 130, knockdown = 50, knockback = 9.0, hitstop = 14, height = H.MID,
		hitboxes = [Rect2(-90, -250, 180, 250)]})
	bite.weight = 2.0
	bite.crippled_weight = 2.0
	bite.max_gap = 60.0
	bite.exposes = ["skull"]

	var sweep := MonsterDefinition.Attack.new()
	sweep.move = _move({id = &"bone_sweep", startup = 36, active = 2, recovery = 40, spawn_from_edge = true,
		spawn = _move({id = &"sweeping_hand", startup = 0, active = 140, recovery = 0, motion = Vector2(10, 0),
			damage = 70, knockdown = 40, knockback = 6.0, hitstop = 10, height = H.LOW,
			hitboxes = [Rect2(-70, -45, 140, 45)]})})
	sweep.weight = 2.0
	sweep.crippled_weight = 1.0
	sweep.min_gap = 60.0
	sweep.requires = ["near hand"]

	var rain := MonsterDefinition.Attack.new()
	rain.move = _move({id = &"bone_rain", startup = 30, active = 2, recovery = 30,
		spawn_offset = Vector2(200, -560),
		spawn = _move({id = &"falling_bones", startup = 0, active = 80, recovery = 0, motion = Vector2(0, 9),
			damage = 50, hitstun = 18, blockstun = 12, knockback = 4.0, hitstop = 8, height = H.HIGH,
			hitboxes = [Rect2(-50, -40, 100, 40)]})})
	rain.weight = 0.0
	rain.crippled_weight = 3.0

	d.attacks = [slam, far_slam, bite, sweep, rain]
	return d


static func _move(props: Dictionary) -> MoveDefinition:
	var m := MoveDefinition.new()
	for key in props:
		assert(key in m, "MoveDefinition has no property '%s'" % key)
		if key == "hitboxes":
			m.hitboxes.assign(props[key])
		else:
			m.set(key, props[key])
	return m
