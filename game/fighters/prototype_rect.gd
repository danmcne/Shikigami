extends RefCounted
## The kit every fighter shares: six normals, a throw, two dashes, two shared
## techniques (toward + special: rush; down + special: rising anti-air), the
## summon gesture and a finisher. roster.gd gives each character its
## proportions and its two specials. The numbers are starting points for
## tuning feel, not balance claims.

const H := MoveDefinition.Height


static func definition() -> FighterDefinition:
	var d := FighterDefinition.new()
	d.id = &"prototype_rect"
	d.display_name = "Rectangle"
	d.kind = FighterDefinition.Kind.HUMAN
	d.stand_hurtbox = Rect2(-30, -160, 60, 160)
	d.crouch_hurtbox = Rect2(-30, -100, 60, 100)
	d.air_hurtbox = Rect2(-30, -140, 60, 120)
	d.pushbox = Rect2(-25, -150, 50, 150)

	var moves: Array[MoveDefinition] = [
		# Normals. Standing light sits at chest height and passes over a crouch;
		# standing heavy reaches low enough to hit one.
		_move({id = &"stand_light", startup = 5, active = 3, recovery = 8,
			damage = 40, hitstun = 14, blockstun = 10, knockback = 6.0, hitstop = 5,
			height = H.MID, hitboxes = [Rect2(20, -130, 70, 25)]}),
		_move({id = &"stand_heavy", startup = 10, active = 4, recovery = 18,
			damage = 90, hitstun = 20, blockstun = 14, knockback = 10.0, hitstop = 9,
			height = H.MID, hitboxes = [Rect2(20, -110, 95, 40)]}),
		_move({id = &"crouch_light", startup = 5, active = 3, recovery = 9,
			damage = 30, hitstun = 13, blockstun = 9, knockback = 5.0, hitstop = 5,
			height = H.LOW, hitboxes = [Rect2(20, -40, 70, 20)]}),
		_move({id = &"crouch_heavy", startup = 11, active = 4, recovery = 22,
			damage = 80, hitstun = 19, blockstun = 13, knockback = 9.0, hitstop = 9,
			height = H.LOW, hitboxes = [Rect2(20, -30, 115, 25)]}),
		_move({id = &"jump_light", startup = 5, active = 8, recovery = 4,
			damage = 40, hitstun = 16, blockstun = 10, knockback = 5.0, hitstop = 5,
			height = H.HIGH, hitboxes = [Rect2(10, -50, 60, 50)]}),
		_move({id = &"jump_heavy", startup = 8, active = 6, recovery = 6,
			damage = 80, hitstun = 20, blockstun = 12, knockback = 8.0, hitstop = 8,
			height = H.HIGH, hitboxes = [Rect2(0, -40, 90, 50)]}),

		# Throw: short reach, beats guard, loses to any strike.
		_move({id = &"throw", startup = 4, active = 2, recovery = 24, throw = true,
			damage = 120, knockdown = 50, knockback = 8.0, hitstop = 12,
			hitboxes = [Rect2(15, -140, 45, 110)]}),

		# Dashes: no hitboxes, only motion.
		_move({id = &"dash_forward", startup = 0, active = 0, recovery = 16,
			motion = Vector2(9, 0)}),
		_move({id = &"dash_back", startup = 0, active = 0, recovery = 18,
			motion = Vector2(-8, 0)}),

		# Shared specials: every fighter has an approach and an anti-air.
		_move({id = &"rush", startup = 10, active = 5, recovery = 20, motion = Vector2(12, 0),
			damage = 100, knockdown = 45, blockstun = 16, knockback = 10.0, hitstop = 10,
			height = H.MID, hitboxes = [Rect2(20, -130, 60, 80)]}),
		# Launches itself; invulnerable through its start, lands in recovery.
		_move({id = &"rising", startup = 3, active = 12, recovery = 25, invulnerable = 8,
			motion = Vector2(2, -15), damage = 110, knockdown = 50, blockstun = 14,
			knockback = 6.0, hitstop = 10, height = H.MID,
			hitboxes = [Rect2(-10, -200, 75, 130)]}),
	]
	for m in moves:
		d.moves[m.id] = m

	d.summon_move = _move({id = &"summon", startup = 6, active = 1, recovery = 14})
	d.spirit_cooldown = 360

	# Wide reach: sealing is not a test of spacing.
	d.finisher_move = _move({id = &"finisher", startup = 20, active = 12, recovery = 40,
		damage = 0, hitboxes = [Rect2(0, -220, 320, 220)]})

	d.commands = {
		"AB": &"throw",        # hold back for a back throw
		"656": &"dash_forward",
		"454": &"dash_back",
		"6C": &"rush",
		"2C": &"rising",
	}
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
