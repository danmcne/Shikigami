extends Node2D
## Screens and flow. Fights are drawn by BoutView; rules live in game/combat/.
##
##   MENU       1 run   2 versus   3 calibrate button timing
##   SELECT     1-3 pick a fighter for the run
##   RUN        you against the CPU; finish beaten foes you can bind
##   BIND       both slots full: choose what to give up
##   RUN_END    result; Enter returns to the menu
##   VERSUS     sandbox: F2 player 2 human/dummy/CPU, F3 dummy behaviour,
##              F5 restart, F6/F7 change fighters
##   CALIBRATE  measure this player's "together" timing
## Anywhere: Esc to the menu, F1 boxes.

const Roster := preload("res://game/fighters/roster.gd")

enum Screen { MENU, SELECT, RUN, BIND, RUN_END, VERSUS, CALIBRATE }
enum Driver { HUMAN, DUMMY, CPU }
const KIND_NAMES := {FighterDefinition.Kind.HUMAN: "human", FighterDefinition.Kind.YOKAI: "yokai"}

var roster: Array[FighterDefinition] = Roster.all()
var screen := Screen.MENU
var show_boxes := false
var players: Array[PlayerController] = [PlayerController.new("p1_"), PlayerController.new("p2_")]

var bout: Bout
var run: Run
var cpu: CpuController
var end_text: Array[String] = []

var versus_choice: Array[int] = [0, 1]
var versus_driver := Driver.HUMAN
var dummy := DummyController.new(DummyController.Mode.FULL_GUARD)

var calibration: Calibration


func _ready() -> void:
	InputSetup.register()


func _physics_process(_delta: float) -> void:
	match screen:
		Screen.RUN:
			var a := bout.fighters[0]
			var b := bout.fighters[1]
			var intents: Array[Intent] = [players[0].read(a, b), cpu.read(b, a)]
			bout.step(intents)
			if bout.is_over():
				_after_fight()
		Screen.VERSUS:
			var a := bout.fighters[0]
			var b := bout.fighters[1]
			var second: Intent
			match versus_driver:
				Driver.HUMAN: second = players[1].read(b, a)
				Driver.DUMMY: second = dummy.read(b, a)
				Driver.CPU: second = cpu.read(b, a)
			var intents: Array[Intent] = [players[0].read(a, b), second]
			bout.step(intents)
			if bout.is_over():
				bout.restart()
		Screen.CALIBRATE:
			var intents: Array[Intent] = [players[0].read(null, null), players[1].read(null, null)]
			calibration.observe(intents)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	var key: int = event.physical_keycode
	if key == KEY_ESCAPE:
		screen = Screen.MENU
		return
	if key == KEY_F1:
		show_boxes = not show_boxes
		return
	var number := key - KEY_1 if key >= KEY_1 and key <= KEY_9 else -1
	match screen:
		Screen.MENU:
			match number:
				0: screen = Screen.SELECT
				1: _start_versus()
				2:
					calibration = Calibration.new()
					screen = Screen.CALIBRATE
		Screen.SELECT:
			if number >= 0 and number < roster.size():
				run = Run.new(roster[number], roster, Time.get_ticks_usec())
				_start_fight()
		Screen.BIND:
			if number >= 0 and number <= Run.SLOTS:
				run.choose(number if number < Run.SLOTS else -1)
				_next_fight()
		Screen.RUN_END:
			if key == KEY_ENTER or key == KEY_KP_ENTER:
				screen = Screen.MENU
		Screen.CALIBRATE:
			if calibration.stage() == Calibration.Stage.DONE and (key == KEY_ENTER or key == KEY_KP_ENTER):
				Settings.set_chord_window(calibration.player, calibration.window())
				screen = Screen.MENU
		Screen.VERSUS:
			match key:
				KEY_F2:
					versus_driver = ((versus_driver + 1) % Driver.size()) as Driver
				KEY_F3:
					dummy.mode = ((dummy.mode + 1) % DummyController.Mode.size()) as DummyController.Mode
				KEY_F5:
					bout.restart()
				KEY_F6, KEY_F7:
					var i := 0 if key == KEY_F6 else 1
					versus_choice[i] = (versus_choice[i] + 1) % roster.size()
					_start_versus()


