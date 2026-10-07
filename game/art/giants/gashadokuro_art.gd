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
## Skull high in the frame; below it the neck, then shoulders, ribcage and a
## spine running down through the ribs to the ground.
const SKULL_REST := Vector2(0, -330)
const NECK := Vector2(0, -448)
const SHOULDERS := [Vector2(-200, -430), Vector2(200, -430)]


## Behind the fighters: the body, the arms, the skull (even when it comes
## down to bite), and the hands at rest.
static func draw_back(ci: CanvasItem, m: Monster, base: Transform2D, tint: Color, bout: Bout = null) -> void:
	var local := base * Transform2D(0.0, Vector2(m.facing, 1), 0.0, m.position)
	ci.draw_set_transform_matrix(local)
	var far := Color(tint.r * 0.85, tint.g * 0.85, tint.b * 0.88, 1.0)
	_spine(ci, far)
	_ribs(ci, far)
	for s in SHOULDERS:
		_bone(ci, NECK + Vector2(0, 10), s, 15.0, BONE * far)
	for side in [0, 1]:
		var arm := _arm(m, side, bout)
		_bone(ci, SHOULDERS[side], arm.elbow, 22.0, BONE * tint)
		_bone(ci, arm.elbow, arm.hand, 18.0, BONE * tint)
		ci.draw_circle(arm.elbow, 13.0, SHADE * tint)
		if not arm.striking:
			_draw_hand(ci, m, side, arm, tint)
	_skull(ci, m, _skull_offset(m), tint)
	ci.draw_set_transform_matrix(base)


## Before the fighters: a hand coming down on them, or lying where it fell.
static func draw_front(ci: CanvasItem, m: Monster, base: Transform2D, tint: Color, bout: Bout = null) -> void:
	var local := base * Transform2D(0.0, Vector2(m.facing, 1), 0.0, m.position)
	ci.draw_set_transform_matrix(local)
	for side in [0, 1]:
		var arm := _arm(m, side, bout)
		if arm.striking:
			_draw_hand(ci, m, side, arm, tint)
	ci.draw_set_transform_matrix(base)


static func draw(ci: CanvasItem, m: Monster, base: Transform2D, tint: Color, bout: Bout = null) -> void:
	draw_back(ci, m, base, tint, bout)
	draw_front(ci, m, base, tint, bout)


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
	_cut(ci, PackedVector2Array([Vector2(0, -160), Vector2(8, -142), Vector2(-8, -142)]), o, SOCKET)
	if open:
		var glow := PackedVector2Array([Vector2(-90, -252), Vector2(90, -252), Vector2(90, -92), Vector2(-90, -92), Vector2(-90, -252)])
		for k in glow.size():
			glow[k] += o
		ci.draw_polyline(glow, Color(1.0, 0.85, 0.3, 0.9), 3.0)


## Where a hand is and where its elbow goes: raised at rest; coming down
## over a slam's start-up; down while it lies open; rising again. While its
## hand is out sweeping the arena (a piece, for as long as that piece lasts)
## the arm reaches for it instead and draws no hand of its own.
static func _arm(m: Monster, side: int, bout: Bout) -> Dictionary:
	var part: MonsterDefinition.Part = m.monster.parts[side]
	var down := part.box.get_center() + Vector2(0, 5)
	var up := down + part.rest_offset
	var hand := up
	var striking := false
	var out := false
	var name := "left" if side == 0 else "right"
	if m.state == Fighter.State.MOVE and m.move and m.move.id == StringName(name + "_slam"):
		var phase := PuppetDefinition._phase(m.move, m.state_frame)
		striking = true
		if phase < 1.0:
			hand = up.lerp(down, phase * phase)
		elif phase < 2.6:
			hand = down
		else:
			hand = down.lerp(up, (phase - 2.6) / 0.4)
	if bout:
		for e in bout.entities:
			# Its hands travel inward: the left one rightward, the right leftward.
			if e.owner_index == 1 and e.move.id in [&"grasping_hand", &"clapping_hand"] and (e.facing * m.facing > 0) == (side == 0):
				hand = Vector2((e.position.x - m.position.x) * m.facing, e.position.y - (20.0 if e.move.id == &"grasping_hand" else 230.0))
				out = true
	if m.state == Fighter.State.DAZED or m.state == Fighter.State.KO:
		hand = down + Vector2(0, -10)
	var shoulder: Vector2 = SHOULDERS[side]
	var outward := -1.0 if side == 0 else 1.0
	var elbow := (shoulder + hand) / 2.0 + Vector2(outward * 70.0, 10.0)
	return {hand = hand, elbow = elbow, striking = striking, out = out}


static func _draw_hand(ci: CanvasItem, m: Monster, side: int, arm: Dictionary, tint: Color) -> void:
	if arm.out:
		return
	var part: MonsterDefinition.Part = m.monster.parts[side]
	var hand: Vector2 = arm.hand
	if m.broken(part.name):
		# A cracked stump where the hand was.
		_cut(ci, PackedVector2Array([hand + Vector2(-14, -6), hand + Vector2(14, -6), hand + Vector2(8, 14), hand + Vector2(0, 6), hand + Vector2(-8, 16)]), Vector2.ZERO, Color(0.45, 0.43, 0.4))
		return
	# Thumbs turned in, toward the skeleton's middle.
	var open := m.exposed(side)
	hand_shape(ci, hand, Vector2(0, 1), 1.0, (BONE.lightened(0.12) if open else BONE) * tint, 1.0 if side == 0 else -1.0)
	if open:
		ci.draw_arc(hand + Vector2(0, 20), 70.0, 0.0, TAU, 24, Color(1.0, 0.85, 0.3, 0.8), 3.0)


## A great skeletal hand at `at`, fingers pointing along `toward`, its thumb
## on one side (`thumb` +1 or -1).
static func hand_shape(ci: CanvasItem, at: Vector2, toward: Vector2, size: float, c: Color, thumb := 1.0) -> void:
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
	_bone(ci, at + s * thumb * 32 * size + f * 8 * size, at + s * thumb * 52 * size + f * 30 * size, 9.0 * size, c)


static func _spine(ci: CanvasItem, tint: Color) -> void:
	# From the neck down through the ribcage to the ground.
	var y := NECK.y
	while y < -30.0:
		_cut(ci, PackedVector2Array([Vector2(-18, y), Vector2(18, y), Vector2(15, y + 22), Vector2(-15, y + 22)]), Vector2.ZERO, BONE * tint)
		_cut(ci, PackedVector2Array([Vector2(-30, y + 7), Vector2(-18, y + 5), Vector2(-18, y + 14), Vector2(-30, y + 12)]), Vector2.ZERO, SHADE * tint)
		_cut(ci, PackedVector2Array([Vector2(18, y + 5), Vector2(30, y + 7), Vector2(30, y + 12), Vector2(18, y + 14)]), Vector2.ZERO, SHADE * tint)
		y += 27.0


static func _ribs(ci: CanvasItem, tint: Color) -> void:
	# Six pairs, each a chain of bone curving out from the spine and down.
	for k in 6:
		var y := -420.0 + k * 26.0
		var reach := 150.0 - absf(k - 1.5) * 14.0
		for sgn in [-1.0, 1.0]:
			var prev := Vector2(sgn * 16.0, y)
			for i in range(1, 7):
				var a := float(i) / 6.0
				var next := Vector2(sgn * (16.0 + reach * sin(a * PI * 0.85)), y + 46.0 * a * a)
				_bone(ci, prev, next, 9.0, BONE * tint)
				prev = next


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
