extends RefCounted
## Ushi-oni, the ox-headed, spider-bodied demon of the shore.
##
## Its body fills about a third of the stage. It takes only half damage on
## its shell. Its legs can be broken from below with low attacks; a broken leg
## staggers it, and once crippled it walks at half speed, can no longer stomp,
## and breathes poison more often. Its head takes double damage, but only after
## a charge, when it lowers it to recover.
##
## Its head and back can be stood on: jump onto the head, then up onto the
## back, ride it, strike the shell beneath you, or drop off behind it to reach
## its back legs. It turns round only after you have been behind it for a
## second, and it bucks to throw off anyone on its back.
##
## Attacks, each telegraphed by its start-up:
##   Leg Stab      both sides at once, beyond its legs; guard it
##   Stomp         a low quake across the stage; jump it or guard low
##   Charge        the whole stage at speed, passing through you; jump it
##   Poison Breath a slow cloud that slows whoever it touches; guard it
##   Buck          throws off a rider; jump off, or guard


const H := MoveDefinition.Height


static func definition() -> MonsterDefinition:
	var d := MonsterDefinition.new()
	var body := FighterDefinition.new()
	body.id = &"ushi_oni"
	body.display_name = "Ushi-oni"
	body.kind = FighterDefinition.Kind.MONSTER
	body.max_health = 2600
	body.stand_hurtbox = Rect2(-180, -210, 360, 210)
	body.crouch_hurtbox = body.stand_hurtbox
	body.air_hurtbox = body.stand_hurtbox
	body.pushbox = Rect2(-170, -200, 340, 200)
	d.body = body
	d.walk_speed = 1.6
	d.rest = 45
	d.stagger = 70
	d.close_gap = 60.0
	d.turn_delay = 60
	# A circular arena two stage-lengths round: no corner to be pinned in.
	d.arena_length = 2400.0
	# Beaten, it sinks onto its belly; its core is under the shell.
	d.core = Rect2(-120, -150, 240, 150)

	# The head's top is low enough for the heaviest fighters' jump, and the
	# back is one jump above it.
	d.parts = [
		# Its back can be stood on; standing blows from there pass over it, so
		# strike it from its head, or crouched on its back.
		MonsterDefinition.Part.new("shell", Rect2(-180, -210, 360, 140), 0.5, 0, false, true, 50.0),
		MonsterDefinition.Part.new("front legs", Rect2(110, -70, 90, 70), 1.0, 350),
		MonsterDefinition.Part.new("back legs", Rect2(-200, -70, 90, 70), 1.0, 350),
		MonsterDefinition.Part.new("head", Rect2(170, -130, 80, 60), 2.0, 0, true, true),
	]

	var stab := MonsterDefinition.Attack.new()
	stab.move = _move({id = &"leg_stab", startup = 32, active = 6, recovery = 30,
		damage = 90, knockdown = 40, knockback = 9.0, hitstop = 10, height = H.MID,
		hitboxes = [Rect2(180, -95, 120, 60), Rect2(-300, -95, 120, 60)]})
	stab.weight = 3.0
	stab.crippled_weight = 2.0
	stab.max_gap = 140.0

	var stomp := MonsterDefinition.Attack.new()
	stomp.move = _move({id = &"stomp", startup = 36, active = 6, recovery = 34,
		damage = 50, knockdown = 45, knockback = 3.0, hitstop = 12, height = H.LOW,
		hitboxes = [Rect2(-620, -18, 1240, 18)]})
	stomp.weight = 2.0
	stomp.requires = ["front legs", "back legs"]

	var charge := MonsterDefinition.Attack.new()
	charge.move = _move({id = &"charge", startup = 40, active = 70, recovery = 90,
		damage = 120, knockdown = 50, knockback = 12.0, hitstop = 12, height = H.MID,
		hitboxes = [Rect2(-150, -110, 340, 110)]})
	charge.weight = 1.5
	charge.crippled_weight = 2.0
	charge.min_gap = 120.0
	charge.travel = Vector2(15, 0)
	charge.pushless = true
	charge.exposes = ["head"]

	var breath := MonsterDefinition.Attack.new()
	breath.move = _move({id = &"poison_breath", startup = 28, active = 2, recovery = 30,
		spawn_offset = Vector2(220, -130),
		spawn = _move({id = &"poison_cloud", startup = 0, active = 120, recovery = 0,
			motion = Vector2(5, 0.6), damage = 40, hitstun = 16, blockstun = 12, knockback = 4.0,
			hitstop = 5, slows = 240, height = H.MID, hitboxes = [Rect2(-35, -30, 70, 60)]})})
	breath.weight = 1.5
	breath.crippled_weight = 3.0
	breath.min_gap = 60.0

	var buck := MonsterDefinition.Attack.new()
	buck.move = _move({id = &"buck", startup = 24, active = 8, recovery = 30,
		damage = 40, knockdown = 40, knockback = 14.0, hitstop = 10, height = H.MID,
		hitboxes = [Rect2(-200, -400, 400, 195)]})
	buck.weight = 6.0
	buck.crippled_weight = 6.0
	buck.ridden_only = true

	d.attacks = [stab, stomp, charge, breath, buck]
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
