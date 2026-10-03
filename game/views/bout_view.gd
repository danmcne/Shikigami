class_name BoutView
extends RefCounted
## Draws a Bout as rectangles onto any CanvasItem: stage, fighters, spirits,
## projectiles, health, spirit slots and round messages. Reads the bout; never
## changes it.

const ORIGIN := Vector2(640, 640)
const COLORS: Array[Color] = [Color(0.85, 0.25, 0.2), Color(0.2, 0.45, 0.9)]
const SMALL := 14
const GREY := Color(0.82, 0.82, 0.82)


## `colourways`: 0 (tori) or 1 (uke) for each fighter's puppet.
static func draw(ci: CanvasItem, bout: Bout, names: Array[String], show_boxes: bool,
		colourways: Array = [0, 1]) -> void:
	var camera_x := bout.fighters[0].position.x if bout.arena_length > 0.0 else 0.0
	Backdrop.draw(ci, camera_x)
	var base := Transform2D(0.0, Vector2(ORIGIN.x - camera_x, ORIGIN.y))
	if bout.arena_length > 0.0:
		# A circular arena: the view follows the first fighter, the floor runs
		# on, and pillars mark the way round.
		var cx := bout.fighters[0].position.x
		ci.draw_set_transform(Vector2(ORIGIN.x - cx, ORIGIN.y))
		var spacing := bout.arena_length / 8.0
		var first := floorf((cx - 700) / spacing) * spacing
		var x := first
		while x < cx + 700:
			ci.draw_rect(Rect2(x - 12, -420, 24, 420), Color(0.3, 0.27, 0.32, 0.6))
			x += spacing
	else:
		ci.draw_set_transform(ORIGIN)
	for i in 2:
		var f := bout.fighters[i]
		if f is Monster:
			_monster(ci, f, show_boxes)
		elif Puppet.has_puppet(f):
			Puppet.draw(ci, f, base, colourways[i])
			_labels(ci, f, show_boxes)
		else:
			_fighter(ci, f, COLORS[i], show_boxes)
	for s in bout.spirits:
		if Puppet.has_puppet(s):
			Puppet.draw(ci, s, base, colourways[s.summoner], 0.45)
		else:
			_fighter(ci, s, Color(COLORS[s.summoner].lightened(0.5), 0.4), show_boxes)
	for e in bout.entities:
		# A tethered piece is joined to its performer: a neck from the shoulders.
		if e.move.tethered:
			var owner: Fighter = bout.fighters[e.owner_index]
			var top := owner.hurtbox()
			var neck := Vector2(top.get_center().x + owner.facing * top.size.x * 0.2, top.position.y + 12)
			ci.draw_line(neck, e.position, COLORS[e.owner_index].lightened(0.2), 6.0)
		# Before it strikes, a piece with a start-up shows where it will.
		if e.frame < e.move.startup:
			for local in e.move.hitboxes:
				var box := MoveDefinition.place(local, e.position, e.facing)
				var urgency := float(e.frame) / maxf(e.move.startup, 1.0)
				ci.draw_rect(box, Color(1.0, 0.2, 0.2, 0.08 + 0.2 * urgency))
				ci.draw_rect(Rect2(box.position.x, -4, box.size.x, 4), Color(1.0, 0.3, 0.2, 0.8))
		# Something falling casts a shadow where it will land.
		if e.move.motion.y > 0.0 and e.position.y < -20.0:
			for box in e.active_hitboxes():
				ci.draw_rect(Rect2(box.position.x, -6, box.size.x, 6), Color(0, 0, 0, 0.45))
		# A returning piece is still drawn on its way back, though it can't strike.
		var drawn := e.boxes() if e.returning else e.active_hitboxes()
		for box in drawn:
			ci.draw_rect(box, COLORS[e.owner_index].lightened(0.4))
			ci.draw_rect(box, Color.RED if show_boxes and not e.returning else Color.WHITE, false, 2.0)
	ci.draw_set_transform(Vector2.ZERO)
	_hud(ci, bout, names)


