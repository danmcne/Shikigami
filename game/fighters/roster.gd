extends RefCounted
## Prototype archetypes, placeholders until real characters exist. Each shares
## the base kit, scaled to its proportions, and adds its own signature special
## on the special button. The signature is also what its spirit does when
## bound and summoned. Nothing in the game refers to these by name.
##
##   Balanced  human, a two-sword swordsman. Signature: Two Heavens, a spinning
##             double cut that strikes in front and behind at once.
##   Heavy     yokai, an oni after Shuten-dōji. Signature: Sake, a long,
##             exposed drink that restores health; as a spirit it heals its
##             summoner. Second special: Oni Grab, a long-reach throw.
##   Swift     yokai, a kitsune. Signature: Fox Step, vanishing and reappearing
##             behind the opponent to strike. Second special: Foxfire, the
##             only projectile in the roster.

const PrototypeRect := preload("res://game/fighters/prototype_rect.gd")
const H := MoveDefinition.Height


static func all() -> Array[FighterDefinition]:
	return [balanced(), heavy(), swift()]


static func balanced() -> FighterDefinition:
	var d := PrototypeRect.definition()
	d.id = &"balanced"
	d.display_name = "Balanced"
	d.kind = FighterDefinition.Kind.HUMAN
	_add(d, "C", {id = &"two_heavens", startup = 9, active = 6, recovery = 18, cooldown = 90,
		damage = 90, hitstun = 18, blockstun = 12, knockback = 9.0, hitstop = 9, height = H.MID,
		hitboxes = [Rect2(10, -135, 95, 60), Rect2(-105, -135, 95, 60)]})
	d.signature = &"two_heavens"
	d.spirit_cooldown = 360
	return d


static func heavy() -> FighterDefinition:
	var d := _variant(&"heavy", "Heavy", {
		health = 1200, size = 1.2, speed = 0.72, jump = 0.9, power = 1.3, tempo = 2})
	d.kind = FighterDefinition.Kind.YOKAI
	_add(d, "C", {id = &"sake", startup = 40, active = 1, recovery = 20, cooldown = 480, heal = 150})
	_add(d, "4C", {id = &"oni_grab", startup = 9, active = 3, recovery = 30, throw = true,
		damage = 160, knockdown = 60, knockback = 10.0, hitstop = 14,
		hitboxes = [Rect2(10, -170, 95, 150)]})
	d.signature = &"sake"
	d.spirit_cooldown = 600
	d.spirit_offset = Vector2(-50, 0)
	d.finisher_command = "28D"
	return d


static func swift() -> FighterDefinition:
	var d := _variant(&"swift", "Swift", {
		health = 850, size = 0.85, speed = 1.35, jump = 1.06, power = 0.8, tempo = -1})
	d.kind = FighterDefinition.Kind.YOKAI
	_add(d, "C", {id = &"fox_step", startup = 20, active = 4, recovery = 16, cooldown = 120,
		invulnerable = 16, teleport_frame = 14, teleport_distance = 70.0,
		damage = 70, hitstun = 18, blockstun = 12, knockback = 7.0, hitstop = 8, height = H.MID,
		hitboxes = [Rect2(10, -120, 70, 50)]})
	_add(d, "4C", {id = &"foxfire", startup = 12, active = 2, recovery = 24,
		spawn_offset = Vector2(45, -95),
		spawn = PrototypeRect._move({id = &"foxfire_flame", startup = 0, active = 100, recovery = 0,
			motion = Vector2(7, 0), damage = 50, hitstun = 16, blockstun = 12,
			knockback = 5.0, hitstop = 5, height = H.MID, hitboxes = [Rect2(-15, -15, 30, 30)]})})
	d.signature = &"fox_step"
	d.spirit_cooldown = 300
	d.finisher_command = "64D"
	return d


## Adds a move authored for this fighter and binds it to `pattern`.
static func _add(d: FighterDefinition, pattern: String, props: Dictionary) -> void:
	var m := PrototypeRect._move(props)
	d.moves[m.id] = m
	d.commands[pattern] = m.id


## Scales the shared kit. size scales every box and offset about the feet;
## speed scales walking and jump distance; jump scales jump height; power
## scales damage; tempo is added to every move's startup and recovery (never
## below one frame). Signature and second specials are authored per fighter
## and added afterwards, unscaled.
static func _variant(id: StringName, name: String, p: Dictionary) -> FighterDefinition:
	var d := PrototypeRect.definition()
	d.id = id
	d.display_name = name
	d.max_health = p.health
	d.walk_forward *= p.speed
	d.walk_back *= p.speed
	d.jump_forward *= p.speed
	d.jump_velocity *= p.jump
	d.stand_hurtbox = _scale(d.stand_hurtbox, p.size)
	d.crouch_hurtbox = _scale(d.crouch_hurtbox, p.size)
	d.air_hurtbox = _scale(d.air_hurtbox, p.size)
	d.pushbox = _scale(d.pushbox, p.size)
	for m in d.moves.values() + [d.summon_move, d.finisher_move]:
		var move: MoveDefinition = m
		move.hitboxes.assign(move.hitboxes.map(func(r: Rect2) -> Rect2: return _scale(r, p.size)))
		move.spawn_offset *= p.size
		move.damage = roundi(move.damage * p.power)
		if move.startup > 0:
			move.startup = maxi(move.startup + p.tempo, 1)
		move.recovery = maxi(move.recovery + p.tempo, 1)
	return d


static func _scale(r: Rect2, s: float) -> Rect2:
	return Rect2(r.position * s, r.size * s)
