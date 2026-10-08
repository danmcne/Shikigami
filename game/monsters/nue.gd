extends RefCounted
## Nue: monkey's face, tanuki's body, tiger's limbs, a snake for a tail, riding
## a black thundercloud. It plagued the emperor's palace until Minamoto no
## Yorimasa shot it down out of the night sky.
##
## It flies above the reach of ordinary jumps. Reach it with a rising
## anti-air, an anti-air special, or a projectile thrown upward or from the
## top of a jump, or punish it on the ground after it dives. Its thundercloud
## takes those blows from below; break the cloud and Nue falls, grounded for
## good, and fights on as a beast: faster, closer, and within reach.
##
## Its back can be stood on: jump onto it while it is on the ground (grounded,
## or after a dive), ride it, strike it, or cross over it. If you are on it
## when it takes off, it carries you up; it thrashes to throw riders off.
##
## Attacks, each telegraphed:
##   Lightning     three bolts strike marked spots around you after a warning;
##                 stand clear of the marks, or guard
##   Dive          it drops on you claws first, an overhead: step aside or
##                 guard standing; then it lies on the ground a moment, open
##   Tail Strike   the snake tail lashes down behind it, at whoever slips under
##   Thrash        throws off a rider
## Grounded:
##   Claw          a quick swipe ahead
##   Tail Lash     low, to both sides
##   Pounce        a running leap at you

const H := MoveDefinition.Height
const O := MoveDefinition.SpawnOrigin


static func definition() -> MonsterDefinition:
	var d := MonsterDefinition.new()
	var body := FighterDefinition.new()
	body.id = &"nue"
	body.display_name = "Nue"
	body.kind = FighterDefinition.Kind.MONSTER
	body.max_health = 2200
	body.stand_hurtbox = Rect2(-110, -100, 220, 100)
	body.crouch_hurtbox = body.stand_hurtbox
	body.air_hurtbox = body.stand_hurtbox
	# The pushbox stays below the back, or it would shove off anyone landing on it.
	body.pushbox = Rect2(-100, -85, 200, 85)
	d.body = body
	d.colour = Color(0.42, 0.33, 0.45)
	d.walk_speed = 2.0
	d.rest = 45
	d.stagger = 70
	d.close_gap = 40.0
	d.turn_delay = 40
	# A circular arena two stage-lengths round: no corner to be pinned in.
	d.arena_length = 2400.0
	# Its cloud's underside is just above an ordinary jump's reach, and within
	# reach of a rising anti-air. (Tengu and the nekomata jump high enough to
	# touch it.)
	d.altitude = 270.0
	d.flight_part = "thundercloud"
	d.core = Rect2(-90, -90, 180, 90)

	d.parts = [
		# Its back can be ridden; standing blows from there pass over it, as on
		# Ushi-oni: strike it crouched.
		MonsterDefinition.Part.new("body", Rect2(-100, -90, 200, 90), 1.0, 0, false, true, 50.0),
		MonsterDefinition.Part.new("face", Rect2(90, -120, 50, 50), 1.5),
		MonsterDefinition.Part.new("tail", Rect2(-170, -80, 70, 40), 1.0),
		MonsterDefinition.Part.new("thundercloud", Rect2(-130, 0, 260, 40), 1.0, 450),
	]

	var lightning := MonsterDefinition.Attack.new()
	lightning.move = _move({id = &"lightning", startup = 20, active = 2, recovery = 50,
		spawn_origin = O.TARGET, spawn_offsets = [Vector2(-170, 0), Vector2(0, 0), Vector2(170, 0)],
		spawn = _move({id = &"bolt", startup = 40, active = 8, recovery = 0,
			damage = 70, knockdown = 40, knockback = 5.0, hitstop = 10, height = H.MID,
			hitboxes = [Rect2(-30, -700, 60, 700)]})})
	lightning.weight = 2.0
	lightning.requires = ["thundercloud"]

	var dive := MonsterDefinition.Attack.new()
	dive.move = _move({id = &"dive", startup = 30, active = 30, recovery = 70,
		damage = 100, knockdown = 45, knockback = 9.0, hitstop = 12, height = H.HIGH,
		hitboxes = [Rect2(-90, -100, 210, 110)]})
	dive.weight = 2.5
	dive.min_gap = 40.0
	dive.max_gap = 260.0
	dive.travel = Vector2(8, 14)
	dive.requires = ["thundercloud"]

	var tail := MonsterDefinition.Attack.new()
	tail.move = _move({id = &"tail_strike", startup = 24, active = 8, recovery = 30,
		damage = 80, knockdown = 35, knockback = 8.0, hitstop = 10, height = H.MID,
		hitboxes = [Rect2(-260, -60, 140, 290)]})
	tail.weight = 1.5
	tail.max_gap = 140.0
	tail.requires = ["thundercloud"]

	var claw := MonsterDefinition.Attack.new()
	claw.move = _move({id = &"claw", startup = 16, active = 5, recovery = 22,
		damage = 80, hitstun = 20, blockstun = 14, knockback = 9.0, hitstop = 10, height = H.MID,
		hitboxes = [Rect2(80, -110, 120, 90)]})
	claw.weight = 3.0
	claw.crippled_weight = 3.0
	claw.max_gap = 120.0
	claw.needs_broken = ["thundercloud"]

	var lash := MonsterDefinition.Attack.new()
	lash.move = _move({id = &"tail_lash", startup = 22, active = 6, recovery = 28,
		damage = 60, knockdown = 35, knockback = 6.0, hitstop = 9, height = H.LOW,
		hitboxes = [Rect2(60, -35, 180, 35), Rect2(-240, -35, 180, 35)]})
	lash.weight = 2.0
	lash.crippled_weight = 2.0
	lash.max_gap = 200.0
	lash.needs_broken = ["thundercloud"]

	var pounce := MonsterDefinition.Attack.new()
	pounce.move = _move({id = &"pounce", startup = 24, active = 18, recovery = 30,
		damage = 90, knockdown = 40, knockback = 10.0, hitstop = 11, height = H.MID,
		hitboxes = [Rect2(-60, -110, 200, 110)]})
	pounce.weight = 1.5
	pounce.crippled_weight = 1.5
	pounce.min_gap = 120.0
	pounce.travel = Vector2(13, 0)
	pounce.needs_broken = ["thundercloud"]

	var thrash := MonsterDefinition.Attack.new()
	thrash.move = _move({id = &"thrash", startup = 22, active = 8, recovery = 26,
		damage = 40, knockdown = 40, knockback = 13.0, hitstop = 10, height = H.MID,
		hitboxes = [Rect2(-120, -280, 240, 190)]})
	thrash.weight = 6.0
	thrash.ridden_only = true

	# While flying, nothing it does is "crippled"; grounded, the weights apply
	# through needs_broken instead, so the two weights are the same.
	for a in [lightning, dive, tail, thrash]:
		a.crippled_weight = a.weight
	d.attacks = [lightning, dive, tail, claw, lash, pounce, thrash]
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
