extends Node2D
## Prototype view. Steps the Bout once per physics tick (60 Hz) and draws its
## state as rectangles. All game rules live in game/combat/.
##
## F1 boxes   F2 player 2: human / dummy   F3 dummy behaviour
## F5 restart   F6 / F7 change player 1 / player 2 fighter

const Roster := preload("res://game/fighters/roster.gd")

const ORIGIN := Vector2(640, 640)
const COLORS: Array[Color] = [Color(0.85, 0.25, 0.2), Color(0.2, 0.45, 0.9)]
const PREFIXES: Array[String] = ["p1_", "p2_"]
const SMALL := 14

var roster: Array[FighterDefinition] = Roster.all()
var choice: Array[int] = [0, 1]
var bout: Bout
var players: Array[PlayerController] = [PlayerController.new("p1_"), PlayerController.new("p2_")]
var dummy := DummyController.new(DummyController.Mode.FULL_GUARD)
var p2_is_dummy := false
var show_boxes := false


func _ready() -> void:
	InputSetup.register()
	_new_bout()


## Each fighter carries the spirits of the other archetypes.
func _new_bout() -> void:
	var loadouts: Array = []
	for i in 2:
		var mine := roster[choice[i]]
		var bound: Array[FighterDefinition] = []
		bound.assign(roster.filter(func(d: FighterDefinition) -> bool: return d != mine))
		loadouts.append(bound)
	bout = Bout.new(roster[choice[0]], roster[choice[1]], loadouts[0], loadouts[1])


func _physics_process(_delta: float) -> void:
	var a := bout.fighters[0]
	var b := bout.fighters[1]
	var i1: Intent = dummy.read(b, a) if p2_is_dummy else players[1].read(b, a)
	var intents: Array[Intent] = [players[0].read(a, b), i1]
	bout.step(intents)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.physical_keycode:
		KEY_F1:
			show_boxes = not show_boxes
		KEY_F2:
			p2_is_dummy = not p2_is_dummy
		KEY_F3:
			dummy.mode = ((dummy.mode + 1) % DummyController.Mode.size()) as DummyController.Mode
		KEY_F5:
			bout.restart()
		KEY_F6, KEY_F7:
			var i := 0 if event.physical_keycode == KEY_F6 else 1
			choice[i] = (choice[i] + 1) % roster.size()
			_new_bout()


func _draw() -> void:
	draw_set_transform(ORIGIN)
	draw_rect(Rect2(Bout.STAGE_LEFT, 0, Bout.STAGE_RIGHT - Bout.STAGE_LEFT, 60), Color(0.18, 0.16, 0.14))
	draw_line(Vector2(Bout.STAGE_LEFT, 0), Vector2(Bout.STAGE_RIGHT, 0), Color(0.5, 0.45, 0.4), 2.0)
	for i in 2:
		_draw_fighter(bout.fighters[i], COLORS[i])
	for s in bout.spirits:
		_draw_fighter(s, Color(COLORS[s.summoner].lightened(0.5), 0.4))
	for e in bout.entities:
		_draw_entity(e, COLORS[e.owner_index])
	draw_set_transform(Vector2.ZERO)
	_draw_hud()


func _draw_fighter(f: Fighter, base: Color) -> void:
	var color := base
	match f.state:
		Fighter.State.HITSTUN:
			color = base.lerp(Color.WHITE, 0.6)
		Fighter.State.BLOCKSTUN:
			color = base.lerp(Color.GRAY, 0.6)
		Fighter.State.GRABBED:
			color = base.lerp(Color.YELLOW, 0.5)
		Fighter.State.KO:
			color = base.darkened(0.6)
	if f.invulnerable():
		color.a = minf(color.a, 0.45)

	var body := f.hurtbox()
	if f.state == Fighter.State.KNOCKDOWN and not f.airborne:
		body = Rect2(f.position.x - 70, f.position.y - 30, 140, 30)
	draw_rect(body, color)
	var notch_x := body.end.x - 10.0 if f.facing == 1 else body.position.x
	draw_rect(Rect2(notch_x, body.position.y + 12, 10, 10), Color(0, 0, 0, color.a))

	# The moving limb: outline during startup, solid while active, faint in recovery.
	if f.state == Fighter.State.MOVE:
		var m := f.move
		for local in m.hitboxes:
			var box := f.to_world(local)
			if f.state_frame < m.startup:
				draw_rect(box, color, false, 2.0)
			elif m.is_active_on(f.state_frame):
				draw_rect(box, Color(color.lightened(0.3), maxf(color.a, 0.8)))
			else:
				draw_rect(box, Color(color, color.a * 0.35))

	if show_boxes:
		if not f.invulnerable() and f.summoner < 0:
			draw_rect(f.hurtbox(), Color.CYAN, false, 1.0)
		if f.summoner < 0:
			draw_rect(f.pushbox(), Color.YELLOW, false, 1.0)
		for box in f.active_hitboxes():
			draw_rect(box, Color.RED, false, 2.0)
		var label: String = Fighter.State.keys()[f.state]
		if f.move:
			label += " " + f.move.id
		label += " %d" % f.state_frame
		draw_string(ThemeDB.fallback_font, body.position + Vector2(-20, -10), label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, SMALL, Color.WHITE)


