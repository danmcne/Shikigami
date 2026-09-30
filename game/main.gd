extends Node2D
## Prototype 1 view. Steps the Bout once per physics tick (60 Hz) and draws
## its state as rectangles. All game rules live in game/combat/.
##
## F1: show boxes and state   F2: cycle player 2 (human / dummy modes)
## F5: restart bout

const PrototypeRect := preload("res://game/fighters/prototype_rect.gd")

const ORIGIN := Vector2(640, 640)
const COLORS: Array[Color] = [Color(0.85, 0.25, 0.2), Color(0.2, 0.45, 0.9)]

var bout: Bout
var p1 := PlayerController.new("p1_")
var p2_human := PlayerController.new("p2_")
var p2_dummy := DummyController.new()
## -1 means a human drives player 2; otherwise a DummyController.Mode.
var p2_dummy_mode := -1
var show_boxes := false


func _ready() -> void:
	InputSetup.register()
	bout = Bout.new(PrototypeRect.definition(), PrototypeRect.definition())


func _physics_process(_delta: float) -> void:
	var a := bout.fighters[0]
	var b := bout.fighters[1]
	var p2: Object = p2_human if p2_dummy_mode < 0 else p2_dummy
	var intents: Array[Intent] = [p1.read(a, b), p2.read(b, a)]
	bout.step(intents)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.physical_keycode:
		KEY_F1:
			show_boxes = not show_boxes
		KEY_F2:
			p2_dummy_mode += 1
			if p2_dummy_mode >= DummyController.Mode.size():
				p2_dummy_mode = -1
			else:
				p2_dummy.mode = p2_dummy_mode as DummyController.Mode
		KEY_F5:
			bout.restart()


func _draw() -> void:
	draw_set_transform(ORIGIN)
	draw_rect(Rect2(Bout.STAGE_LEFT, 0, Bout.STAGE_RIGHT - Bout.STAGE_LEFT, 60), Color(0.18, 0.16, 0.14))
	draw_line(Vector2(Bout.STAGE_LEFT, 0), Vector2(Bout.STAGE_RIGHT, 0), Color(0.5, 0.45, 0.4), 2.0)
	for i in 2:
		_draw_fighter(bout.fighters[i], COLORS[i])
	draw_set_transform(Vector2.ZERO)
	_draw_hud()


func _draw_fighter(f: Fighter, base: Color) -> void:
	var body := f.hurtbox()
	var color := base
	match f.state:
		Fighter.State.HITSTUN:
			color = base.lerp(Color.WHITE, 0.6)
		Fighter.State.BLOCKSTUN:
			color = base.lerp(Color.GRAY, 0.6)
		Fighter.State.KO:
			color = base.darkened(0.6)
	draw_rect(body, color)
	# A notch on the leading edge shows facing.
	var notch_x := body.end.x - 10.0 if f.facing == 1 else body.position.x
	draw_rect(Rect2(notch_x, body.position.y + 12, 10, 10), Color.BLACK)

	# The attacking limb: outline during startup, solid while active,
	# faint during recovery.
	if f.state == Fighter.State.ATTACK:
		var atk := f.attack
		for local in atk.hitboxes:
			var box := f.to_world(local)
			if f.state_frame < atk.startup:
				draw_rect(box, color, false, 2.0)
			elif atk.is_active_on(f.state_frame):
				draw_rect(box, color.lightened(0.3))
			else:
				draw_rect(box, Color(color, 0.35))

	if show_boxes:
		draw_rect(f.hurtbox(), Color.CYAN, false, 1.0)
		draw_rect(f.pushbox(), Color.YELLOW, false, 1.0)
		for box in f.active_hitboxes():
			draw_rect(box, Color.RED, false, 2.0)
		var label := "%s %d" % [Fighter.State.keys()[f.state], f.state_frame]
		draw_string(ThemeDB.fallback_font, body.position + Vector2(-20, -10), label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)


func _draw_hud() -> void:
	var font := ThemeDB.fallback_font
	var width := 1280.0
	for i in 2:
		var f := bout.fighters[i]
		var frac := float(f.health) / f.definition.max_health
		var bar := Rect2(40 if i == 0 else 680, 30, 560, 24)
		draw_rect(bar, Color(0.15, 0.15, 0.15))
		# Bars drain toward the centre of the screen.
		var fill := bar
		fill.size.x *= frac
		if i == 0:
			fill.position.x = bar.end.x - fill.size.x
		draw_rect(fill, COLORS[i])
		draw_rect(bar, Color.WHITE, false, 2.0)
		for w in Bout.ROUNDS_TO_WIN:
			var pip_x := bar.end.x - 20 - w * 26 if i == 0 else bar.position.x + 4 + w * 26
			var won := w < bout.wins[i]
			draw_rect(Rect2(pip_x, 62, 16, 16), Color.GOLD if won else Color(0.3, 0.3, 0.3))

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
		draw_string(font, Vector2(0, 250), message, HORIZONTAL_ALIGNMENT_CENTER, width, 56)

	var p2_label := "human" if p2_dummy_mode < 0 else "dummy: " + p2_dummy.mode_name()
	var help := "P1: WASD + F/G    P2 (%s): arrows + Num1/Num2 or , .    F1 boxes   F2 P2 mode   F5 restart" % p2_label
	draw_string(font, Vector2(0, 700), help, HORIZONTAL_ALIGNMENT_CENTER, width, 16, Color(0.8, 0.8, 0.8))
