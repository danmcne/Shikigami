extends RefCounted
## Gashadokuro in cut paper: a giant skeleton looming behind the arena. Its
## ribcage, spine and collarbones stand behind everything; its skull hangs
## high above, coming down to bite; its arms reach from its shoulders to its
## hands, which wait raised and come down to slam, or go out across the
## arena to grab and clap (those hands are pieces; the arms reach for them).
## Drawn over its gameplay parts, which stay the truth: a hand lies open
## after a slam, the skull after a bite, and a broken hand is a stump.

const BONE := Color("e8e0c8")
const SHADE := Color("c4b99c")
const SOCKET := Color("1d1818")
const GLOW := Color("d9483b")
const INK := Color(0.08, 0.06, 0.06, 0.6)
const SHOULDERS := [Vector2(-230, -555), Vector2(230, -555)]
const SKULL_REST := Vector2(0, -330)


static func draw(ci: CanvasItem, m: Monster, base: Transform2D, tint: Color, bout: Bout = null) -> void:
	var local := base * Transform2D(0.0, Vector2(m.facing, 1), 0.0, m.position)
	ci.draw_set_transform_matrix(local)
	var far := Color(tint.r * 0.82, tint.g * 0.82, tint.b * 0.86, 1.0)
	_spine(ci, far)
	_ribs(ci, far)
	# Collarbones from the neck to the shoulders.
	for s in SHOULDERS:
		_bone(ci, Vector2(0, -585), s, 16.0, BONE * far)
	var skull_at := _skull_offset(m)
	for side in [0, 1]:
		_arm(ci, m, side, local, bout, tint)
	_skull(ci, m, skull_at, tint)
	ci.draw_set_transform_matrix(base)


## Where the skull hangs: high at rest; coming down to bite (or for the
## jaws), down while it lies open, rising again afterwards.
static func _skull_offset(m: Monster) -> Vector2:
	var up := SKULL_REST
	if m.state == Fighter.State.DAZED or m.state == Fighter.State.KO:
		return Vector2.ZERO
	if m.state == Fighter.State.MOVE and m.move and m.move.id in [&"skull_bite", &"jaws"]:
		var phase := PuppetDefinition._phase(m.move, m.state_frame)
		if phase < 1.0:
			return up.lerp(Vector2.ZERO, phase * phase)
		if phase < 2.6:
			return Vector2.ZERO
		return Vector2.ZERO.lerp(up, (phase - 2.6) / 0.4)
	return up


static func _skull(ci: CanvasItem, m: Monster, o: Vector2, tint: Color) -> void:
	var open := m.exposed(2)
	var jaw := 0.0
	if m.state == Fighter.State.MOVE and m.move and m.move.id in [&"skull_bite", &"jaws"]:
		var phase := PuppetDefinition._phase(m.move, m.state_frame)
		jaw = 24.0 * clampf(1.0 - absf(phase - 1.0) * 2.0, 0.0, 1.0) if m.move.id == &"jaws" else 14.0 * clampf(phase, 0.0, 1.0) * (1.0 if phase < 1.2 else 0.0)
	var c := BONE.lightened(0.15) if open else BONE
	# Cranium, cheekbones, upper teeth; the jaw hangs below.
	_cut(ci, PackedVector2Array([Vector2(-78, -170), Vector2(-86, -205), Vector2(-62, -238), Vector2(0, -250), Vector2(62, -238),
			Vector2(86, -205), Vector2(78, -170), Vector2(52, -140), Vector2(-52, -140)]) , o, c * tint)
	_cut(ci, PackedVector2Array([Vector2(-52, -140), Vector2(52, -140), Vector2(44, -128), Vector2(-44, -128)]), o, SHADE * tint)
	for k in 7:
		var x := -36.0 + k * 12.0
		_cut(ci, PackedVector2Array([Vector2(x - 5, -130), Vector2(x + 5, -130), Vector2(x + 3, -118), Vector2(x - 3, -118)]), o, BONE * tint)
	var j := Vector2(0, jaw)
	_cut(ci, PackedVector2Array([Vector2(-58, -128), Vector2(58, -128), Vector2(50, -104), Vector2(0, -96), Vector2(-50, -104)]), o + j, SHADE * tint)
	# Eye sockets with an ember deep in each, and the nose.
	for x in [-34.0, 34.0]:
		_cut(ci, PackedVector2Array([Vector2(x - 20, -190), Vector2(x + 20, -190), Vector2(x + 16, -162), Vector2(x - 16, -162)]), o, SOCKET)
		ci.draw_circle(Vector2(x, -176) + o, 5.0, GLOW * tint)
	_cut(ci, PackedVector2Array([Vector2(-8, -158), Vector2(8, -158), Vector2(0, -142)]), o, SOCKET)
	if open:
		var glow := PackedVector2Array([Vector2(-90, -252), Vector2(90, -252), Vector2(90, -92), Vector2(-90, -92), Vector2(-90, -252)])
		for k in glow.size():
			glow[k] += o
		ci.draw_polyline(glow, Color(1.0, 0.85, 0.3, 0.9), 3.0)


