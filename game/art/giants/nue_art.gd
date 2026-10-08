extends RefCounted
## Nue in cut paper: a monkey's face, a tanuki's body, a tiger's legs, a
## living snake for a tail, riding a black thundercloud. Drawn over its
## gameplay parts (body, face, tail, cloud), which stay the truth: the face
## glows as the weak point it is, and a broken cloud is gone, Nue grounded.
## In flight its legs tuck and it bobs; grounded it walks. Each attack has
## its own motion. All of it is drawn behind the fighters (it can be ridden).

const FUR := Color("7a5a3e")
const PATCH := Color("5a4030")
const BELLY := Color("b89878")
const TIGER := Color("d9862b")
const STRIPE := Color("1d1411")
const CLAW := Color("efe6d0")
const FACE := Color("c0392b")
const RUFF := Color("c8b090")
const EYE := Color("f0c840")
const SNAKE := Color("4f7a3e")
const SNAKE_BELLY := Color("a8c070")
const CLOUD := Color("2a2830")
const CLOUD_EDGE := Color("4a4752")
const BOLT := Color("f6e27a")
const INK := Color(0.08, 0.06, 0.06, 0.55)


static func draw_back(ci: CanvasItem, m: Monster, base: Transform2D, tint: Color, bout: Bout = null) -> void:
	draw(ci, m, base, tint, bout)


static func draw_front(_ci: CanvasItem, _m: Monster, _base: Transform2D, _tint: Color, _bout: Bout = null) -> void:
	pass


static func draw(ci: CanvasItem, m: Monster, base: Transform2D, tint: Color, _bout: Bout = null) -> void:
	var pose := _pose(m)
	var local := base * Transform2D(0.0, Vector2(m.facing, 1), 0.0, m.position + Vector2(0, pose.bob))
	var body := local * Transform2D(deg_to_rad(pose.tilt), Vector2(0, -45)) * Transform2D(0.0, Vector2(0, 45))
	if not m.broken("thundercloud"):
		ci.draw_set_transform_matrix(local)
		_cloud(ci, m, pose, tint)
	ci.draw_set_transform_matrix(body)
	_tail(ci, pose, tint)
	for leg in _legs(m, pose):
		if not leg.near:
			_tiger_leg(ci, leg, TIGER.darkened(0.3) * tint)
	_body(ci, tint)
	_head(ci, m, pose, tint)
	for leg in _legs(m, pose):
		if leg.near:
			_tiger_leg(ci, leg, TIGER * tint)
	ci.draw_set_transform_matrix(base)


static func _pose(m: Monster) -> Dictionary:
	var t := m.state_frame
	var flying := m.flying() and m.position.y < -30.0
	var pose := {tilt = 0.0, bob = 0.0, flying = flying, tuck = 1.0 if flying else 0.0, walk = 0.0, head = Vector2.ZERO,
			snake = Vector2(-178, -112), swipe = [], stretch = 0.0, flash = 0.0}
	if flying:
		pose.bob = 4.0 * sin(Time.get_ticks_msec() * 0.004)
	elif m.state == Fighter.State.WALK:
		pose.walk = m.position.x * 0.07 * m.facing
	match m.state:
		Fighter.State.HITSTUN:
			pose.tilt = 6.0 * sin(t * 1.4)
		Fighter.State.KO, Fighter.State.DAZED:
			pose.tilt = 8.0
			pose.tuck = 0.0
		Fighter.State.MOVE:
			var mv := m.move
			var phase := PuppetDefinition._phase(mv, t)
			var wind := clampf(phase, 0.0, 1.0)
			var on := phase >= 1.0 and phase < 2.0
			match mv.id:
				&"lightning":
					pose.head = Vector2(-4, -14) * wind
					pose.tilt = -8.0 * wind
					pose.flash = 1.0 if phase >= 0.7 and phase < 2.2 else 0.0
				&"dive":
					# Rearing back, then plunging claws first; then sprawled, open.
					pose.tilt = -16.0 * wind if phase < 1.0 else (28.0 if on else 0.0)
					pose.tuck = 0.0
					if on:
						pose.swipe = [["lead", Vector2(130, -10)], ["trail", Vector2(90, 0)]]
				&"tail_strike":
					if on:
						pose.snake = mv.hitboxes[0].get_center()
					else:
						pose.snake = Vector2(-150, -150).lerp(Vector2(-178, -112), 1.0 - wind) if phase < 1.0 else pose.snake
				&"thrash":
					pose.tilt = 14.0 * sin(t * 0.8) * (1.0 if phase >= 0.5 else wind)
				&"claw":
					pose.swipe = [["lead", mv.hitboxes[0].get_center() if on else Vector2(70, -110).lerp(Vector2(60, -60), 1.0 - wind)]]
				&"tail_lash":
					if on:
						pose.snake = mv.hitboxes[1].get_center()
						pose.swipe = [["lead", mv.hitboxes[0].get_center()]]
				&"pounce":
					pose.stretch = wind if phase < 2.0 else clampf(3.0 - phase, 0.0, 1.0)
					pose.tilt = -10.0 * pose.stretch
	return pose


