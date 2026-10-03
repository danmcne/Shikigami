class_name Backdrop
extends RefCounted
## The shore at dusk, in the manner of ukiyo-e: a banded sky (the printers'
## bokashi gradation), a low sun, a distant mountain, sea in flat bands with
## curling crests, a vermilion torii standing in the water, and a sand floor.
## Layers scroll at different rates for depth; every layer repeats, so it
## also serves a circular arena.

const SKY := [Color("2b2950"), Color("4a3a68"), Color("7a4a6e"), Color("b5636a"), Color("de8c66"), Color("f0b37a")]
const SEA := [Color("1f3e63"), Color("27507a"), Color("2f6390")]
const FOAM := Color("eef0ec")
const SAND := Color("c8ad84")
const SAND_EDGE := Color("8d7556")
const TORII := Color("c0392b")
const INK := Color(0.08, 0.06, 0.06)
const HORIZON := 430.0
const FLOOR := 640.0
const WIDTH := 1280.0


## Draws in screen space. `camera_x` is the world x at the centre of the view.
static func draw(ci: CanvasItem, camera_x: float) -> void:
	ci.draw_set_transform(Vector2.ZERO)
	# Sky: horizontal bands, darkest at the top.
	var band := HORIZON / SKY.size()
	for k in SKY.size():
		ci.draw_rect(Rect2(0, k * band, WIDTH, band + 1), SKY[k])
	# The sun, low and red, barely moving.
	var sun := Vector2(_wrap(860.0 - camera_x * 0.02, 1400.0), HORIZON - 70)
	ci.draw_circle(sun, 52.0, Color("d9483b"))
	# A distant mountain, snow-capped.
	var mx := _wrap(330.0 - camera_x * 0.08, 1600.0)
	var mountain := PackedVector2Array([Vector2(mx - 260, HORIZON), Vector2(mx - 40, HORIZON - 150),
			Vector2(mx + 30, HORIZON - 150), Vector2(mx + 270, HORIZON)])
	ci.draw_colored_polygon(mountain, Color("5d5878"))
	ci.draw_colored_polygon(PackedVector2Array([Vector2(mx - 40, HORIZON - 150), Vector2(mx + 30, HORIZON - 150),
			Vector2(mx + 62, HORIZON - 118), Vector2(mx + 30, HORIZON - 126), Vector2(mx, HORIZON - 112),
			Vector2(mx - 30, HORIZON - 124), Vector2(mx - 72, HORIZON - 116)]), Color("ece6dc"))
	# Sea: bands from the horizon to the shore, nearer ones scrolling faster.
	var sea_top := HORIZON
	var depth := (FLOOR - 40.0 - HORIZON) / SEA.size()
	for k in SEA.size():
		ci.draw_rect(Rect2(0, sea_top + k * depth, WIDTH, depth + 1), SEA[k])
		_crests(ci, sea_top + k * depth + 6.0, camera_x * (0.15 + 0.15 * k), 70.0 + 30.0 * k, 4.0 + 3.0 * k)
	# The torii in the water.
	_torii(ci, _wrap(980.0 - camera_x * 0.35, 1800.0), FLOOR - 60.0)
	# The sand, with an ink edge where it meets the sea.
	ci.draw_rect(Rect2(0, FLOOR - 40.0, WIDTH, 120.0), SAND)
	ci.draw_line(Vector2(0, FLOOR - 40.0), Vector2(WIDTH, FLOOR - 40.0), SAND_EDGE, 2.0)
	ci.draw_line(Vector2(0, FLOOR), Vector2(WIDTH, FLOOR), Color(SAND_EDGE, 0.7), 2.0)


## Scalloped wave crests along a line: little curls of foam.
static func _crests(ci: CanvasItem, y: float, shift: float, spacing: float, size: float) -> void:
	var x := -fmod(shift, spacing) - spacing
	while x < WIDTH + spacing:
		var curl := PackedVector2Array()
		for k in 7:
			var t := float(k) / 6.0 * PI
			curl.append(Vector2(x + cos(t) * size * 2.2, y - sin(t) * size))
		curl.append(Vector2(x - size * 0.6, y + size * 0.3))
		ci.draw_colored_polygon(curl, FOAM)
		x += spacing


static func _torii(ci: CanvasItem, x: float, base: float) -> void:
	var c := TORII
	ci.draw_rect(Rect2(x - 52, base - 120, 9, 120), c)
	ci.draw_rect(Rect2(x + 43, base - 120, 9, 120), c)
	ci.draw_rect(Rect2(x - 62, base - 100, 124, 7), c)
	ci.draw_colored_polygon(PackedVector2Array([Vector2(x - 78, base - 128), Vector2(x + 78, base - 128),
			Vector2(x + 70, base - 118), Vector2(x - 70, base - 118)]), Color("2a1b18"))
	ci.draw_rect(Rect2(x - 70, base - 118, 140, 6), c)
	# Its reflection, broken by the water.
	for k in 4:
		ci.draw_rect(Rect2(x - 52, base + 6 + k * 7, 9, 3), Color(c, 0.35))
		ci.draw_rect(Rect2(x + 43, base + 6 + k * 7, 9, 3), Color(c, 0.35))


static func _wrap(x: float, period: float) -> float:
	return fposmod(x + period * 0.25, period) - period * 0.25