# --- flow ------------------------------------------------------------------

func _start_fight() -> void:
	bout = _make_bout(run.character, run.opponent, run.spirits, run.opponent_spirits)
	cpu = CpuController.new(CpuController.EASY, run.rng.randi())
	screen = Screen.RUN


func _after_fight() -> void:
	if bout.winner() != 0:
		end_text = ["Defeated in fight %d of %d." % [run.fight + 1, Run.LENGTH]]
		screen = Screen.RUN_END
		return
	var bound := run.opponent if bout.bound else null
	if run.win(bound):
		screen = Screen.BIND
	else:
		_next_fight()


func _next_fight() -> void:
	if run.advance():
		_start_fight()
	else:
		end_text = ["Run complete: %d fights won." % Run.LENGTH]
		screen = Screen.RUN_END
	if screen == Screen.RUN_END:
		var names := run.spirits.map(func(d: FighterDefinition) -> String: return d.display_name)
		end_text.append("Spirits bound: %s" % (", ".join(names) if not names.is_empty() else "none"))


func _start_versus() -> void:
	var defs := versus_choice.map(func(c: int) -> FighterDefinition: return roster[c])
	var loadouts: Array = []
	for d in defs:
		var bound: Array[FighterDefinition] = []
		bound.assign(roster.filter(func(o: FighterDefinition) -> bool: return d.binds(o)).slice(0, Run.SLOTS))
		loadouts.append(bound)
	bout = _make_bout(defs[0], defs[1], loadouts[0], loadouts[1])
	cpu = CpuController.new(CpuController.EASY, Time.get_ticks_usec())
	screen = Screen.VERSUS


func _make_bout(a: FighterDefinition, b: FighterDefinition,
		sa: Array[FighterDefinition], sb: Array[FighterDefinition]) -> Bout:
	var made := Bout.new(a, b, sa.duplicate(), sb.duplicate())
	for i in 2:
		made.fighters[i].set_chord_window(Settings.chord_window(i))
	return made


# --- drawing -----------------------------------------------------------------

func _draw() -> void:
	match screen:
		Screen.MENU:
			BoutView.message(self, "SHIKIGAMI (working title)", 200, 48)
			BoutView.lines(self, Vector2(0, 300), [
				"1   Run: you against the computer, binding the spirits you defeat",
				"2   Versus: two players, a training dummy, or the computer",
				"3   Calibrate button timing for your keyboard or pad",
				"",
				"Esc returns here from anywhere.   F1 shows boxes.",
			], 1280, HORIZONTAL_ALIGNMENT_CENTER, 20)
		Screen.SELECT:
			BoutView.message(self, "Choose your fighter", 160, 40)
			var rows: Array[String] = []
			for k in roster.size():
				var d := roster[k]
				rows.append("%d   %s  (%s)   health %d   walk %.1f   finisher %s" % [k + 1, d.display_name,
						KIND_NAMES[d.kind], d.max_health, d.walk_forward,
						ControlsText.describe(d.finisher_command, 1, "p1_")])
			rows.append("")
			rows.append("Humans bind yokai spirits; yokai bind human spirits. You start with none.")
			BoutView.lines(self, Vector2(0, 260), rows, 1280, HORIZONTAL_ALIGNMENT_CENTER, 20)
		Screen.RUN, Screen.VERSUS:
			_draw_fight()
		Screen.BIND:
			BoutView.message(self, "%s's spirit is bound" % run.pending.display_name, 220, 40)
			BoutView.lines(self, Vector2(0, 300), [
				"Both slots are full. Choose:",
				"1   replace %s" % run.spirits[0].display_name,
				"2   replace %s" % run.spirits[1].display_name,
				"3   release %s" % run.pending.display_name,
			], 1280, HORIZONTAL_ALIGNMENT_CENTER, 22)
		Screen.RUN_END:
			BoutView.message(self, "Run over", 220, 48)
			BoutView.lines(self, Vector2(0, 300), end_text + ["", "Enter to continue."], 1280,
					HORIZONTAL_ALIGNMENT_CENTER, 22)
		Screen.CALIBRATE:
			_draw_calibration()


