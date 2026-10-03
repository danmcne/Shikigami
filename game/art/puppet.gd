class_name Puppet
extends RefCounted
## Draws a fighter as its cut-paper puppet, posed from its state. Poses are
## built from a few joint angles; an attack aims the weapon arm at the move's
## own hitbox, so every attack reads without per-move animation.

const INK := Color(0.08, 0.06, 0.06)
const PuppetsRegistry := preload("res://game/art/puppets/registry.gd")
## The puppet stands a little taller than the hurtbox it is fitted to.
const FIT := 1.08
## States in which the face is clouded (kumoru): head lowered, in shadow.
const CLOUDED := [Fighter.State.GUARD, Fighter.State.BLOCKSTUN, Fighter.State.HITSTUN,
		Fighter.State.KNOCKDOWN, Fighter.State.DAZED, Fighter.State.SEALED, Fighter.State.KO,
		Fighter.State.GRABBED]


static func has_puppet(f: Fighter) -> bool:
	return PuppetsRegistry.for_id(f.definition.id) != null


## Draws `f` under the transform `base` (the view's camera), in colourway
## 0 (tori) or 1 (uke). `alpha` below 1 for spirits.
static func draw(ci: CanvasItem, f: Fighter, base: Transform2D, colourway: int, alpha := 1.0) -> void:
	var p := PuppetsRegistry.for_id(f.definition.id)
	var scale := f.definition.stand_hurtbox.size.y / p.height * FIT
	var pose := _pose(f, p, scale)
	var kumoru := f.state in CLOUDED
	# Like a noh mask: tilted up it shines (teru), tilted down it clouds (kumoru).
	pose.angles.head = pose.angles.get("head", 0.0) + (16.0 if kumoru else -6.0)
	var placed := base * Transform2D(0.0, Vector2(f.facing * scale, scale), 0.0, f.position)
	placed = placed * Transform2D(deg_to_rad(pose.root_rot), pose.root)
	var colours: Dictionary = p.colourways[clampi(colourway, 0, p.colourways.size() - 1)]
	var dim := 1.0
	if f.state == Fighter.State.HITSTUN:
		dim = 1.25
	var transforms := p.pose_transforms(pose.angles)
	var ordered := p.parts.duplicate()
	ordered.sort_custom(func(a: PuppetDefinition.Part, b: PuppetDefinition.Part) -> bool: return a.z < b.z)
	var current: StringName = f.move.id if f.state == Fighter.State.MOVE and f.move else &""
	for part in ordered:
		if p.props.has(part.name) and not current in p.props[part.name]:
			continue
		if p.hidden_during.has(part.name) and current in p.hidden_during[part.name]:
			continue
		var t: Transform2D = placed * transforms[part.name]
		var c: Color = colours.get(part.slot, Color.MAGENTA)
		if part.far:
			c = c.darkened(0.25)
		c = Color(c.r * dim, c.g * dim, c.b * dim, c.a * alpha)
		_cut(ci, t, part.shape, c, alpha)
		if part.name == "head":
			for feature in (p.face_kumoru if kumoru else p.face_teru):
				var fc: Color = colours.get(feature[1], INK)
				_cut(ci, t, PackedVector2Array(feature[0]), Color(fc, fc.a * alpha), alpha, false)
			if kumoru:
				# The lowered mask falls into shadow.
				_cut(ci, t, part.shape, Color(0.1, 0.05, 0.1, 0.32 * alpha), alpha, false)
	ci.draw_set_transform_matrix(base)


## A cut-paper shape: flat colour with an ink edge.
static func _cut(ci: CanvasItem, t: Transform2D, shape: PackedVector2Array, c: Color, alpha: float,
		outline := true) -> void:
	ci.draw_set_transform_matrix(t)
	if shape.size() >= 3:
		ci.draw_colored_polygon(shape, c)
		if outline:
			var loop := shape.duplicate()
			loop.append(shape[0])
			ci.draw_polyline(loop, Color(INK, 0.4 * alpha), 0.9)
	elif shape.size() == 2:
		ci.draw_line(shape[0], shape[1], c, 2.5)