static func message(ci: CanvasItem, text: String, y := 380.0, size := 56) -> void:
	ci.draw_string(ThemeDB.fallback_font, Vector2(0, y), text, HORIZONTAL_ALIGNMENT_CENTER, 1280, size)


static func lines(ci: CanvasItem, at: Vector2, rows: Array, width: float,
		align := HORIZONTAL_ALIGNMENT_LEFT, size := SMALL, color := GREY) -> void:
	var y := at.y
	for row in rows:
		ci.draw_string(ThemeDB.fallback_font, Vector2(at.x, y), row, align, width, size, color)
		y += size + 4


## A monster: each part drawn by its state (shell, legs, a weak point open or
## closed, broken parts greyed), its attacks' start-up shown in red as a
## warning of where they will land.
static func _monster(ci: CanvasItem, m: Monster, show_boxes: bool) -> void:
	var font := ThemeDB.fallback_font
	var tint := Color(1, 1, 1, 1)
	if m.state == Fighter.State.HITSTUN:
		tint = Color(1.4, 1.4, 1.4)
	elif m.state == Fighter.State.KO:
		tint = Color(0.4, 0.4, 0.4)
	if m.position.y < -20.0:
		# Something flying casts a shadow on the floor beneath it.
		var under := m.to_world(m.definition.pushbox)
		ci.draw_rect(Rect2(under.position.x + 20, -6, under.size.x - 40, 6), Color(0, 0, 0, 0.4))
	for shape in m.monster.backdrop:
		ci.draw_rect(m.to_world(shape), Color(0.85, 0.82, 0.7, 0.12) * tint)
	for k in m.monster.parts.size():
		var part: MonsterDefinition.Part = m.monster.parts[k]
		var box := m.to_world(part.box)
		var color := m.monster.colour.darkened(0.2)
		if part.health > 0:
			color = Color(0.35, 0.35, 0.35) if m.part_health[k] <= 0 else m.monster.colour
		if part.hidden:
			if not m.exposed(k):
				var resting := Rect2(box.position + part.rest_offset, box.size)
				ci.draw_rect(resting, Color(0.6, 0.5, 0.2, 0.5), false, 2.0)
				continue
			color = Color(1.0, 0.85, 0.3)
		ci.draw_rect(box, color * tint)
		ci.draw_rect(box, Color(0, 0, 0, 0.6), false, 1.0)
		if part.health > 0 and m.part_health[k] > 0:
			var frac := float(m.part_health[k]) / part.health
			ci.draw_rect(Rect2(box.position.x, box.end.y + 4, box.size.x * frac, 4), Color(0.9, 0.6, 0.2))
	if m.state == Fighter.State.MOVE:
		var mv := m.move
		var warning := _converge_warning(mv, m)
		if warning.has_area() and m.state_frame < mv.startup:
			var urgency := float(m.state_frame) / maxf(mv.startup, 1.0)
			ci.draw_rect(warning, Color(1.0, 0.1, 0.1, 0.1 + 0.2 * urgency))
			ci.draw_rect(warning, Color(1.0, 0.2, 0.2, 0.7), false, 2.0)
		for local in mv.hitboxes:
			var box := m.to_world(local)
			if m.state_frame < mv.startup:
				var urgency := float(m.state_frame) / maxf(mv.startup, 1.0)
				ci.draw_rect(box, Color(1.0, 0.1, 0.1, 0.12 + 0.25 * urgency))
				ci.draw_rect(box, Color(1.0, 0.2, 0.2, 0.8), false, 2.0)
			elif mv.is_active_on(m.state_frame):
				ci.draw_rect(box, Color(1.0, 0.3, 0.1, 0.85))
	if m.state == Fighter.State.DAZED and m.monster.core.has_area():
		var core := m.to_world(m.monster.core)
		var pulse := 0.5 + 0.4 * sin(m.state_frame * 0.2)
		ci.draw_rect(core, Color(0.7, 0.9, 1.0, 0.35 + 0.3 * pulse))
		ci.draw_rect(core, Color(0.8, 1.0, 1.0, 0.9), false, 3.0)
	var top := m.to_world(m.definition.stand_hurtbox)
	ci.draw_string(font, Vector2(top.position.x, top.position.y - 26), m.definition.display_name,
			HORIZONTAL_ALIGNMENT_CENTER, top.size.x, 16, Color(1, 1, 1, 0.8))
	if m.notice_frames > 0:
		ci.draw_string(font, Vector2(top.position.x, top.position.y - 48), m.notice,
				HORIZONTAL_ALIGNMENT_CENTER, top.size.x, 20, Color(1.0, 0.95, 0.5))
	if show_boxes:
		for box in m.hurtboxes():
			ci.draw_rect(box, Color.CYAN, false, 1.0)
		if m.pushbox().has_area():
			ci.draw_rect(m.pushbox(), Color.YELLOW, false, 1.0)
		for box in m.active_hitboxes():
			ci.draw_rect(box, Color.RED, false, 2.0)


