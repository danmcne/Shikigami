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
	var pose := _pose(f, p, scale)
	var kumoru := f.state in CLOUDED
	# Like a noh mask: tilted up it shines (teru), tilted down it clouds (kumoru).
	pose.angles.head = pose.angles.get("head", 0.0) + (16.0 if kumoru else -6.0)
	var placed := base * Transform2D(0.0, Vector2(f.facing * scale, scale), 0.0, f.position)
	placed = placed * Transform2D(deg_to_rad(pose.root_rot), pose.root)
	var colours: Dictionary = p.colourways[clampi(colourway, 0, p.colourways.size() - 1)]
	var dim := 1.25 if f.state == Fighter.State.HITSTUN else 1.0
	var transforms := p.pose_transforms(pose.angles)
	var current: MoveDefinition = f.move if f.state == Fighter.State.MOVE else null
	for part in p.draw_order(p.view):
		if not p.shows(part, current, f.state_frame):
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


## Where a point on a part of `f`'s puppet is in the world, in its present pose.
static func world_point(f: Fighter, part_name: String, local: Vector2) -> Vector2:
	var p := PuppetsRegistry.for_id(f.definition.id)
	if p == null or p.find(part_name) == null:
		return f.position
	var scale := f.definition.stand_hurtbox.size.y / p.height * FIT
	var pose := _pose(f, p, scale)
	var placed := Transform2D(0.0, Vector2(f.facing * scale, scale), 0.0, f.position) \
			* Transform2D(deg_to_rad(pose.root_rot), pose.root)
	return placed * (p.pose_transforms(pose.angles)[part_name] * local)


## Just the head (with its hair and hat), as when Rokurokubi's head flies:
## `centre` is the middle of the head in the world.
static func draw_head(ci: CanvasItem, f: Fighter, p: PuppetDefinition, centre: Vector2, facing: int,
		base: Transform2D, colourway: int) -> void:
	var scale := f.definition.stand_hurtbox.size.y / p.height * FIT
	var transforms := p.pose_transforms(p.base_angles("stand"))
	var head_t: Transform2D = transforms["head"]
	var at := base * Transform2D(0.0, Vector2(facing * scale, scale), 0.0, centre + Vector2(0, 15 * scale))
	var colours: Dictionary = p.colourways[clampi(colourway, 0, p.colourways.size() - 1)]
	for part in p.draw_order(p.view):
		var q: PuppetDefinition.Part = part
		var under_head := false
		while q != null:
			if q.name == "head":
				under_head = true
				break
			q = p.find(q.parent) if q.parent != "" else null
		if not under_head:
			continue
		var t: Transform2D = at * head_t.affine_inverse() * transforms[part.name]
		_cut(ci, t, p.shape_of(part, p.view), colours.get(part.slot, Color.MAGENTA), 1.0)
		if part.name == "head":
			for feature in p.face_teru:
				_cut(ci, t, PackedVector2Array(feature[0]), colours.get(feature[1], INK), 1.0, false)
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
static func _pose(f: Fighter, p: PuppetDefinition, scale: float) -> Dictionary:
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
			# A shuffle about the stance; in profile, after the first steps, a
			# real stride.
			var walking := 0.0
			if p.view == PuppetDefinition.View.SIDE and p.gait == "stride":
				walking = clampf((t - 8.0) / 12.0, 0.0, 1.0)
			var stride := _stride(f, p)
			var phase := f.position.x * PI / 68.0 * f.facing
			var shuffle := {lead_thigh = a.lead_thigh + 14.0 * sin(phase), trail_thigh = a.trail_thigh - 14.0 * sin(phase),
					lead_shin = a.lead_shin + 16.0 * maxf(0.0, -cos(phase)), trail_shin = a.trail_shin + 16.0 * maxf(0.0, cos(phase))}
			for joint in shuffle:
				a[joint] = lerpf(shuffle[joint], stride[joint], walking)
			root.y = stride.drop * walking
		Fighter.State.CROUCH:
			root.y = PuppetDefinition.CROUCH_DROP
			a.merge(PuppetDefinition.CROUCH, true)
			a.merge(p.crouch_pose, true)
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
			a.merge(p.air_pose, true)
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
			# A move without a swing: crouched or tucked as the fighter is, the
			# striking arm reaching toward where the move hits (a placeholder
			# until the move is animated).
			if f.crouching and not f.airborne:
				root.y = PuppetDefinition.CROUCH_DROP
				a.merge(PuppetDefinition.CROUCH, true)
			elif f.airborne:
				a.merge(PuppetDefinition.AIR, true)
			if f.move and not f.move.hitboxes.is_empty():
				_reach_toward_hit(f.move, t, p, scale, a, root)
	p.limit(a)
	p.apply_grips(a, root)
	p.apply_follows(a)
	return {angles = a, root = root, root_rot = root_rot}


## A walk that plants its feet. Over a cycle of two strides each leg is
## planted for half: its foot sweeps back from a half-stride ahead of the hip
## to a half-stride behind, exactly as fast as the body travels (the thigh's
## angle is the arcsine of the foot's offset over the leg's length), while the
## other leg swings forward, knee lifted. The hips ride at the height the
## planted leg allows. Walking backward runs the same cycle in reverse.
static func _stride(f: Fighter, p: PuppetDefinition) -> Dictionary:
	const STEP := 68.0  # travel per stride, in puppet units
	var leg := p.find("lead_shin").pivot.length() + p.find("lead_foot").pivot.length()
	var cycle := fposmod(f.position.x * f.facing / (2.0 * STEP), 1.0)
	var out := {}
	var drop := 0.0
	for side in ["lead", "trail"]:
		var u := fposmod(cycle + (0.0 if side == "lead" else 0.5), 1.0)
		var offset: float
		var lift := 0.0
		if u < 0.5:
			offset = STEP / 2.0 - STEP * (u / 0.5)
		else:
			var w := (u - 0.5) / 0.5
			offset = -STEP / 2.0 + STEP * smoothstep(0.0, 1.0, w)
			lift = 38.0 * sin(PI * w)
		var thigh := asin(clampf(-offset / leg, -1.0, 1.0))
		out[side + "_thigh"] = rad_to_deg(thigh)
		out[side + "_shin"] = 4.0 + lift
		if u < 0.5:
			drop = leg * (1.0 - cos(thigh))
	out["drop"] = drop
	return out


static func _reach_toward_hit(m: MoveDefinition, frame: int, p: PuppetDefinition, scale: float,
		a: Dictionary, root: Vector2) -> void:
	var t := PuppetDefinition._phase(m, frame)
	var progress := clampf(t, 0.0, 1.0) if t < 2.0 else clampf(3.0 - t, 0.0, 1.0)
	if progress <= 0.0:
		return
	var arm := p.striking_arm(m)
	var reached := a.duplicate()
	p.reach_with(reached, arm, m.hitboxes[0].get_center() / scale, -1.0, root)
	for joint in [arm + "_upper", arm + "_fore"]:
		a[joint] = lerpf(a[joint], reached[joint], progress)
