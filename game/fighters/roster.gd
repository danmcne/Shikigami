extends RefCounted
## The roster: eight humans and eight yokai, still drawn as rectangles. Each
## shares the base kit, scaled to its proportions, and adds two specials of
## its own: one on special, one on away + special. Both recharge. When bound
## as a spirit, the binder chooses which of the two the spirit performs.
##
## Everything is data. Specials are built from a small set of effects that
## MoveDefinition provides: strikes in any direction, high-and-low strikes,
## throws, projectiles (including stationary traps and barriers), launches,
## teleports, counters, heals, armour, slow, and pulls (negative knockback).

const PuppetsRegistry := preload("res://game/art/puppets/registry.gd")
const PrototypeRect := preload("res://game/fighters/prototype_rect.gd")
const H := MoveDefinition.Height
const HUMAN := FighterDefinition.Kind.HUMAN
const YOKAI := FighterDefinition.Kind.YOKAI


static func all() -> Array[FighterDefinition]:
	var out: Array[FighterDefinition] = []
	for entry in _table():
		out.append(_build(entry))
	return out


static func by_id(id: StringName) -> FighterDefinition:
	for d in all():
		if d.id == id:
			return d
	return null


## One entry per character: identity, proportions, and two specials.
## Proportions: size scales boxes, speed walking and jump distance, jump
## height, power damage; tempo is added to every shared move's startup and
## recovery. Specials are authored per character and are not scaled.
static func _table() -> Array:
	return [
		# --- humans ---------------------------------------------------------
		{id = &"musashi", name = "Miyamoto Musashi", kind = HUMAN,
			p = {health = 1000, size = 1.0, speed = 1.0, jump = 1.0, power = 1.0, tempo = 0},
			# Niten Ichi-ryū: one sword high, one low, at once.
			specials = [{id = &"two_heavens", startup = 14, active = 4, recovery = 22, cooldown = 120,
					damage = 100, knockdown = 40, knockback = 8.0, hitstop = 10, height = H.HIGH_LOW,
					hitboxes = [Rect2(15, -140, 85, 40), Rect2(15, -45, 85, 40)]},
				# The Void, last of the Five Rings: a still stance that answers any strike.
				{id = &"void_stance", startup = 2, active = 24, recovery = 18, cooldown = 150,
					counter = {id = &"void_cut", startup = 2, active = 4, recovery = 14, damage = 110,
						knockdown = 45, knockback = 9.0, hitstop = 12, hitboxes = [Rect2(0, -150, 110, 120)]}}]},
		{id = &"kojiro", name = "Sasaki Kojirō", kind = HUMAN,
			p = {health = 950, size = 1.05, speed = 1.05, jump = 1.0, power = 1.0, tempo = 0},
			# Tsubame Gaeshi: a cut that turns back on itself like a swallow, from the air too.
			specials = [{id = &"swallow_cut", startup = 6, active = 8, recovery = 20, cooldown = 90, air = true,
					damage = 90, knockdown = 40, knockback = 7.0, hitstop = 10,
					hitboxes = [Rect2(0, -230, 90, 110), Rect2(20, -130, 100, 50)]},
				# The Drying Pole, his overlong nodachi, in a fencer's lunge that
				# carries him forward. Only its tip wounds: against someone too close
				# the thrust passes harmlessly, its recharge spent.
				{id = &"drying_pole", startup = 10, active = 4, recovery = 20, cooldown = 60, motion = Vector2(7, 0),
					damage = 80, hitstun = 18, blockstun = 12, knockback = 12.0, hitstop = 9,
					hitboxes = [Rect2(140, -115, 120, 25)]}]},
		{id = &"tomoe", name = "Tomoe Gozen", kind = HUMAN,
			p = {health = 950, size = 0.95, speed = 1.1, jump = 1.0, power = 0.95, tempo = -1},
			# The naginata swung full circle, front and back, also in the air.
			specials = [{id = &"naginata_wheel", startup = 9, active = 8, recovery = 18, cooldown = 90, air = true,
					damage = 85, hitstun = 18, blockstun = 12, knockback = 9.0, hitstop = 9,
					hitboxes = [Rect2(10, -140, 120, 70), Rect2(-130, -140, 120, 70)]},
				{id = &"naginata_sweep", startup = 10, active = 5, recovery = 24, cooldown = 60,
					damage = 75, knockdown = 40, knockback = 6.0, hitstop = 9, height = H.LOW,
					hitboxes = [Rect2(20, -35, 170, 30)]}]},
		{id = &"benkei", name = "Benkei", kind = HUMAN,
			p = {health = 1250, size = 1.25, speed = 0.75, jump = 0.9, power = 1.25, tempo = 1},
			# He died standing on the bridge, still blocking it: armour while he advances.
			specials = [{id = &"standing_death", startup = 4, active = 40, recovery = 20, cooldown = 240,
					armor = 64, motion = Vector2(5, 0), damage = 90, hitstun = 20, blockstun = 14,
					knockback = 10.0, hitstop = 10, hitboxes = [Rect2(10, -170, 90, 150)]},
				{id = &"seven_weapons", startup = 8, active = 3, recovery = 30, cooldown = 180, throw = true,
					damage = 170, knockdown = 60, knockback = 10.0, hitstop = 14,
					hitboxes = [Rect2(10, -170, 100, 150)]}]},
		{id = &"hanzo", name = "Hattori Hanzō", kind = HUMAN,
			p = {health = 850, size = 0.9, speed = 1.3, jump = 1.1, power = 0.85, tempo = -1},
			# Kawarimi, the substitution: struck, he is gone, and behind you.
			specials = [{id = &"kawarimi", startup = 2, active = 20, recovery = 22, cooldown = 150,
					counter = {id = &"kawarimi_strike", startup = 10, active = 4, recovery = 12,
						teleport_frame = 1, teleport_distance = 45.0, invulnerable = 8,
						damage = 80, hitstun = 20, knockback = 7.0, hitstop = 9, hitboxes = [Rect2(10, -120, 70, 50)]}},
				{id = &"shuriken", startup = 8, active = 1, recovery = 16, cooldown = 45, air = true,
					spawn_offset = Vector2(40, -120),
					spawn = {id = &"shuriken_star", startup = 0, active = 70, recovery = 0, motion = Vector2(11, 0),
						damage = 35, hitstun = 12, blockstun = 8, knockback = 3.0, hitstop = 3,
						hitboxes = [Rect2(-10, -8, 20, 16)]}}]},
		{id = &"monk", name = "En no Gyōja", kind = HUMAN,
			p = {health = 1100, size = 1.0, speed = 0.9, jump = 1.0, power = 0.9, tempo = 0},
			# Meditation, after Yoshimitsu: still and exposed, then restored.
			# Like the sake: long, exposed, generous, and slow to return.
			specials = [{id = &"meditation", startup = 55, active = 1, recovery = 15, cooldown = 1200, heal = 220},
				{id = &"sutra_palm", startup = 8, active = 4, recovery = 18, cooldown = 60,
					damage = 60, hitstun = 18, blockstun = 14, knockback = 20.0, hitstop = 10,
					hitboxes = [Rect2(20, -130, 70, 70)]}]},
		{id = &"miko", name = "Izumo no Okuni", kind = HUMAN,
			p = {health = 900, size = 0.9, speed = 1.0, jump = 1.0, power = 0.9, tempo = 0},
			# Ofuda: paper talismans thrown, or laid on the ground as a ward.
			specials = [{id = &"ofuda", startup = 10, active = 1, recovery = 20, cooldown = 60,
					spawn_offset = Vector2(45, -115),
					spawn = {id = &"ofuda_paper", startup = 0, active = 90, recovery = 0, motion = Vector2(8, 0),
						damage = 50, hitstun = 16, blockstun = 12, knockback = 5.0, hitstop = 5,
						hitboxes = [Rect2(-12, -18, 24, 36)]}},
				{id = &"warding_seal", startup = 12, active = 1, recovery = 18, cooldown = 240,
					spawn_offset = Vector2(120, 0),
					# A trap holds rather than hurts; no guard height stops it, only not stepping on it.
					spawn = {id = &"warding_seal_trap", startup = 0, active = 300, recovery = 0,
						damage = 10, paralyse = 70, hitstop = 8, height = H.HIGH_LOW,
						hitboxes = [Rect2(-25, -12, 50, 12)]}}]},
		{id = &"onmyoji", name = "Abe no Seimei", kind = HUMAN,
			p = {health = 900, size = 0.95, speed = 0.9, jump = 1.0, power = 0.9, tempo = 0},
			# Paper shikigami: birds released low that climb gently as they fly.
			specials = [{id = &"paper_birds", startup = 10, active = 1, recovery = 20, cooldown = 60, air = true,
					spawn_offset = Vector2(40, -70),
					spawn = {id = &"paper_bird", startup = 0, active = 80, recovery = 0, motion = Vector2(7, -1.8),
						damage = 50, hitstun = 16, blockstun = 12, knockback = 5.0, hitstop = 5,
						hitboxes = [Rect2(-15, -10, 30, 20)]}},
				# A five-element seal: stops projectiles, repels whoever walks into it.
				{id = &"five_element_seal", startup = 8, active = 1, recovery = 16, cooldown = 300,
					spawn_offset = Vector2(70, 0),
					spawn = {id = &"seal_barrier", startup = 0, active = 120, recovery = 0,
						damage = 0, hitstun = 6, blockstun = 6, knockback = 12.0, hitstop = 2,
						hitboxes = [Rect2(-10, -180, 20, 180)]}}]},

		# --- yokai ----------------------------------------------------------
		{id = &"shuten", name = "Shuten-dōji", kind = YOKAI,
			p = {health = 1400, size = 1.3, speed = 0.8, jump = 0.9, power = 1.3, tempo = 1},
			# His heavy raises the kanabō off his shoulder to overhead and brings it
			# down: a longer wind-up than a plain heavy.
			frames = {stand_heavy = {startup = 15}},
			# The sake-drinking oni: a long, exposed drink that restores a great deal,
			# with a very slow recharge, so when to drink is a decision, not a habit.
			# A hit during the drink spills it; the recharge is spent either way.
			specials = [{id = &"sake", startup = 50, active = 1, recovery = 20, cooldown = 1500, heal = 260},
				# The iron club driven into the ground: a quake along the floor to both
				# sides. Little damage, but it knocks down anyone standing; jump it or
				# guard low.
				{id = &"kanabo_quake", startup = 20, active = 6, recovery = 24, cooldown = 150,
					damage = 60, knockdown = 50, knockback = 3.0, hitstop = 12, height = H.LOW,
					hitboxes = [Rect2(-230, -18, 460, 18)]}]},
		{id = &"kitsune", name = "Tamamo-no-Mae", kind = YOKAI,
			p = {health = 850, size = 0.85, speed = 1.35, jump = 1.06, power = 0.8, tempo = -1},
			# Fox illusion: gone, then behind you.
			specials = [{id = &"fox_step", startup = 20, active = 4, recovery = 16, cooldown = 240, teleport_range = 160.0,
					invulnerable = 16, teleport_frame = 14, teleport_distance = 45.0,
					damage = 70, hitstun = 18, blockstun = 12, knockback = 7.0, hitstop = 8,
					hitboxes = [Rect2(10, -120, 70, 50)]},
				# A sweep of many tails, low and mid at once.
				{id = &"nine_tails", startup = 8, active = 6, recovery = 18, cooldown = 60,
					damage = 65, knockdown = 30, knockback = 6.0, hitstop = 8, height = H.LOW,
					hitboxes = [Rect2(15, -40, 100, 30), Rect2(15, -120, 70, 40)]}]},
		{id = &"tengu", name = "Sōjōbō", kind = YOKAI,
			p = {health = 1000, size = 1.05, speed = 1.1, jump = 1.15, power = 1.0, tempo = 0},
			# The feather fan: a gust that hurls more than it hurts.
			specials = [{id = &"gale_fan", startup = 12, active = 1, recovery = 20, cooldown = 90,
					spawn_offset = Vector2(50, 0),
					spawn = {id = &"gale", startup = 0, active = 60, recovery = 0, motion = Vector2(9, 0),
						damage = 20, hitstun = 14, blockstun = 10, knockback = 22.0, hitstop = 4,
						hitboxes = [Rect2(-20, -150, 40, 150)]}},
				{id = &"tengu_flight", startup = 6, active = 18, recovery = 14, cooldown = 90, air = true,
					motion = Vector2(11, -7), damage = 80, knockdown = 35, knockback = 8.0, hitstop = 9,
					height = H.HIGH, hitboxes = [Rect2(0, -120, 80, 60)]}]},
		{id = &"kappa", name = "Kawatarō", kind = YOKAI,
			# Child-sized, so hard to hit; it pays for that in health and power,
			# as small, quick fighters must.
			p = {health = 900, size = 0.8, speed = 0.9, jump = 1.0, power = 1.0, tempo = 0},
			# Kappa challenge travellers to sumo.
			specials = [{id = &"sumo_grab", startup = 10, active = 3, recovery = 28, cooldown = 180, throw = true,
					damage = 130, knockdown = 55, knockback = 14.0, hitstop = 14,
					hitboxes = [Rect2(10, -140, 85, 140)]},
				# Water from the dish on its head, along the ground: a low projectile.
				# Leaning forward, he spits a jet from the water in his head: it
				# drives down at 30 degrees, and on meeting the ground runs on along it.
				{id = &"water_jet", startup = 12, active = 1, recovery = 20, cooldown = 60,
					spawn_offset = Vector2(45, -125),
					spawn = {id = &"water", startup = 0, active = 70, recovery = 0, motion = Vector2(8, 4.6),
						damage = 45, hitstun = 16, blockstun = 12, knockback = 5.0, hitstop = 5, height = H.MID,
						hitboxes = [Rect2(-14, -14, 28, 28)],
						leaves = {id = &"water_wave", startup = 0, active = 45, recovery = 0, motion = Vector2(8, 0),
							damage = 40, hitstun = 14, blockstun = 10, knockback = 5.0, hitstop = 5, height = H.LOW,
							hitboxes = [Rect2(-20, -20, 40, 20)]}}}]},
		{id = &"yuki_onna", name = "O-Yuki", kind = YOKAI,
			p = {health = 950, size = 0.95, speed = 1.05, jump = 1.0, power = 0.95, tempo = 0},
			# The snow woman's breath: it chills, and the chilled are slow.
			specials = [{id = &"frost_breath", startup = 10, active = 10, recovery = 18, cooldown = 100,
					damage = 40, hitstun = 16, blockstun = 12, knockback = 4.0, hitstop = 6, slows = 180,
					hitboxes = [Rect2(15, -140, 110, 60)]},
				# An icicle falling from above, some way ahead: an overhead.
				# Forms high above the opponent (above a giant's core), and falls; no
				# further than two of her body lengths away.
				{id = &"icicle", startup = 14, active = 1, recovery = 18, cooldown = 75,
					spawn_origin = MoveDefinition.SpawnOrigin.TARGET, spawn_offset = Vector2(0, -300), spawn_range = 300.0,
					spawn = {id = &"icicle_shard", startup = 0, active = 50, recovery = 0, motion = Vector2(0, 9),
						damage = 70, hitstun = 18, blockstun = 12, knockback = 4.0, hitstop = 8, height = H.HIGH,
						hitboxes = [Rect2(-12, -30, 24, 30)]}}]},
		{id = &"jorogumo", name = "Jorōgumo", kind = YOKAI,
			p = {health = 950, size = 1.0, speed = 1.0, jump = 1.0, power = 1.0, tempo = 0},
			# Silk that reels the victim in (negative knockback).
			specials = [{id = &"web", startup = 12, active = 1, recovery = 22, cooldown = 120,
					spawn_offset = Vector2(40, -110),
					spawn = {id = &"web_strand", startup = 0, active = 70, recovery = 0, motion = Vector2(8, 0),
						damage = 30, hitstun = 22, blockstun = 12, knockback = -14.0, hitstop = 6,
						hitboxes = [Rect2(-15, -15, 30, 30)]}},
				# Up into the rafters, out of reach, and down again on top of you.
				{id = &"ceiling_drop", startup = 20, active = 12, recovery = 18, cooldown = 120, invulnerable = 18,
					motion = Vector2(4, -20), damage = 90, knockdown = 40, knockback = 6.0, hitstop = 10,
					height = H.HIGH, hitboxes = [Rect2(-20, -40, 80, 50)]}]},
		{id = &"rokurokubi", name = "Rokurokubi", kind = YOKAI,
			p = {health = 900, size = 1.0, speed = 0.95, jump = 1.0, power = 0.95, tempo = 0},
			# By night her neck stretches: her head flies out in a long arc and comes
			# down on you from above, turning back when it strikes or reaches a
			# fighter's mid-height, and returning along the same path. It stays joined
			# to her, so a blow to the head is a blow to her, and it snaps back the
			# moment she is struck. Her recovery lasts the whole flight out and back.
			# Her head leaves from her own neck and swings on a circle, up, over, and
			# down onto the opponent at mid-height, about 380 ahead.
			specials = [{id = &"long_neck", startup = 12, active = 1, recovery = 66, cooldown = 120,
					spawn_offset = Vector2(4, -168),
					spawn = {id = &"flying_head", startup = 0, active = 80, recovery = 0,
						orbit_radius = 200.0, orbit_centre = Vector2(179, 88), orbit_speed = 0.064, tethered = true, returns = true,
						turn_height = -80.0,
						damage = 80, hitstun = 20, blockstun = 12, knockback = 6.0, hitstop = 9, height = H.HIGH,
						hitboxes = [Rect2(-25, -25, 50, 50)]}},
				# The lantern whose oil she licks by night, thrown in an arc; where it
				# breaks, a small fire burns a moment.
				{id = &"lantern", startup = 12, active = 1, recovery = 22, cooldown = 120, air = true,
					spawn_offset = Vector2(30, -110),
					spawn = {id = &"thrown_lantern", startup = 0, active = 120, recovery = 0,
						motion = Vector2(6, -9), gravity = 0.4,
						damage = 30, hitstun = 14, blockstun = 10, knockback = 4.0, hitstop = 5, height = H.MID,
						hitboxes = [Rect2(-15, -30, 30, 30)],
						leaves = {id = &"lantern_fire", startup = 0, active = 90, recovery = 0,
							damage = 40, hitstun = 18, blockstun = 12, knockback = 4.0, hitstop = 6, height = H.MID,
							hitboxes = [Rect2(-55, -60, 110, 60)]}}}]},
		{id = &"tanuki", name = "Danzaburō-danuki", kind = YOKAI,
			p = {health = 1100, size = 0.9, speed = 0.9, jump = 1.0, power = 0.95, tempo = 0},
			# Hara-tsuzumi, the belly drum: a low shockwave to both sides.
			specials = [{id = &"belly_drum", startup = 14, active = 6, recovery = 22, cooldown = 120,
					damage = 70, knockdown = 40, knockback = 6.0, hitstop = 9, height = H.LOW,
					hitboxes = [Rect2(0, -30, 140, 30), Rect2(-140, -30, 140, 30)]},
				# A leaf on the head and it is a stone statue; strike it and it strikes back.
				{id = &"leaf_disguise", startup = 3, active = 30, recovery = 24, cooldown = 180,
					counter = {id = &"statue_slam", startup = 3, active = 4, recovery = 16, damage = 100,
						knockdown = 45, knockback = 8.0, hitstop = 12, hitboxes = [Rect2(0, -140, 100, 140)]}}]},
	]


