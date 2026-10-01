extends RefCounted
## Prototype archetypes. All three share one move set and differ only in
## numbers: body size, speed, power, tempo, health, and which of their moves
## they perform when bound as a spirit.
##
## Deriving variants by scaling is a prototype convenience for testing whether
## data alone makes fighters feel different. Real characters will be written
## move by move.

const PrototypeRect := preload("res://game/fighters/prototype_rect.gd")


static func all() -> Array[FighterDefinition]:
	return [balanced(), heavy(), swift()]


static func balanced() -> FighterDefinition:
	var d := PrototypeRect.definition()
	d.id = &"balanced"
	d.display_name = "Balanced"
	return d


static func heavy() -> FighterDefinition:
	var d := _variant(&"heavy", "Heavy", {
		health = 1200, size = 1.2, speed = 0.72, jump = 0.9, power = 1.3, tempo = 2})
	d.spirit_move = &"stand_heavy"
	d.spirit_cooldown = 300
	d.spirit_offset = Vector2(50, 0)
	return d


static func swift() -> FighterDefinition:
	var d := _variant(&"swift", "Swift", {
		health = 850, size = 0.85, speed = 1.35, jump = 1.06, power = 0.8, tempo = -1})
	d.spirit_move = &"projectile"
	d.spirit_cooldown = 240
	d.spirit_offset = Vector2(-40, 0)
	return d


## size scales every box and offset about the feet; speed scales walking and
## jump distance; jump scales jump height; power scales damage; tempo is added
## to every move's startup and recovery (never below one frame).
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
	for m in d.moves.values() + [d.summon_move]:
		var move: MoveDefinition = m
		move.hitboxes.assign(move.hitboxes.map(func(r: Rect2) -> Rect2: return _scale(r, p.size)))
		move.spawn_offset *= p.size
		move.damage = roundi(move.damage * p.power)
		if move.startup > 0:
			move.startup = maxi(move.startup + p.tempo, 1)
		move.recovery = maxi(move.recovery + p.tempo, 1)
		if move.spawn:
			move.spawn.damage = roundi(move.spawn.damage * p.power)
	return d


static func _scale(r: Rect2, s: float) -> Rect2:
	return Rect2(r.position * s, r.size * s)