func _draw_fight() -> void:
	var names: Array[String] = []
	for i in 2:
		var d := bout.fighters[i].definition
		names.append("%s (%s)" % [d.display_name, KIND_NAMES[d.kind]])
	if screen == Screen.RUN:
		names[1] += "  CPU · fight %d of %d" % [run.fight + 1, Run.LENGTH]
	else:
		names[1] += "  " + ["human", "dummy: " + dummy.mode_name(), "CPU"][versus_driver]
	BoutView.draw(self, bout, names, show_boxes)

	BoutView.lines(self, Vector2(40, 128), BoutView.move_list(bout.fighters[0], "p1_"), 560)
	if screen == Screen.VERSUS and versus_driver == Driver.HUMAN:
		BoutView.lines(self, Vector2(680, 128), BoutView.move_list(bout.fighters[1], "p2_"), 560,
				HORIZONTAL_ALIGNMENT_RIGHT)
	if bout.phase == Bout.Phase.FINISH and bout.round_winner == 0:
		var f := bout.fighters[0]
		var seconds := ceili((Bout.FINISH_FRAMES - bout.phase_frame) / 60.0)
		BoutView.message(self, "SEAL THE SPIRIT:  %s" % ControlsText.describe(f.definition.finisher_command, f.facing, "p1_"), 380, 40)
		BoutView.message(self, "%d" % seconds, 430, 28)
	elif bout.phase == Bout.Phase.FINISH:
		BoutView.message(self, "K.O.")
	if screen == Screen.VERSUS:
		var help := "F2 player 2: human / dummy / CPU   F3 dummy behaviour   F5 restart   F6 / F7 change fighters   Esc menu"
		BoutView.lines(self, Vector2(0, 708), [help], 1280, HORIZONTAL_ALIGNMENT_CENTER, 13, Color(0.7, 0.7, 0.7))


func _draw_calibration() -> void:
	BoutView.message(self, "Calibrate button timing", 140, 40)
	var who := "either player" if calibration.player < 0 else "player %d" % (calibration.player + 1)
	var rows: Array[String] = []
	match calibration.stage():
		Calibration.Stage.TOGETHER:
			rows = ["Press LIGHT and HEAVY at the same time, as you would for a throw.",
					"(Player 1: J and I.   Player 2: Num 4 and Num 8.)",
					"%d of %d  (%s)" % [calibration.together.size(), Calibration.TRIALS, who]]
		Calibration.Stage.SEQUENCE:
			rows = ["Now press LIGHT, then HEAVY, one after the other, as quickly as you can",
					"while still meaning them as two separate presses.",
					"%d of %d  (%s)" % [calibration.sequence.size(), Calibration.TRIALS, who]]
		Calibration.Stage.DONE:
			var w := calibration.window()
			rows = ["Together: presses landed up to %d frames apart." % calibration.together.max(),
					"Quick sequence: presses landed at least %d frames apart." % calibration.sequence.min(),
					"Window for player %d: presses under %d frames apart (%d ms) count as together."
							% [calibration.player + 1, w, roundi(w * 1000.0 / 60.0)]]
			if calibration.overlapping():
				rows.append("Your together and sequence timings overlap; the window favours together.")
			rows.append("")
			rows.append("Enter to save.   Esc to discard.")
	BoutView.lines(self, Vector2(0, 260), rows, 1280, HORIZONTAL_ALIGNMENT_CENTER, 20)
