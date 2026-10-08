class_name Pieces
extends RefCounted
## Pictures for what fighters send out (projectiles, traps, heads) and for
## the visible effects of some strikes, in the same cut-paper language as the
## puppets. A piece's hitboxes stay the truth; F1 shows them over the art.

const INK := Color(0.08, 0.06, 0.06, 0.6)
const PuppetsRegistry := preload("res://game/art/puppets/registry.gd")

const DRAWN := [&"shuriken_star", &"paper_bird", &"water", &"water_wave", &"icicle_shard", &"web_strand",
		&"thrown_lantern", &"lantern_fire", &"flying_head", &"poison_cloud", &"grasping_hand", &"clapping_hand", &"falling_bone", &"bolt",
		&"ofuda_paper", &"warding_seal_trap", &"seal_barrier", &"dust", &"gale"]
const GashaArt := preload("res://game/art/giants/gashadokuro_art.gd")


static func has_art(id: StringName) -> bool:
	return id in DRAWN


## Draws entity `e`; false if it has no picture (it is then drawn as boxes).
static func draw(ci: CanvasItem, bout: Bout, e: Entity, base: Transform2D, colourways: Array) -> bool:
	if not has_art(e.move.id):
		return false
	var t := base * Transform2D(0.0, Vector2(e.facing, 1), 0.0, e.position)
	ci.draw_set_transform_matrix(t)
	var f := e.frame
	match e.move.id:
		&"shuriken_star":
			var star := PackedVector2Array()
			for k in 8:
				var r := 12.0 if k % 2 == 0 else 4.0
				var a := k * PI / 4.0 + f * 0.6
				star.append(Vector2(cos(a), sin(a)) * r)
			_cut(ci, star, Color("cfd5da"))
			ci.draw_circle(Vector2.ZERO, 2.5, Color("2a2a30"))
		&"paper_bird":
			# An origami bird, wings beating.
			var flap := sin(f * 0.5) * 9.0
			_cut(ci, PackedVector2Array([Vector2(16, 0), Vector2(-12, -3), Vector2(-14, 3)]), Color("f4efe3"))
			_cut(ci, PackedVector2Array([Vector2(4, -1), Vector2(-6, -1), Vector2(-2, -10 - flap)]), Color("ece4d2"))
			_cut(ci, PackedVector2Array([Vector2(18, -2), Vector2(14, 0), Vector2(22, -6)]), Color("f4efe3"))
		&"water":
			# A jet driven down and forward: a long drop and its trail.
			var dir := Vector2(e.move.motion.x, e.move.motion.y).normalized()
			var side := Vector2(-dir.y, dir.x)
			_cut(ci, PackedVector2Array([dir * 16, side * 7, -dir * 26, -side * 7]), Color("8fc4e8", 0.9))
			for k in 3:
				ci.draw_circle(-dir * (34 + k * 10) + side * sin(f * 0.7 + k) * 3, 4.0 - k, Color("b8dcf2", 0.8))
		&"water_wave":
			var crest := PackedVector2Array([Vector2(-22, 0), Vector2(-14, -10), Vector2(-2, -18 - sin(f * 0.6) * 3),
					Vector2(12, -14), Vector2(22, -4), Vector2(24, 0)])
			_cut(ci, crest, Color("8fc4e8", 0.9))
			_cut(ci, PackedVector2Array([Vector2(-2, -18), Vector2(8, -22), Vector2(12, -14)]), Color("eef6fb"))
		&"icicle_shard":
			_cut(ci, PackedVector2Array([Vector2(-8, -34), Vector2(8, -34), Vector2(3, -8), Vector2(0, 2), Vector2(-3, -8)]), Color("cfeaf6", 0.95))
			_cut(ci, PackedVector2Array([Vector2(-2, -32), Vector2(2, -32), Vector2(0, -4)]), Color("ffffff", 0.9), false)
		&"web_strand":
			# The web, and its strand back to the spider's hand.
			ci.draw_set_transform_matrix(base)
			var owner := bout.fighters[e.owner_index]
			var hand := owner.position + Vector2(owner.facing * 30, -110)
			ci.draw_line(hand, e.position, Color("f2f2f0", 0.8), 1.5)
			ci.draw_set_transform_matrix(t)
			for k in 8:
				var a := k * PI / 4.0 + f * 0.05
				ci.draw_line(Vector2.ZERO, Vector2(cos(a), sin(a)) * 16, Color("f2f2f0", 0.85), 1.2)
			for r in [6.0, 11.0, 16.0]:
				var ring := PackedVector2Array()
				for k in 9:
					var a := k * PI / 4.0 + f * 0.05
					ring.append(Vector2(cos(a), sin(a)) * r)
				ci.draw_polyline(ring, Color("f2f2f0", 0.7), 1.0)
		&"thrown_lantern":
			ci.draw_set_transform_matrix(t * Transform2D(f * 0.12, Vector2.ZERO))
			_lantern(ci)
		&"lantern_fire":
			for k in 4:
				var x := -36.0 + k * 24.0
				var h := 34.0 + sin(f * 0.4 + k * 1.7) * 10.0
				_cut(ci, PackedVector2Array([Vector2(x - 12, 0), Vector2(x - 4, -h * 0.6), Vector2(x, -h), Vector2(x + 5, -h * 0.5), Vector2(x + 12, 0)]), Color("e2572b", 0.9), false)
				_cut(ci, PackedVector2Array([Vector2(x - 6, 0), Vector2(x, -h * 0.55), Vector2(x + 6, 0)]), Color("f6c24a", 0.95), false)
		&"grasping_hand":
			# A skeletal hand sweeping along the floor, fingers leading.
			GashaArt.hand_shape(ci, Vector2(-30, -40), Vector2(1, 0), 0.9, GashaArt.BONE, 1.0)
		&"clapping_hand":
			# Upright, palm forward, sweeping in at head height and above.
			GashaArt.hand_shape(ci, Vector2(-30, -250), Vector2(1, -0.15), 1.4, GashaArt.BONE, 1.0)
		&"falling_bone":
			ci.draw_set_transform_matrix(t * Transform2D(f * 0.15, Vector2(0, -20)))
			GashaArt._bone(ci, Vector2(-34, 0), Vector2(34, 0), 12.0, GashaArt.BONE)
		&"dust":
			# A pinch of fox-fire powder: glinting motes drifting and spreading.
			for k in 14:
				var a := k * 2.39996
				var r := 4.0 + fmod(k * 7.3 + f * 1.4, 26.0)
				var at := Vector2(cos(a) * r, sin(a) * r * 0.7)
				ci.draw_circle(at, 2.5 - r / 20.0, Color(1.0, 0.75, 0.35, 0.85 - r / 40.0))
			ci.draw_circle(Vector2.ZERO, 6.0, Color(0.6, 0.85, 1.0, 0.45))
		&"gale":
			# A gust of wind: streaming strokes that curl at their heads.
			for k in 6:
				var y := -140.0 + k * 26.0
				var shift := fmod(f * 9.0 + k * 13.0, 40.0)
				var stroke := PackedVector2Array()
				for i in 9:
					var x := -50.0 + i * 9.0 + shift - 20.0
					stroke.append(Vector2(x, y + sin(i * 0.8 + f * 0.3 + k) * 4.0))
				var head := stroke[-1]
				for i in 5:
					var a := -PI / 2.0 + i * 0.7
					stroke.append(head + Vector2(cos(a), sin(a) + 1.0) * 6.0)
				ci.draw_polyline(stroke, Color(0.92, 0.96, 1.0, 0.75 - k * 0.05), 2.5)
		&"ofuda_paper":
			# A talisman in flight: a paper strip with a red border and black
			# brush strokes, fluttering.
			ci.draw_set_transform_matrix(t * Transform2D(sin(f * 0.4) * 0.25, Vector2.ZERO))
			_talisman(ci, Vector2.ZERO, 1.0)
		&"warding_seal_trap":
			# A talisman lying on the ground inside a faint ring of light.
			ci.draw_arc(Vector2(0, -2), 28.0, 0.0, TAU, 28, Color(0.95, 0.75, 0.3, 0.35 + 0.2 * sin(f * 0.15)), 3.0)
			ci.draw_set_transform_matrix(t * Transform2D(PI / 2.0, Vector2(0, -4)))
			_talisman(ci, Vector2.ZERO, 0.8)
		&"seal_barrier":
			# The five-element seal: a tall pane of light, the five-pointed star
			# of the elements at its heart, talismans hanging down it.
			ci.draw_rect(Rect2(-12, -180, 24, 180), Color(0.95, 0.85, 0.5, 0.18 + 0.06 * sin(f * 0.2)))
			ci.draw_rect(Rect2(-12, -180, 24, 180), Color(0.95, 0.8, 0.4, 0.6), false, 1.5)
			var star := PackedVector2Array()
			for k in 6:
				var a := -PI / 2.0 + k * TAU * 2.0 / 5.0
				star.append(Vector2(0, -105) + Vector2(cos(a), sin(a)) * 30.0)
			ci.draw_arc(Vector2(0, -105), 33.0, 0.0, TAU, 32, Color(0.9, 0.2, 0.15, 0.85), 2.0)
			ci.draw_polyline(star, Color(0.9, 0.2, 0.15, 0.9), 2.5)
			for y in [-170.0, -60.0]:
				_talisman(ci, Vector2(0, y + 18), 0.75)
		&"bolt":
			# A lightning bolt: its mark is shown while it gathers; then it strikes,
			# jagged, from the sky to the ground.
			if e.move.is_active_on(f):
				var line := PackedVector2Array()
				var y := -700.0
				var k := 0
				while y < 0.0:
					line.append(Vector2((10.0 if k % 2 == 0 else -10.0) + sin(f * 3.0 + k) * 4.0, y))
					y += 50.0
					k += 1
				line.append(Vector2(0, 0))
				ci.draw_polyline(line, Color(1.0, 0.98, 0.8, 0.9), 9.0)
				ci.draw_polyline(line, Color("f6e27a"), 4.0)
		&"poison_cloud":
			# A drifting cloud of poison, puffs swelling and thinning.
			for k in 5:
				var at := Vector2(cos(k * 1.3 + f * 0.05) * 18.0, sin(k * 2.1 + f * 0.07) * 12.0)
				ci.draw_circle(at, 14.0 + 4.0 * sin(f * 0.1 + k), Color(0.55, 0.35, 0.65, 0.45))
		&"flying_head":
			var owner := bout.fighters[e.owner_index]
			var p := PuppetsRegistry.for_id(owner.definition.id)
			if p == null:
				return false
			Puppet.draw_head(ci, owner, p, e.position, e.facing, base, colourways[e.owner_index])
	ci.draw_set_transform_matrix(base)
	return true