## Where a monster's converging pieces will sweep: the band they occupy, from
## where they start to its centreline.
static func _converge_warning(mv: MoveDefinition, m: Monster) -> Rect2:
	if mv.spawn == null or not mv.spawn.converges or mv.spawn.hitboxes.is_empty():
		return Rect2()
	var offsets: Array[Vector2] = mv.spawn_offsets if not mv.spawn_offsets.is_empty() else [mv.spawn_offset]
	var left := m.position.x
	var right := m.position.x
	for o in offsets:
		left = minf(left, m.position.x + m.facing * o.x)
		right = maxf(right, m.position.x + m.facing * o.x)
	var top := INF
	var bottom := -INF
	for box in mv.spawn.hitboxes:
		top = minf(top, box.position.y)
		bottom = maxf(bottom, box.end.y)
	return Rect2(left, top, right - left, bottom - top)


## For a puppet: its name and notices overhead, and its boxes if asked for.
static func _labels(ci: CanvasItem, f: Fighter, show_boxes: bool) -> void:
	var body := f.hurtbox()
	ci.draw_string(ThemeDB.fallback_font, Vector2(body.position.x - 60, body.position.y - 40),
			f.definition.display_name, HORIZONTAL_ALIGNMENT_CENTER, body.size.x + 120, 13, Color(1, 1, 1, 0.8))
	if f.notice_frames > 0:
		ci.draw_string(ThemeDB.fallback_font, Vector2(body.position.x - 60, body.position.y - 58),
				f.notice, HORIZONTAL_ALIGNMENT_CENTER, body.size.x + 120, 18, Color(1.0, 0.95, 0.5))
	if show_boxes:
		ci.draw_rect(body, Color.CYAN, false, 1.0)
		ci.draw_rect(f.pushbox(), Color.YELLOW, false, 1.0)
		for box in f.active_hitboxes():
			ci.draw_rect(box, Color.RED, false, 2.0)


