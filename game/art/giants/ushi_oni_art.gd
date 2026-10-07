extends RefCounted
## Ushi-oni in cut paper: an ox's head on a spider's body. The carapace is
## built of lacquered plates with a spined ridge; eight jointed legs carry it,
## the near four before the body and the far four behind it, darker. With its
## front and back pairs broken it still walks on the four in the middle. It is
## drawn over its gameplay parts (shell, legs, head), which stay the truth:
## a broken leg pair becomes stumps, and the head glows when exposed. Each
## attack has its own motion.

const SHELL := Color("5a2a24")
const PLATE := Color("74362c")
const RIDGE := Color("2e1714")
const LEG := Color("2a1d1a")
const JOINT := Color("4a2f28")
const FACE := Color("6b2a24")
const MUZZLE := Color("8a4a3a")
const HORN := Color("e7dcbf")
const EYE := Color("f0c840")
const INK := Color(0.08, 0.06, 0.06, 0.55)

# Each leg: where it joins the body, its knee, its foot (local, facing +x),
# and which gameplay part it belongs to.
const LEGS := [
	{at = Vector2(110, -100), knee = Vector2(165, -195), foot = Vector2(140, 0), part = "front legs", near = false},
	{at = Vector2(40, -96), knee = Vector2(60, -192), foot = Vector2(48, 0), part = "", near = false},
	{at = Vector2(-40, -96), knee = Vector2(-62, -190), foot = Vector2(-56, 0), part = "", near = false},
	{at = Vector2(-110, -100), knee = Vector2(-150, -190), foot = Vector2(-130, 0), part = "back legs", near = false},
	{at = Vector2(120, -100), knee = Vector2(195, -200), foot = Vector2(178, 0), part = "front legs", near = true},
	{at = Vector2(50, -96), knee = Vector2(90, -198), foot = Vector2(96, 0), part = "", near = true},
	{at = Vector2(-30, -96), knee = Vector2(-58, -198), foot = Vector2(-80, 0), part = "", near = true},
	{at = Vector2(-115, -100), knee = Vector2(-180, -200), foot = Vector2(-168, 0), part = "back legs", near = true},
]


## Behind the fighters: all of it (a fighter can stand before it or on it).
static func draw_back(ci: CanvasItem, m: Monster, base: Transform2D, tint: Color, bout: Bout = null) -> void:
	draw(ci, m, base, tint, bout)


static func draw_front(_ci: CanvasItem, _m: Monster, _base: Transform2D, _tint: Color, _bout: Bout = null) -> void:
	pass


static func draw(ci: CanvasItem, m: Monster, base: Transform2D, tint: Color, _bout: Bout = null) -> void:
	var pose := _pose(m)
	var local := base * Transform2D(0.0, Vector2(m.facing, 1), 0.0, m.position)
	var body := local * Transform2D(deg_to_rad(pose.tilt), Vector2(0, pose.drop))
	ci.draw_set_transform_matrix(local)
	for leg in LEGS:
		if not leg.near:
			_leg(ci, m, leg, pose, body, local, LEG.darkened(0.3) * tint)
	ci.draw_set_transform_matrix(body)
	_carapace(ci, tint)
	_head(ci, m, pose, tint)
	ci.draw_set_transform_matrix(local)
	for leg in LEGS:
		if leg.near:
			_leg(ci, m, leg, pose, body, local, LEG * tint)
	ci.draw_set_transform_matrix(base)


## How the body sits and what each leg and the head are doing.
static func _pose(m: Monster) -> Dictionary:
	var pose := {tilt = 0.0, drop = 0.0, lift = {}, reach = {}, head = Vector2.ZERO, jaw = 0.0, scuttle = 0.0}
	var t := m.state_frame
	if m.state == Fighter.State.WALK or (m.state == Fighter.State.STAND and absf(m.velocity.x) > 0.1):
		pose.scuttle = m.position.x * 0.08 * m.facing
	match m.state:
		Fighter.State.HITSTUN:
			pose.drop = 4.0 * sin(t * 1.3)
		Fighter.State.KO, Fighter.State.DAZED:
			pose.drop = 40.0
		Fighter.State.MOVE:
			var mv := m.move
			var phase := PuppetDefinition._phase(mv, t)
			var wind := clampf(phase, 0.0, 1.0)
			var strike := 1.0 if phase >= 1.0 and phase < 2.0 else clampf(3.0 - phase, 0.0, 1.0) if phase >= 2.0 else 0.0
			match mv.id:
				&"leg_stab":
					# The end legs rear, then stab where the blow lands.
					for i in mv.hitboxes.size():
						var target: Vector2 = mv.hitboxes[i].get_center()
						var part := "front legs" if target.x > 0 else "back legs"
						pose.lift[part] = 50.0 * wind * (1.0 - strike)
						pose.reach[part] = [target, strike]
				&"stomp":
					for part in ["front legs", "back legs", ""]:
						pose.lift[part] = 40.0 * wind * (1.0 - strike)
					pose.drop = -12.0 * wind * (1.0 - strike) + 6.0 * strike
				&"charge":
					pose.drop = 14.0
					pose.head = Vector2(18, 16)
					pose.scuttle = t * 0.6
				&"poison_breath":
					pose.head = Vector2(6, -18) * wind
					pose.jaw = 1.0 if phase >= 0.8 else 0.0
				&"buck":
					pose.tilt = -12.0 * (wind if phase < 1.0 else strike)
	return pose