## The visible effect of a strike while it is active (a breath of frost, a
## drum's shockwave), drawn over its hitboxes.
static func draw_effect(ci: CanvasItem, f: Fighter, base: Transform2D) -> void:
	if f.state != Fighter.State.MOVE or f.move == null or not f.move.is_active_on(f.state_frame):
		return
	var k := f.state_frame - f.move.startup
	ci.draw_set_transform_matrix(base)
	# Drawn from the move itself, so the effect shows whether or not it struck.
	var boxes: Array[Rect2] = []
	for box in f.move.hitboxes:
		boxes.append(f.to_world(box))
	match f.move.id:
		&"frost_breath":
			for box in boxes:
				for i in 6:
					var at := box.position + Vector2(fmod(i * 23.0 + k * 6.0, box.size.x), box.size.y * (0.3 + 0.4 * sin(i * 1.9)))
					ci.draw_circle(at, 8.0 + (i % 3) * 3.0, Color(0.85, 0.95, 1.0, 0.55))
		&"belly_drum":
			for box in boxes:
				var centre := Vector2(box.get_center().x, 0)
				for r in [16.0 + k * 8.0, 32.0 + k * 8.0]:
					ci.draw_arc(centre, r, PI, TAU, 18, Color(0.95, 0.85, 0.6, 0.7), 2.5)