static func _fighter(ci: CanvasItem, f: Fighter, base: Color, show_boxes: bool) -> void:
	var color := base
	match f.state:
		Fighter.State.HITSTUN:
			color = base.lerp(Color.WHITE, 0.6)
		Fighter.State.BLOCKSTUN:
			color = base.lerp(Color.GRAY, 0.6)
		Fighter.State.GRABBED:
			color = base.lerp(Color.YELLOW, 0.5)
		Fighter.State.DAZED:
			color = base.lerp(Color.WHITE, 0.3 + 0.3 * sin(f.state_frame * 0.25))
		Fighter.State.SEALED:
			color = Color(base.lerp(Color.WHITE, 0.7), 0.5)
		Fighter.State.KO:
			color = base.darkened(0.6)
	if f.slow_frames > 0:
		color = color.lerp(Color(0.6, 0.85, 1.0, color.a), 0.5)
	if f.invulnerable() and f.state != Fighter.State.DAZED:
		color.a = minf(color.a, 0.45)

	var body := f.hurtbox()
	var lying := f.state in [Fighter.State.KNOCKDOWN, Fighter.State.SEALED] and not f.airborne
	if lying:
		body = Rect2(f.position.x - 70, f.position.y - 30, 140, 30)
	ci.draw_rect(body, color)
	if f.armor_frames > 0:
		ci.draw_rect(body.grow(3), Color(1.0, 0.8, 0.2, 0.9), false, 3.0)
	if f.glow_frames > 0:
		ci.draw_rect(body.grow(5), Color(0.4, 1.0, 0.5, f.glow_frames / float(Fighter.GLOW_FRAMES)), false, 4.0)
	if f.summoner < 0:
		ci.draw_string(ThemeDB.fallback_font, Vector2(body.position.x - 60, body.position.y - 26),
				f.definition.display_name, HORIZONTAL_ALIGNMENT_CENTER, body.size.x + 120, 13, Color(1, 1, 1, 0.75))
	if f.notice_frames > 0:
		ci.draw_string(ThemeDB.fallback_font, Vector2(body.position.x - 60, body.position.y - 44),
				f.notice, HORIZONTAL_ALIGNMENT_CENTER, body.size.x + 120, 18, Color(1.0, 0.95, 0.5))
	var notch_x := body.end.x - 10.0 if f.facing == 1 else body.position.x
	ci.draw_rect(Rect2(notch_x, body.position.y + 12, 10, 10), Color(0, 0, 0, color.a))
	if f.state == Fighter.State.GUARD or (f.state == Fighter.State.BLOCKSTUN and not lying):
		# A guard bar across the front edge.
		var gx := body.end.x + 2 if f.facing == 1 else body.position.x - 8
		ci.draw_rect(Rect2(gx, body.position.y, 6, body.size.y), Color(0.95, 0.95, 0.7, 0.9))

	if f.state == Fighter.State.MOVE:
		var m := f.move
		for local in m.hitboxes:
			var box := f.to_world(local)
			if f.state_frame < m.startup:
				ci.draw_rect(box, color, false, 2.0)
			elif m.is_active_on(f.state_frame):
				ci.draw_rect(box, Color(color.lightened(0.3), maxf(color.a, 0.8)))
			else:
				ci.draw_rect(box, Color(color, color.a * 0.35))

	if show_boxes:
		if not f.invulnerable() and f.summoner < 0:
			ci.draw_rect(f.hurtbox(), Color.CYAN, false, 1.0)
		if f.summoner < 0:
			ci.draw_rect(f.pushbox(), Color.YELLOW, false, 1.0)
		for box in f.active_hitboxes():
			ci.draw_rect(box, Color.RED, false, 2.0)
		var label: String = Fighter.State.keys()[f.state]
		if f.move:
			label += " " + f.move.id
		label += " %d" % f.state_frame
		ci.draw_string(ThemeDB.fallback_font, body.position + Vector2(-20, -10), label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, SMALL, Color.WHITE)


static func _hud(ci: CanvasItem, bout: Bout, names: Array[String]) -> void:
	var font := ThemeDB.fallback_font
	for i in 2:
		var f := bout.fighters[i]
		var left := i == 0
		var bar := Rect2(40 if left else 680, 30, 560, 24)
		ci.draw_rect(bar, Color(0.15, 0.15, 0.15))
		var fill := bar
		fill.size.x *= float(f.health) / f.definition.max_health
		if left:
			fill.position.x = bar.end.x - fill.size.x
		ci.draw_rect(fill, COLORS[i])
		ci.draw_rect(bar, Color.WHITE, false, 2.0)
		for w in bout.rounds_to_win:
			var pip_x := bar.end.x - 20 - w * 26 if left else bar.position.x + 4 + w * 26
			ci.draw_rect(Rect2(pip_x, 62, 16, 16), Color.GOLD if w < bout.wins[i] else Color(0.3, 0.3, 0.3))
		var align := HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT
		ci.draw_string(font, Vector2(bar.position.x, 76), names[i], align, bar.size.x, 16)
		# Hits landed on the other fighter in the current combo, on the attacker's side.
		var chain := bout.combo[1 - i]
		if chain >= 2:
			ci.draw_string(font, Vector2(bar.position.x, 300), "%d HITS" % chain, align, bar.size.x, 30,
					Color(1.0, 0.85, 0.3))
		_slots(ci, f, i, bar, left)

	match bout.phase:
		Bout.Phase.FIGHT:
			if bout.phase_frame < 60:
				message(ci, "ROUND %d" % bout.round_number)
		Bout.Phase.ROUND_OVER:
			message(ci, "DOUBLE K.O." if bout.round_winner < 0 else "K.O.")
		Bout.Phase.BOUT_OVER:
			if bout.bound:
				message(ci, "SPIRIT BOUND")
			else:
				message(ci, "PLAYER %d WINS" % (bout.winner() + 1))