## Four legs; each a hip, a knee and a paw (local to the body, facing +x).
static func _legs(m: Monster, pose: Dictionary) -> Array:
	var legs: Array = []
	var spec := [
		{side = "lead", near = false, hip = Vector2(55, -45), paw = Vector2(70, 0)},
		{side = "trail", near = false, hip = Vector2(-55, -45), paw = Vector2(-70, 0)},
		{side = "lead", near = true, hip = Vector2(65, -40), paw = Vector2(85, 0)},
		{side = "trail", near = true, hip = Vector2(-65, -40), paw = Vector2(-55, 0)},
	]
	for k in spec.size():
		var leg: Dictionary = spec[k].duplicate()
		var paw: Vector2 = leg.paw
		if pose.walk != 0.0:
			var step := sin(pose.walk + k * PI * 0.5)
			paw += Vector2(14.0 * step, -10.0 * maxf(0.0, step))
		# Tucked up under the body in flight.
		paw = paw.lerp(leg.hip + Vector2(signf(leg.paw.x) * 22.0, 22.0), pose.tuck)
		# Stretched out in a pounce: fore legs reach forward, hind legs back.
		if pose.stretch > 0.0:
			paw = paw.lerp(leg.hip + (Vector2(70, -10) if leg.side == "lead" else Vector2(-70, 10)), pose.stretch)
		for s in pose.swipe:
			if s[0] == leg.side and leg.near:
				paw = s[1]
		leg.paw = paw
		leg.knee = (leg.hip + paw) / 2.0 + Vector2(-8.0 * signf(paw.x - leg.hip.x + 0.01), -6)
		legs.append(leg)
	return legs


static func _tiger_leg(ci: CanvasItem, leg: Dictionary, c: Color) -> void:
	_limb(ci, leg.hip, leg.knee, 24.0, 18.0, c)
	_limb(ci, leg.knee, leg.paw, 18.0, 14.0, c)
	# Black stripes across each segment.
	for seg in [[leg.hip, leg.knee], [leg.knee, leg.paw]]:
		for f in [0.35, 0.7]:
			var at: Vector2 = (seg[0] as Vector2).lerp(seg[1], f)
			var n: Vector2 = ((seg[1] as Vector2) - seg[0]).normalized().orthogonal()
			_cut(ci, PackedVector2Array([at + n * 8, at + n * 9 + (seg[1] - seg[0]).normalized() * 4, at - n * 8, at - n * 7 - (seg[1] - seg[0]).normalized() * 3]), STRIPE)
	# The paw and its claws.
	ci.draw_circle(leg.paw, 10.0, c)
	for k in 3:
		var tip: Vector2 = leg.paw + Vector2(8 + k * 3, 4 + k * 2)
		_cut(ci, PackedVector2Array([leg.paw + Vector2(4, -2 + k * 3), tip, leg.paw + Vector2(4, 2 + k * 3)]), CLAW)


static func _body(ci: CanvasItem, tint: Color) -> void:
	# A tanuki's round body in shaggy fur: a tufted outline, a pale belly, and
	# darker fur streaked along the back (not plates: it must not read as a shell).
	var shape := PackedVector2Array()
	for k in 28:
		var a := k * TAU / 28.0
		var tuft := 1.0 if k % 2 == 0 else 0.9
		shape.append(Vector2(cos(a) * 92.0 * tuft, -50.0 + sin(a) * 46.0 * tuft))
	_cut(ci, shape, FUR * tint)
	var belly := PackedVector2Array()
	for k in 9:
		var a := PI * 0.15 + k * PI * 0.7 / 8.0
		belly.append(Vector2(cos(a) * 70.0, -50.0 + sin(a) * 30.0))
	belly.append(Vector2(-40, -40))
	belly.append(Vector2(40, -40))
	_cut(ci, Geometry2D.convex_hull(belly), BELLY * tint)
	# Soft bands of darker fur across the back.
	for k in 3:
		var x := -48.0 + k * 40.0
		_cut(ci, PackedVector2Array([Vector2(x - 14, -90), Vector2(x + 8, -94), Vector2(x + 16, -74), Vector2(x - 6, -70)]), FUR.darkened(0.18) * tint)