## A talisman: a paper strip, red border, black brush strokes down its middle.
static func _talisman(ci: CanvasItem, at: Vector2, size: float) -> void:
	var w := 10.0 * size
	var h := 20.0 * size
	_cut(ci, PackedVector2Array([at + Vector2(-w, -h), at + Vector2(w, -h), at + Vector2(w, h), at + Vector2(-w, h)]), Color("f4efe3"))
	ci.draw_rect(Rect2(at + Vector2(-w + 2, -h + 2), Vector2(2 * w - 4, 2 * h - 4)), Color("c0392b"), false, 1.5)
	for k in 3:
		var y := -h + 6.0 * size + k * 11.0 * size
		ci.draw_line(at + Vector2(-3 * size, y), at + Vector2(3 * size, y + 5 * size), Color("1d1818"), 2.0 * size)


static func _lantern(ci: CanvasItem) -> void:
	_cut(ci, PackedVector2Array([Vector2(-7, -12), Vector2(7, -12), Vector2(10, -4), Vector2(10, 6), Vector2(7, 13),
			Vector2(-7, 13), Vector2(-10, 6), Vector2(-10, -4)]), Color("f3e3b0"))
	ci.draw_rect(Rect2(-7, -14, 14, 3), Color("1d1818"))
	ci.draw_rect(Rect2(-7, 12, 14, 3), Color("1d1818"))
	ci.draw_circle(Vector2(0, 1), 4.0, Color(1.0, 0.75, 0.3, 0.7))


static func _cut(ci: CanvasItem, shape: PackedVector2Array, c: Color, outline := true) -> void:
	if Geometry2D.triangulate_polygon(shape).is_empty():
		shape = Geometry2D.convex_hull(shape)
	ci.draw_colored_polygon(shape, c)
	if outline:
		var loop := shape.duplicate()
		loop.append(shape[0])
		ci.draw_polyline(loop, INK, 0.9)