## Where a hand is: raised at rest; coming down to slam over its start-up;
## down while it lies open; rising again. Or out in the arena, sweeping.
static func _arm(ci: CanvasItem, m: Monster, side: int, local: Transform2D, bout: Bout, tint: Color) -> void:
	var part: MonsterDefinition.Part = m.monster.parts[side]
	var down := part.box.get_center() + Vector2(0, 5)
	var up := down + part.rest_offset
	var hand := up
	var pointing := Vector2(0, 1)
	var name := "left" if side == 0 else "right"
	var out := false
	if m.state == Fighter.State.MOVE and m.move:
		var phase := PuppetDefinition._phase(m.move, m.state_frame)
		if m.move.id == StringName(name + "_slam"):
			if phase < 1.0:
				hand = up.lerp(down, phase * phase)
			elif phase < 2.6:
				hand = down
			else:
				hand = down.lerp(up, (phase - 2.6) / 0.4)
		elif m.move.id in [StringName(name + "_grab"), &"high_clap"] and phase >= 1.0 and bout:
			out = true
	if out:
		# Its hand is out sweeping the arena: the arm reaches for it.
		for e in bout.entities:
			if e.owner_index == 1 and e.move.id in [&"grasping_hand", &"clapping_hand"]:
				var at := Vector2((e.position.x - m.position.x) * m.facing, e.position.y)
				if (at.x < 0.0) == (side == 0):
					hand = at + Vector2(0, -20)
					pointing = Vector2(-signf(at.x), 0) if at.x != 0.0 else Vector2(0, 1)
	if m.state == Fighter.State.DAZED or m.state == Fighter.State.KO:
		hand = down + Vector2(0, -10)
	var shoulder: Vector2 = SHOULDERS[side]
	var elbow := (shoulder + hand) / 2.0 + Vector2(-60 if side == 0 else 60, 20)
	_bone(ci, shoulder, elbow, 22.0, BONE * tint)
	_bone(ci, elbow, hand, 18.0, BONE * tint)
	ci.draw_circle(elbow, 13.0, SHADE * tint)
	if out:
		return
	if m.broken(part.name):
		# A cracked stump where the hand was.
		_cut(ci, PackedVector2Array([hand + Vector2(-14, -6), hand + Vector2(14, -6), hand + Vector2(8, 14), hand + Vector2(0, 6), hand + Vector2(-8, 16)]), Vector2.ZERO, Color(0.45, 0.43, 0.4))
		return
	hand_shape(ci, hand, pointing, 1.0, (BONE.lightened(0.12) if m.exposed(side) else BONE) * tint)
	if m.exposed(side):
		ci.draw_arc(hand + Vector2(0, 20), 70.0, 0.0, TAU, 24, Color(1.0, 0.85, 0.3, 0.8), 3.0)


## A great skeletal hand at `at`, fingers pointing along `toward`.
static func hand_shape(ci: CanvasItem, at: Vector2, toward: Vector2, size: float, c: Color) -> void:
	var f := toward.normalized()
	var s := f.orthogonal()
	var palm := PackedVector2Array([at - s * 34 * size, at + s * 34 * size, at + s * 30 * size + f * 34 * size, at - s * 30 * size + f * 34 * size])
	_cut(ci, palm, Vector2.ZERO, c)
	for k in 4:
		var root := at + f * 34 * size + s * (-24.0 + k * 16.0) * size
		var mid := root + f * 26 * size + s * (k - 1.5) * 3.0 * size
		var tip := mid + f * 22 * size
		_bone(ci, root, mid, 9.0 * size, c)
		_bone(ci, mid, tip, 7.0 * size, c)
	_bone(ci, at - s * 32 * size + f * 8 * size, at - s * 52 * size + f * 30 * size, 9.0 * size, c)


static func _spine(ci: CanvasItem, tint: Color) -> void:
	for k in 9:
		var y := -300.0 + k * 33.0
		_cut(ci, PackedVector2Array([Vector2(-22, y), Vector2(22, y), Vector2(18, y + 26), Vector2(-18, y + 26)]), Vector2.ZERO, BONE * tint)
		_cut(ci, PackedVector2Array([Vector2(-34, y + 8), Vector2(-22, y + 6), Vector2(-22, y + 16), Vector2(-34, y + 14)]), Vector2.ZERO, SHADE * tint)
		_cut(ci, PackedVector2Array([Vector2(22, y + 6), Vector2(34, y + 8), Vector2(34, y + 14), Vector2(22, y + 16)]), Vector2.ZERO, SHADE * tint)


static func _ribs(ci: CanvasItem, tint: Color) -> void:
	# The sternum, and six pairs of ribs curving down and round from it.
	_cut(ci, PackedVector2Array([Vector2(-14, -585), Vector2(14, -585), Vector2(10, -330), Vector2(-10, -330)]), Vector2.ZERO, BONE * tint)
	for k in 6:
		var y := -560.0 + k * 40.0
		var reach := 150.0 - absf(k - 2.0) * 12.0
		for sgn in [-1.0, 1.0]:
			var rib := PackedVector2Array()
			for i in 7:
				var a := float(i) / 6.0
				rib.append(Vector2(sgn * (14 + reach * sin(a * PI * 0.9)), y + 50 * a * a - 6))
			for i in range(6, -1, -1):
				var a := float(i) / 6.0
				rib.append(Vector2(sgn * (14 + (reach - 12) * sin(a * PI * 0.9)), y + 50 * a * a + 8))
			_cut(ci, rib, Vector2.ZERO, BONE * tint)


static func _bone(ci: CanvasItem, a: Vector2, b: Vector2, w: float, c: Color) -> void:
	var n := (b - a).normalized().orthogonal() * w / 2.0
	_cut(ci, PackedVector2Array([a + n, b + n, b - n, a - n]), Vector2.ZERO, c)
	ci.draw_circle(a, w * 0.62, c)
	ci.draw_circle(b, w * 0.62, c)


static func _cut(ci: CanvasItem, shape: PackedVector2Array, o: Vector2, c: Color) -> void:
	var moved := shape.duplicate()
	for k in moved.size():
		moved[k] += o
	ci.draw_colored_polygon(moved, c)
	var loop := moved.duplicate()
	loop.append(moved[0])
	ci.draw_polyline(loop, INK, 1.0)