## Recharging abilities under the name: the two specials, then each spirit
## slot. The fill drains on use and refills as it recharges.
static func _slots(ci: CanvasItem, f: Fighter, index: int, bar: Rect2, left: bool) -> void:
	var prefix := "p%d_" % (index + 1)
	var slots: Array = []  # [label, remaining, full]
	var d := f.definition
	var patterns := ["C", "4C"]
	for k in d.specials.size():
		var m: MoveDefinition = d.moves[d.specials[k]]
		slots.append([ControlsText.describe(patterns[k], f.facing, prefix) + "  " + _name(m.id),
				f.move_cooldowns.get(m.id, 0), maxi(m.cooldown, 1)])
	for slot in f.spirits.size():
		var binding := f.spirits[slot]
		slots.append([ControlsText.describe(Fighter.SUMMON_COMMANDS[slot], f.facing, prefix)
				+ "  " + binding.label(), f.cooldowns[slot], binding.source.spirit_cooldown])
	var w := 130.0
	for k in slots.size():
		var x := bar.position.x + k * (w + 10) if left else bar.end.x - (k + 1) * (w + 10) + 10
		var r := Rect2(x, 86, w, 18)
		var fill := r
		fill.size.x *= 1.0 - float(slots[k][1]) / slots[k][2]
		ci.draw_rect(r, Color(0.15, 0.15, 0.15))
		ci.draw_rect(fill, Color(0.55, 0.5, 0.8) if slots[k][1] == 0 else Color(0.35, 0.33, 0.45))
		ci.draw_rect(r, Color(0.8, 0.8, 0.8), false, 1.0)
		ci.draw_string(ThemeDB.fallback_font, r.position + Vector2(6, 14), slots[k][0],
				HORIZONTAL_ALIGNMENT_LEFT, w - 8, 12)


static func _name(id: StringName) -> String:
	return String(id).replace("_", " ")


## Every input this fighter has, in this player's keys, for the current facing.
static func move_list(f: Fighter, prefix: String) -> Array[String]:
	var away := ControlsText.direction(4, f.facing, prefix)
	var down := ControlsText.direction(2, f.facing, prefix)
	var light := ControlsText.key(prefix, "light")
	var heavy := ControlsText.key(prefix, "heavy")
	var special := ControlsText.key(prefix, "special")
	var spirit := ControlsText.key(prefix, "spirit")
	var rows: Array[String] = [
		"Guard: hold %s+%s (with %s: low). Against spirits instead: hold %s+%s+%s." % [
				light, special, down, light, spirit, special],
		"%s light, %s heavy. Crouching: lows. Jumping: overheads." % [light, heavy],
	]
	var d := f.definition
	for pattern in d.commands:
		var m: MoveDefinition = d.moves[d.commands[pattern]]
		var name := _name(m.id)
		if m.id in d.specials:
			name += " (recharges)"
		if m.throw:
			name += " (hold %s to throw backward)" % away
		rows.append("%s   %s" % [ControlsText.describe(pattern, f.facing, prefix), name])
	rows.append("Escape a throw: %s+%s as you are grabbed." % [light, heavy])
	if d.finisher_move:
		rows.append("Finisher (beaten foe you can bind, or a beaten giant): %s" % ControlsText.describe(Fighter.FINISHER_COMMAND, f.facing, prefix))
	if f.free_facing:
		rows.append("Free facing: tap %s twice to turn round; hold it to turn and run. Guard covers only the side you face." % away)
	return rows
