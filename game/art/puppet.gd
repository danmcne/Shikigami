class_name Puppet
extends RefCounted
## Draws a fighter as its cut-paper puppet on the humanoid rig, posed from
## its state. The view the character is drawn in decides what is in front of
## what, where limbs attach and what is shaded; poses only say what the lead
## and trailing limbs do. A move animated as a swing is posed exactly as its
## hitboxes were traced.

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
## 0 (tori) or 1 (uke). `alpha` below 1 for spirits. Facing left is a mirror.
static func draw(ci: CanvasItem, f: Fighter, base: Transform2D, colourway: int, alpha := 1.0) -> void:
	var p := PuppetsRegistry.for_id(f.definition.id)
	var scale := f.definition.stand_hurtbox.size.y / p.height * FIT
	var pose := _pose(f, p)
	var kumoru := f.state in CLOUDED
	# Like a noh mask: tilted up it shines (teru), tilted down it clouds (kumoru).
	pose.angles.head = pose.angles.get("head", 0.0) + (16.0 if kumoru else -6.0)
	var placed := base * Transform2D(0.0, Vector2(f.facing * scale, scale), 0.0, f.position)
	placed = placed * Transform2D(deg_to_rad(pose.root_rot), pose.root)
	var colours: Dictionary = p.colourways[clampi(colourway, 0, p.colourways.size() - 1)]
	var dim := 1.25 if f.state == Fighter.State.HITSTUN else 1.0
	var transforms := p.pose_transforms(pose.angles)
	var current: StringName = f.move.id if f.state == Fighter.State.MOVE and f.move else &""
	for part in p.draw_order(p.view):
		if p.props.has(part.name) and not current in p.props[part.name]:
			continue
		if p.hidden_during.has(part.name) and current in p.hidden_during[part.name]:
			continue
		var t: Transform2D = placed * transforms[part.name]
		var c: Color = colours.get(part.slot, Color.MAGENTA)
		c = c.darkened(p.shade_of(part, p.view))
		c = Color(c.r * dim, c.g * dim, c.b * dim, c.a * alpha)
		var outline := p.shape_of(part, p.view)
		_cut(ci, t, outline, c, alpha)
		if part.name == "head":
			for feature in (p.face_kumoru if kumoru else p.face_teru):
				var fc: Color = colours.get(feature[1], INK)
				_cut(ci, t, PackedVector2Array(feature[0]), Color(fc, fc.a * alpha), alpha, false)
			if kumoru:
				# The lowered mask falls into shadow.
				_cut(ci, t, outline, Color(0.1, 0.05, 0.1, 0.32 * alpha), alpha, false)
	ci.draw_set_transform_matrix(base)


## A cut-paper shape: flat colour with a fine ink edge.
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


## Joint angles for the fighter's present state, plus a root offset and
## rotation. Reactions shift limbs from where they rest rather than replacing
## the rest pose, so whatever a hand holds stays plausible.
static func _pose(f: Fighter, p: PuppetDefinition) -> Dictionary:
	var t := f.state_frame
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
			a.lead_thigh += 20.0 * sin(phase)
			a.trail_thigh -= 20.0 * sin(phase)
			a.lead_shin += 18.0 * maxf(0.0, cos(phase))
			a.trail_shin += 18.0 * maxf(0.0, -cos(phase))
			root.y = -2.0 * absf(sin(phase))
		Fighter.State.CROUCH:
			root.y = PuppetDefinition.CROUCH_DROP
			a.merge(PuppetDefinition.CROUCH, true)
		Fighter.State.GUARD, Fighter.State.BLOCKSTUN:
			# Both forearms raised before the body.
			a.lead_upper = -60.0
			a.lead_fore = -95.0
			a.trail_upper = -40.0
			a.trail_fore = -100.0
			a.torso = -4.0
			if f.crouching:
				root.y = PuppetDefinition.CROUCH_DROP
				a.merge(PuppetDefinition.CROUCH, true)
		Fighter.State.JUMP:
			a.merge(PuppetDefinition.AIR, true)
		Fighter.State.HITSTUN:
			# Reeling: thrown back, arms flung from wherever they rested.
			a.torso = -16.0
			a.head = -12.0
			a.lead_upper += 35.0
			a.trail_upper += 30.0
		Fighter.State.KNOCKDOWN, Fighter.State.KO, Fighter.State.SEALED:
			if not f.airborne:
				root_rot = -88.0
				root = Vector2(-30.0, -18.0)
		Fighter.State.DAZED, Fighter.State.GRABBED:
			# Slumped: arms dropped from wherever they rested.
			a.torso = 24.0
			a.head = 22.0
			a.lead_upper += 25.0
			a.trail_upper += 15.0
			a.lead_thigh = -5.0
			a.trail_thigh = 8.0
		Fighter.State.MOVE:
			# A move without a swing: crouched or tucked as the fighter is.
			if f.crouching and not f.airborne:
				root.y = PuppetDefinition.CROUCH_DROP
				a.merge(PuppetDefinition.CROUCH, true)
			elif f.airborne:
				a.merge(PuppetDefinition.AIR, true)
	return {angles = a, root = root, root_rot = root_rot}