## Joint angles (degrees; for a hanging limb, negative swings it forward),
## plus a root offset and rotation, for the fighter's present state.
static func _pose(f: Fighter, p: PuppetDefinition, scale: float) -> Dictionary:
	var t := f.state_frame
	# A move animated as a swing is posed exactly as its hitboxes were traced.
	if f.state == Fighter.State.MOVE and f.move and p.swings.has(String(f.move.id)):
		return p.swing_pose(p.swings[String(f.move.id)], f.move, t)
	var a := p.base_angles("stand")
	var root := Vector2.ZERO
	var root_rot := 0.0
	match f.state:
		Fighter.State.STAND:
			a.torso += 2.0 * sin(Time.get_ticks_msec() * 0.003)
		Fighter.State.WALK:
			var phase := f.position.x * 0.06 * f.facing
			a.thigh_f = -14.0 + 24.0 * sin(phase)
			a.thigh_b = 16.0 - 24.0 * sin(phase)
			a.shin_f = 12.0 + 18.0 * maxf(0.0, cos(phase))
			a.shin_b = 4.0 + 18.0 * maxf(0.0, -cos(phase))
			root.y = -2.0 * absf(sin(phase))
		Fighter.State.CROUCH:
			root.y = 38.0
			a.torso = 22.0
			a.thigh_f = -78.0
			a.shin_f = 100.0
			a.thigh_b = -40.0
			a.shin_b = 110.0
		Fighter.State.GUARD, Fighter.State.BLOCKSTUN:
			a.upper_arm_f = -60.0
			a.lower_arm_f = -95.0
			a.upper_arm_b = -40.0
			a.lower_arm_b = -100.0
			a.torso = -4.0
			if f.crouching:
				root.y = 38.0
				a.thigh_f = -78.0
				a.shin_f = 100.0
				a.thigh_b = -40.0
				a.shin_b = 110.0
		Fighter.State.JUMP:
			a.thigh_f = -70.0
			a.shin_f = 95.0
			a.thigh_b = -30.0
			a.shin_b = 80.0
			a.upper_arm_b = -20.0
		Fighter.State.HITSTUN:
			# Reeling: thrown back, arms flung from wherever they rested.
			a.torso = -16.0
			a.head = -12.0
			a.upper_arm_f += 35.0
			a.upper_arm_b += 30.0
		Fighter.State.KNOCKDOWN, Fighter.State.KO, Fighter.State.SEALED:
			if not f.airborne:
				root_rot = -88.0
				root = Vector2(-30.0, -18.0)
				a.upper_arm_f = 10.0
				a.lower_arm_f = 0.0
		Fighter.State.DAZED, Fighter.State.GRABBED:
			# Slumped: arms dropped from wherever they rested.
			a.torso = 24.0
			a.head = 22.0
			a.upper_arm_f += 25.0
			a.upper_arm_b += 15.0
			a.thigh_f = -5.0
			a.thigh_b = 8.0
		Fighter.State.MOVE:
			_attack_pose(f, p, scale, a)
			if f.crouching and not f.airborne:
				root.y = 38.0
				a.thigh_f = -78.0
				a.shin_f = 100.0
				a.thigh_b = -40.0
				a.shin_b = 110.0
			elif f.airborne:
				a.thigh_f = -60.0
				a.shin_f = 80.0
				a.thigh_b = -25.0
				a.shin_b = 70.0
	return {angles = a, root = root, root_rot = root_rot}


## Wind up, strike along the line to the move's hitbox, then recover. Moves
## without a hitbox (heals, summons, throws of things) get a gesture instead.
static func _attack_pose(f: Fighter, p: PuppetDefinition, scale: float, a: Dictionary) -> void:
	var m := f.move
	var frame := f.state_frame
	var target := Vector2(70, -120)
	if not m.hitboxes.is_empty():
		target = m.hitboxes[0].get_center() / scale
	elif m.heal > 0 or m.counter:
		# Stillness: meditation, a drink, a stance.
		a.upper_arm_f = -20.0
		a.lower_arm_f = -110.0
		a.upper_arm_b = -15.0
		a.lower_arm_b = -110.0
		return
	var shoulder := Vector2(4, -128)
	var line := target - shoulder
	var aim := rad_to_deg(atan2(-line.x, line.y))
	var progress := 0.0
	if frame < m.startup:
		progress = -float(frame) / maxf(m.startup, 1.0)  # winding up: 0 -> -1
	elif m.is_active_on(frame):
		progress = 1.0
	else:
		progress = 1.0 - float(frame - m.startup - m.active) / maxf(m.recovery, 1.0)
	if progress < 0.0:
		a.upper_arm_f = lerpf(a.upper_arm_f, aim + 120.0, -progress)
		a.lower_arm_f = lerpf(a.lower_arm_f, -40.0, -progress)
		a.torso = lerpf(a.torso, -8.0, -progress)
	else:
		a.upper_arm_f = lerpf(a.upper_arm_f, aim, progress)
		a.lower_arm_f = lerpf(a.lower_arm_f, 0.0, progress)
		a.weapon_f = lerpf(a.weapon_f, -10.0, progress)
		a.torso = lerpf(a.torso, 14.0, progress)
		a.upper_arm_b = lerpf(a.upper_arm_b, 45.0, progress)
	# A second hitbox is for the other arm: the second sword low, or a strike
	# behind in a spin.
	if m.hitboxes.size() > 1 and progress > 0.0:
		var line_b: Vector2 = m.hitboxes[1].get_center() / scale - Vector2(-3, -128)
		var aim_b := rad_to_deg(atan2(-line_b.x, line_b.y))
		a.upper_arm_b = lerpf(a.upper_arm_b, aim_b, progress)
		a.lower_arm_b = lerpf(a.lower_arm_b, 0.0, progress)
		a.weapon_b = lerpf(a.weapon_b, -10.0, progress)