static func _build(e: Dictionary) -> FighterDefinition:
	var d := PrototypeRect.definition()
	d.id = e.id
	d.display_name = e.name
	d.kind = e.kind
	_scale_kit(d, e.p)
	# A fighter's own frame data for shared moves, where its animation needs it.
	var frames: Dictionary = e.get("frames", {})
	for move_id in frames:
		for key in frames[move_id]:
			d.moves[move_id].set(key, frames[move_id][key])
	var patterns := ["C", "4C"]
	for k in e.specials.size():
		var m := _special(e.specials[k])
		d.moves[m.id] = m
		d.commands[patterns[k]] = m.id
		d.specials.append(m.id)
	d.spirit_cooldown = e.get("spirit_cooldown", 360)
	_trace_weapons(d)
	return d


## A fighter with a puppet strikes with its weapons: each move it animates as
## a swing has its hitboxes traced, frame by frame, from where the weapons
## are. Moves without a swing, or whose swing strikes with nothing (a throw's
## grab, a quake's ground wave), keep their own boxes.
static func _trace_weapons(d: FighterDefinition) -> void:
	var puppet := PuppetsRegistry.for_id(d.id)
	if puppet == null:
		return
	var scale := d.stand_hurtbox.size.y / puppet.height * Puppet.FIT
	var everything: Array = d.moves.values() + [d.summon_move, d.finisher_move]
	for m in d.moves.values():
		if m.counter:
			everything.append(m.counter)
	for m in everything:
		if m == null or not puppet.swings.has(String(m.id)):
			continue
		var swing: Dictionary = puppet.swings[String(m.id)]
		if swing.get("strikes", []).is_empty():
			continue
		var frames: Array = []
		var all: Array[Rect2] = []
		for f in range(m.startup, m.startup + m.active):
			var strikes := puppet.weapon_strikes(swing, m, f, scale)
			frames.append(strikes)
			for strike in strikes:
				all.append(strike[0])
		m.frame_strikes = frames
		m.hitboxes = all


## A MoveDefinition from a dictionary; nested `counter`, `spawn` and `leaves`
## dictionaries become moves too.
static func _special(props: Dictionary) -> MoveDefinition:
	var flat := props.duplicate()
	for key in ["counter", "spawn", "leaves"]:
		if flat.has(key):
			flat[key] = _special(flat[key])
	return PrototypeRect._move(flat)


static func _scale_kit(d: FighterDefinition, p: Dictionary) -> void:
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
		move.damage = roundi(move.damage * p.power)
		if move.startup > 0:
			move.startup = maxi(move.startup + p.tempo, 1)
		move.recovery = maxi(move.recovery + p.tempo, 1)


static func _scale(r: Rect2, s: float) -> Rect2:
	return Rect2(r.position * s, r.size * s)