func _draw_entity(e: Entity, base: Color) -> void:
	for box in e.active_hitboxes():
		draw_rect(box, base.lightened(0.4))
		draw_rect(box, Color.RED if show_boxes else Color.WHITE, false, 2.0)


func _draw_hud() -> void:
	var font := ThemeDB.fallback_font
	var width := 1280.0
	for i in 2:
		var f := bout.fighters[i]
		var left := i == 0
		var bar := Rect2(40 if left else 680, 30, 560, 24)
		draw_rect(bar, Color(0.15, 0.15, 0.15))
		var fill := bar
		fill.size.x *= float(f.health) / f.definition.max_health
		if left:
			fill.position.x = bar.end.x - fill.size.x
		draw_rect(fill, COLORS[i])
		draw_rect(bar, Color.WHITE, false, 2.0)
		for w in Bout.ROUNDS_TO_WIN:
			var pip_x := bar.end.x - 20 - w * 26 if left else bar.position.x + 4 + w * 26
			draw_rect(Rect2(pip_x, 62, 16, 16), Color.GOLD if w < bout.wins[i] else Color(0.3, 0.3, 0.3))

		var align := HORIZONTAL_ALIGNMENT_LEFT if left else HORIZONTAL_ALIGNMENT_RIGHT
		var who := f.definition.display_name
		if i == 1 and p2_is_dummy:
			who += "  (dummy: %s)" % dummy.mode_name()
		draw_string(font, Vector2(bar.position.x, 76), who, align, bar.size.x, 16)
		_draw_spirit_slots(f, bar, left)
		if i == 0 or not p2_is_dummy:
			var y := 128.0
			for line in _move_list(f, PREFIXES[i]):
				draw_string(font, Vector2(bar.position.x, y), line, align, bar.size.x, SMALL, Color(0.82, 0.82, 0.82))
				y += 18.0

	var message := ""
	match bout.phase:
		Bout.Phase.FIGHT:
			if bout.phase_frame < 60:
				message = "ROUND %d" % bout.round_number
		Bout.Phase.ROUND_OVER:
			message = "DOUBLE K.O." if bout.round_winner < 0 else "K.O."
		Bout.Phase.BOUT_OVER:
			message = "PLAYER %d WINS" % (bout.winner() + 1)
	if message != "":
		draw_string(font, Vector2(0, 380), message, HORIZONTAL_ALIGNMENT_CENTER, width, 56)

	var p2 := "dummy" if p2_is_dummy else "human"
	var help := "F1 boxes   F2 player 2: %s   F3 dummy behaviour   F5 restart   F6 / F7 change fighters" % p2
	draw_string(font, Vector2(0, 710), help, HORIZONTAL_ALIGNMENT_CENTER, width, SMALL, Color(0.7, 0.7, 0.7))


## Two boxes under the name: spirit and keys; the fill drains while on cooldown.
func _draw_spirit_slots(f: Fighter, bar: Rect2, left: bool) -> void:
	for slot in f.spirits.size():
		var w := 180.0
		var x := bar.position.x + slot * (w + 10) if left else bar.end.x - (slot + 1) * (w + 10) + 10
		var r := Rect2(x, 86, w, 18)
		var source := f.spirits[slot]
		var ready := 1.0 - float(f.cooldowns[slot]) / source.spirit_cooldown
		var fill := r
		fill.size.x *= ready
		draw_rect(r, Color(0.15, 0.15, 0.15))
		draw_rect(fill, Color(0.55, 0.5, 0.8) if f.cooldowns[slot] == 0 else Color(0.35, 0.33, 0.45))
		draw_rect(r, Color(0.8, 0.8, 0.8), false, 1.0)
		var label := "%s  %s" % [ControlsText.describe(Fighter.SUMMON_COMMANDS[slot], f.facing, _prefix_of(f)), source.display_name]
		draw_string(ThemeDB.fallback_font, r.position + Vector2(6, 14), label, HORIZONTAL_ALIGNMENT_LEFT, w - 8, 12)


func _prefix_of(f: Fighter) -> String:
	return PREFIXES[bout.fighters.find(f)]


## Every input this fighter has, in this player's keys, for the current facing.
func _move_list(f: Fighter, prefix: String) -> Array[String]:
	var away := ControlsText.direction(4, f.facing, prefix)
	var down_away := ControlsText.direction(1, f.facing, prefix)
	var light := ControlsText.key(prefix, "light")
	var heavy := ControlsText.key(prefix, "heavy")
	var lines: Array[String] = [
		"Guard: hold %s.  Low guard: hold %s." % [away, down_away],
		"%s light, %s heavy.  Crouching: lows.  Jumping: overheads." % [light, heavy],
	]
	var d := f.definition
	for pattern in d.commands:
		var m: MoveDefinition = d.moves[d.commands[pattern]]
		var name := String(m.id).replace("_", " ")
		if m.throw:
			name += " (hold %s: back throw)" % away
		lines.append("%s   %s" % [ControlsText.describe(pattern, f.facing, prefix), name])
	lines.append("Escape a throw: %s+%s as you are grabbed." % [light, heavy])
	return lines
