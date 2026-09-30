extends RefCounted
## Prototype 1's only fighter: a rectangle with six normals. Its numbers are
## starting points for tuning feel, not balance claims.
##
## Standing light sits at chest height and whiffs over a crouch; standing heavy
## reaches low enough to hit one. That difference comes from box geometry, not
## from any rule in code.

const H := AttackDefinition.Height


static func definition() -> FighterDefinition:
	var d := FighterDefinition.new()
	d.id = &"prototype_rect"
	d.display_name = "Rectangle"
	d.stand_hurtbox = Rect2(-30, -160, 60, 160)
	d.crouch_hurtbox = Rect2(-30, -100, 60, 100)
	d.air_hurtbox = Rect2(-30, -140, 60, 120)
	d.pushbox = Rect2(-25, -150, 50, 150)
	d.attacks = {
		&"stand_light": _attack({
			id = &"stand_light", startup = 5, active = 3, recovery = 8,
			damage = 40, hitstun = 14, blockstun = 10, knockback = 6.0, hitstop = 5,
			height = H.MID, hitboxes = [Rect2(20, -130, 70, 25)],
		}),
		&"stand_heavy": _attack({
			id = &"stand_heavy", startup = 10, active = 4, recovery = 18,
			damage = 90, hitstun = 20, blockstun = 14, knockback = 10.0, hitstop = 9,
			height = H.MID, hitboxes = [Rect2(20, -110, 95, 40)],
		}),
		&"crouch_light": _attack({
			id = &"crouch_light", startup = 5, active = 3, recovery = 9,
			damage = 30, hitstun = 13, blockstun = 9, knockback = 5.0, hitstop = 5,
			height = H.LOW, hitboxes = [Rect2(20, -40, 70, 20)],
		}),
		&"crouch_heavy": _attack({
			id = &"crouch_heavy", startup = 11, active = 4, recovery = 22,
			damage = 80, hitstun = 19, blockstun = 13, knockback = 9.0, hitstop = 9,
			height = H.LOW, hitboxes = [Rect2(20, -30, 115, 25)],
		}),
		&"jump_light": _attack({
			id = &"jump_light", startup = 5, active = 8, recovery = 4,
			damage = 40, hitstun = 16, blockstun = 10, knockback = 5.0, hitstop = 5,
			height = H.HIGH, hitboxes = [Rect2(10, -50, 60, 50)],
		}),
		&"jump_heavy": _attack({
			id = &"jump_heavy", startup = 8, active = 6, recovery = 6,
			damage = 80, hitstun = 20, blockstun = 12, knockback = 8.0, hitstop = 8,
			height = H.HIGH, hitboxes = [Rect2(0, -40, 90, 50)],
		}),
	}
	return d


static func _attack(props: Dictionary) -> AttackDefinition:
	var a := AttackDefinition.new()
	for key in props:
		assert(key in a, "AttackDefinition has no property '%s'" % key)
		if key == "hitboxes":
			a.hitboxes.assign(props[key])
		else:
			a.set(key, props[key])
	return a