static func _head(ci: CanvasItem, m: Monster, pose: Dictionary, tint: Color) -> void:
	var o: Vector2 = pose.head
	var open := false
	for k in m.monster.parts.size():
		if m.monster.parts[k].name == "face":
			open = true  # the face is always exposed: it is the weak point
	# A thick neck of fur from the front of the body up into the ruff, which
	# follows the head wherever it goes.
	var neck_from := Vector2(66, -66)
	var neck_to := Vector2(106, -92) + o
	var across := (neck_to - neck_from).normalized().orthogonal()
	_cut(ci, PackedVector2Array([neck_from + across * 24, neck_to + across * 20, neck_to - across * 20, neck_from - across * 26]), FUR * tint)
	# The ruff, then the red face, brow, eye, muzzle.
	var ruff := PackedVector2Array()
	for k in 12:
		var a := k * TAU / 12.0
		var r := 34.0 if k % 2 == 0 else 26.0
		ruff.append(Vector2(110, -95) + o + Vector2(cos(a), sin(a)) * r)
	_cut(ci, ruff, RUFF * tint)
	_cut(ci, PackedVector2Array([Vector2(98, -116) + o, Vector2(128, -118) + o, Vector2(140, -98) + o, Vector2(134, -78) + o, Vector2(104, -76) + o, Vector2(96, -94) + o]), FACE * tint)
	_cut(ci, PackedVector2Array([Vector2(104, -110) + o, Vector2(136, -108) + o, Vector2(134, -103) + o, Vector2(106, -104) + o]), RUFF.lightened(0.3) * tint)
	ci.draw_circle(Vector2(126, -98) + o, 4.5, EYE * tint)
	ci.draw_circle(Vector2(127, -98) + o, 2.0, Color(0.1, 0.05, 0.05))
	_cut(ci, PackedVector2Array([Vector2(122, -88) + o, Vector2(142, -88) + o, Vector2(138, -80) + o, Vector2(122, -80) + o]), FACE.darkened(0.2) * tint)
	if open and m.state == Fighter.State.HITSTUN:
		ci.draw_arc(Vector2(118, -96) + o, 36.0, 0.0, TAU, 20, Color(1.0, 0.85, 0.3, 0.8), 2.5)


## The snake for a tail: a tapering body curving from the rump to its head,
## which goes where the tail strikes.
static func _tail(ci: CanvasItem, pose: Dictionary, tint: Color) -> void:
	var root := Vector2(-92, -58)
	var head: Vector2 = pose.snake
	var bend := (root + head) / 2.0 + Vector2(20, 40)
	var prev := root
	for i in range(1, 11):
		var f := i / 10.0
		var p := root.lerp(bend, f).lerp(bend.lerp(head, f), f)
		_limb(ci, prev, p, lerpf(18.0, 9.0, f - 0.1), lerpf(18.0, 9.0, f), SNAKE * tint)
		prev = p
	var dir := (head - bend).normalized()
	var side := dir.orthogonal()
	_cut(ci, PackedVector2Array([head - dir * 4 + side * 9, head + dir * 16, head - dir * 4 - side * 9]), SNAKE.darkened(0.15) * tint)
	ci.draw_circle(head + dir * 4 + side * 3, 2.0, EYE)
	ci.draw_line(head + dir * 16, head + dir * 24 + side * 3, Color("c0392b"), 1.5)


## The thundercloud it rides: dark billows, crackling as it flies, flashing
## when it calls down lightning.
static func _cloud(ci: CanvasItem, m: Monster, pose: Dictionary, tint: Color) -> void:
	var t := Time.get_ticks_msec() * 0.002
	var lit: float = pose.flash
	for k in 9:
		var x := -120.0 + k * 30.0
		var y := 18.0 + sin(t + k * 1.3) * 4.0
		var r := 26.0 + 6.0 * sin(t * 1.3 + k)
		ci.draw_circle(Vector2(x, y), r + 3.0, CLOUD_EDGE.lightened(0.3 * lit) * tint)
	for k in 9:
		var x := -120.0 + k * 30.0
		var y := 20.0 + sin(t + k * 1.3) * 4.0
		ci.draw_circle(Vector2(x, y), 24.0 + 6.0 * sin(t * 1.3 + k), CLOUD.lightened(0.25 * lit) * tint)
	if lit > 0.0 or fmod(t, 2.4) < 0.15:
		var x := -60.0 + fmod(t * 97.0, 120.0)
		_zigzag(ci, Vector2(x, 10), Vector2(x + 8, 46), 4, BOLT)


static func _zigzag(ci: CanvasItem, a: Vector2, b: Vector2, kinks: int, c: Color) -> void:
	var line := PackedVector2Array([a])
	for k in range(1, kinks):
		var p := a.lerp(b, float(k) / kinks)
		line.append(p + Vector2(8.0 if k % 2 == 0 else -8.0, 0))
	line.append(b)
	ci.draw_polyline(line, c, 3.0)


static func _limb(ci: CanvasItem, a: Vector2, b: Vector2, wa: float, wb: float, c: Color) -> void:
	var n := (b - a).normalized().orthogonal()
	_cut(ci, PackedVector2Array([a + n * wa / 2.0, b + n * wb / 2.0, b - n * wb / 2.0, a - n * wa / 2.0]), c)
	ci.draw_circle(b, wb / 2.0, c)


static func _cut(ci: CanvasItem, shape: PackedVector2Array, c: Color) -> void:
	if Geometry2D.triangulate_polygon(shape).is_empty():
		shape = Geometry2D.convex_hull(shape)
	ci.draw_colored_polygon(shape, c)
	var loop := shape.duplicate()
	loop.append(shape[0])
	ci.draw_polyline(loop, INK, 1.0)