static func _carapace(ci: CanvasItem, tint: Color) -> void:
	var shell := PackedVector2Array()
	for k in 14:
		var a := PI + k * PI / 13.0
		shell.append(Vector2(cos(a) * 188.0, -128.0 + sin(a) * 82.0))
	shell.append(Vector2(170, -78))
	shell.append(Vector2(-170, -78))
	_cut(ci, shell, SHELL * tint)
	# Overlapping plates, back to front.
	for i in 5:
		var x0 := -170.0 + i * 70.0
		_cut(ci, PackedVector2Array([Vector2(x0, -100), Vector2(x0 + 18, -190 + absf(i - 2) * 6), Vector2(x0 + 82, -188 + absf(i - 2) * 6), Vector2(x0 + 70, -98)]), PLATE * tint)
	# The spined ridge.
	for i in 9:
		var x := -150.0 + i * 37.0
		var top := -205.0 + absf(i - 4) * 3.0
		_cut(ci, PackedVector2Array([Vector2(x - 10, top + 8), Vector2(x, top - 16), Vector2(x + 10, top + 8)]), RIDGE * tint)


static func _head(ci: CanvasItem, m: Monster, pose: Dictionary, tint: Color) -> void:
	var o: Vector2 = pose.head
	var exposed := false
	for k in m.monster.parts.size():
		if m.monster.parts[k].name == "head":
			exposed = m.exposed(k)
	var face := FACE.lightened(0.35) if exposed else FACE
	# Neck, skull, muzzle and lower jaw.
	_cut(ci, PackedVector2Array([Vector2(150, -150) + o, Vector2(196, -138) + o, Vector2(190, -84) + o, Vector2(146, -92) + o]), face.darkened(0.15) * tint)
	_cut(ci, PackedVector2Array([Vector2(176, -136) + o, Vector2(232, -130) + o, Vector2(252, -100) + o, Vector2(238, -80) + o, Vector2(184, -84) + o]), face * tint)
	_cut(ci, PackedVector2Array([Vector2(226, -108) + o, Vector2(258, -100) + o, Vector2(256, -84) + o, Vector2(230, -84) + o]), MUZZLE * tint)
	var jaw := Vector2(0, 14.0 * pose.jaw)
	_cut(ci, PackedVector2Array([Vector2(196, -84) + o, Vector2(250, -84) + o + jaw, Vector2(236, -70) + o + jaw, Vector2(200, -74) + o]), face.darkened(0.25) * tint)
	# Horns sweeping out and up.
	_cut(ci, PackedVector2Array([Vector2(198, -132) + o, Vector2(174, -168) + o, Vector2(150, -176) + o, Vector2(170, -160) + o, Vector2(190, -126) + o]), HORN * tint)
	_cut(ci, PackedVector2Array([Vector2(218, -132) + o, Vector2(236, -170) + o, Vector2(258, -182) + o, Vector2(244, -162) + o, Vector2(226, -126) + o]), HORN * tint)
	# A glaring eye, brighter when the head lies open.
	ci.draw_circle(Vector2(214, -112) + o, 6.0, (EYE.lightened(0.3) if exposed else EYE) * tint)
	ci.draw_circle(Vector2(215, -112) + o, 2.5, Color(0.1, 0.05, 0.05))
	ci.draw_circle(Vector2(250, -94) + o, 2.0, Color(0.15, 0.08, 0.06))
	if exposed:
		var glow := PackedVector2Array([Vector2(170, -140) + o, Vector2(260, -140) + o, Vector2(262, -68) + o, Vector2(170, -68) + o, Vector2(170, -140) + o])
		ci.draw_polyline(glow, Color(1.0, 0.85, 0.3, 0.9), 3.0)


## A jointed leg: from where it joins the (moving) body, up to its knee and
## down to its foot; walking lifts feet in turn; a broken pair is a stump.
static func _leg(ci: CanvasItem, m: Monster, leg: Dictionary, pose: Dictionary, body: Transform2D, local: Transform2D, c: Color) -> void:
	var at: Vector2 = local.affine_inverse() * (body * leg.at)
	var knee: Vector2 = leg.knee
	var foot: Vector2 = leg.foot
	var part: String = leg.part
	var broken := part != "" and m.broken(part)
	var lift: float = pose.lift.get(part, 0.0)
	if pose.scuttle != 0.0:
		var step := maxf(0.0, sin(pose.scuttle + LEGS.find(leg) * 2.1))
		lift += 22.0 * step
		foot.x += 10.0 * cos(pose.scuttle + LEGS.find(leg) * 2.1)
	foot.y -= lift
	knee.y -= lift * 0.6
	if pose.reach.has(part):
		var r: Array = pose.reach[part]
		foot = foot.lerp(r[0], r[1])
		knee = knee.lerp((at + r[0]) / 2.0 + Vector2(0, -60), r[1])
	if broken:
		var stump := at.lerp(knee, 0.55)
		_limb(ci, at, stump, 12.0, 9.0, Color(0.35, 0.35, 0.35))
		return
	_limb(ci, at, knee, 13.0, 10.0, c)
	_limb(ci, knee, foot, 10.0, 3.0, c)
	ci.draw_circle(knee, 7.0, JOINT * Color(c.r * 2.0, c.g * 2.0, c.b * 2.0))


## A tapered limb segment in cut paper.
static func _limb(ci: CanvasItem, a: Vector2, b: Vector2, wa: float, wb: float, c: Color) -> void:
	var n := (b - a).normalized().orthogonal()
	_cut(ci, PackedVector2Array([a + n * wa / 2.0, b + n * wb / 2.0, b - n * wb / 2.0, a - n * wa / 2.0]), c)


static func _cut(ci: CanvasItem, shape: PackedVector2Array, c: Color) -> void:
	if Geometry2D.triangulate_polygon(shape).is_empty():
		shape = Geometry2D.convex_hull(shape)
	ci.draw_colored_polygon(shape, c)
	var loop := shape.duplicate()
	loop.append(shape[0])
	ci.draw_polyline(loop, INK, 1.0)
