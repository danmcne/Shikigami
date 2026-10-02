extends Node2D
## Screens and flow. Fights are drawn by BoutView; rules live in game/combat/.
##
##   MENU       1 new run   2 continue run   3 versus   4 calibrate timing
##              5 difficulty   6 game speed   7 invincibility (player 1)
##              8 unlock the yokai without completing a campaign (practice)
##              9 tournament: computer against computer, for balance
##   TOURNAMENT progress, then results; Esc stops it
##
## From the command line, with or without a window:
##   godot --path . -- --tournament [--bouts=N] [--level=N] [--seed=N] [--spirits]
## runs the tournament, prints the results, and (headless) quits.
##   SELECT     A / D or arrows to choose a fighter, Enter or J to confirm
##   RUN        you against the CPU; finish beaten foes you can bind
##   BIND       choose which special the bound spirit performs (1 / 2),
##              then, if both slots are full, what to give up (1 / 2 / 3)
##   RUN_END    result; Enter returns to the menu
##   VERSUS     sandbox: F2 player 2 human/dummy/CPU, F3 dummy behaviour,
##              F5 restart, F6/F7 change fighters
##   CALIBRATE  measure this player's "together" timing
## Anywhere: Esc to the menu, F1 boxes.

const Roster := preload("res://game/fighters/roster.gd")
const Bestiary := preload("res://game/monsters/bestiary.gd")

enum Screen { MENU, SELECT, RUN, BIND, RUN_END, VERSUS, CALIBRATE, TOURNAMENT }
enum Driver { HUMAN, DUMMY, CPU }
const KIND_NAMES := {FighterDefinition.Kind.HUMAN: "human", FighterDefinition.Kind.YOKAI: "yokai",
		FighterDefinition.Kind.MONSTER: "monster"}

var roster: Array[FighterDefinition] = Roster.all()
var selected := 0
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
var tournament: Tournament
## Started from the command line: print the results when done, and quit if
## there is no window.
var tournament_from_command_line := false


func _ready() -> void:
	InputSetup.register()
	var args := OS.get_cmdline_user_args()
	if "--tournament" in args:
		var option := func(name: String, fallback: int) -> int:
			for a in args:
				if a.begins_with("--%s=" % name):
					return int(a.get_slice("=", 1))
			return fallback
		tournament = Tournament.new(roster, option.call("level", 3), option.call("bouts", 2),
				"--spirits" in args, option.call("seed", 1))
		tournament_from_command_line = true
		screen = Screen.TOURNAMENT


func _process(_delta: float) -> void:
	if screen != Screen.TOURNAMENT or tournament.done():
		return
	var headless := DisplayServer.get_name() == "headless"
	if tournament.step(1000 if headless else 12):
		var lines := tournament.report()
		var file := FileAccess.open("user://tournament_report.txt", FileAccess.WRITE)
		file.store_string("\n".join(lines) + "\n")
		file.close()
		if tournament_from_command_line:
			print("\n".join(lines))
			if headless:
				get_tree().quit(0)


func _physics_process(_delta: float) -> void:
	var fighting := screen == Screen.RUN or screen == Screen.VERSUS
	Engine.time_scale = Settings.SPEEDS[Settings.speed()] if fighting else 1.0
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
				1:
					var saved := Run.restore(Settings.saved_run(), roster)
					if saved:
						run = saved
						_start_fight()
				2: _start_versus()
				3:
					calibration = Calibration.new()
					screen = Screen.CALIBRATE
				4:
					Settings.set_option("difficulty", (Settings.difficulty() + 1) % CpuController.LEVELS.size())
				5:
					Settings.set_option("speed", (Settings.speed() + 1) % Settings.SPEEDS.size())
				6:
					Settings.set_option("invincible", not Settings.invincible())
				8:
					tournament = Tournament.new(roster, 3, 2, false, Time.get_ticks_usec() % 100000)
					tournament_from_command_line = false
					screen = Screen.TOURNAMENT
				7:
					Settings.set_option("yokai_unlocked", not Settings.yokai_unlocked())
					selected = 0
					versus_choice = [0, 1]
		Screen.SELECT:
			match key:
				KEY_A, KEY_LEFT, KEY_W, KEY_UP:
					selected = (selected - 1 + _playable().size()) % _playable().size()
				KEY_D, KEY_RIGHT, KEY_S, KEY_DOWN:
					selected = (selected + 1) % _playable().size()
				KEY_ENTER, KEY_KP_ENTER, KEY_J:
					run = Run.new(_playable()[selected], roster, Time.get_ticks_usec())
					_start_fight()
		Screen.BIND:
			if not run.offer.is_empty() and number >= 0 and number <= run.offer.size():
				# The last number releases the offer.
				if not run.choose_offer(number if number < run.offer.size() else -1):
					_next_fight()
			elif run.pending and number >= 0 and number <= Run.SLOTS:
				run.choose_slot(number if number < Run.SLOTS else -1)
				_next_fight()
		Screen.RUN_END:
			if key == KEY_ENTER or key == KEY_KP_ENTER:
				screen = Screen.MENU
		Screen.CALIBRATE:
			if calibration.stage == Calibration.Stage.DONE and (key == KEY_ENTER or key == KEY_KP_ENTER):
				Settings.set_chord_window(calibration.player, calibration.chord_window())
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
					# Player 2 may also be a monster, after the fighters.
					var choices := _playable().size() + (Bestiary.all().size() if i == 1 else 0)
					versus_choice[i] = (versus_choice[i] + 1) % choices
					_start_versus()


# --- flow ------------------------------------------------------------------

## Saves the run before every fight, so quitting mid-fight resumes at its start.
func _start_fight() -> void:
	Settings.save_run(run.to_dict())
	if run.monster:
		bout = _make_monster_bout(run.character, run.spirits, run.monster, run.rng.randi())
	else:
		bout = _make_bout(run.character, run.opponent, run.spirits, run.opponent_spirits)
		bout.offer_finisher = not run.grants_on_victory()
	cpu = _cpu(run.rng.randi())
	screen = Screen.RUN


func _after_fight() -> void:
	if bout.winner() != 0:
		end_text = ["Defeated in fight %d of %d." % [run.fight + 1, Run.length()]]
		_end_run()
		return
	if run.after_victory(bout.bound):
		screen = Screen.BIND
	else:
		_next_fight()


func _next_fight() -> void:
	if run.advance():
		_start_fight()
	else:
		end_text = ["Run complete: %d fights won." % Run.length()]
		if not Settings.yokai_unlocked():
			Settings.set_option("yokai_unlocked", true)
			end_text.append("The yokai are now unlocked, for their own campaign and for versus.")
		_end_run()


func _end_run() -> void:
	var names := run.spirits.map(func(b: SpiritBinding) -> String: return b.label())
	end_text.append("Spirits bound: %s" % (", ".join(names) if not names.is_empty() else "none"))
	Settings.save_run({})
	screen = Screen.RUN_END


func _start_versus() -> void:
	var playable := _playable()
	var defs: Array[FighterDefinition] = [playable[versus_choice[0] % playable.size()]]
	var beast_index := versus_choice[1] - playable.size()
	if beast_index < 0:
		defs.append(playable[versus_choice[1]])
	var loadouts: Array = []
	for d in defs:
		# In versus each fighter carries two spirits it could bind, each with
		# its first special.
		var bound: Array[SpiritBinding] = []
		for o in roster.filter(func(o: FighterDefinition) -> bool: return d.binds(o)).slice(0, Run.SLOTS):
			bound.append(SpiritBinding.new(o, o.specials[0]))
		loadouts.append(bound)
	if beast_index >= 0:
		bout = _make_monster_bout(defs[0], loadouts[0], Bestiary.all()[beast_index], Time.get_ticks_usec())
	else:
		bout = _make_bout(defs[0], defs[1], loadouts[0], loadouts[1])
	cpu = _cpu(Time.get_ticks_usec())
	screen = Screen.VERSUS


func _cpu(seed_value: int) -> CpuController:
	return CpuController.new(CpuController.LEVELS[Settings.difficulty()][1], seed_value)


func _make_bout(a: FighterDefinition, b: FighterDefinition,
		sa: Array[SpiritBinding], sb: Array[SpiritBinding]) -> Bout:
	var made := Bout.new(a, b, sa.duplicate(), sb.duplicate())
	for i in 2:
		made.fighters[i].set_chord_window(Settings.chord_window(i))
	made.fighters[0].invincible = Settings.invincible()
	return made


func _make_monster_bout(a: FighterDefinition, sa: Array[SpiritBinding], beast: MonsterDefinition,
		seed_value: int) -> Bout:
	var made := Bout.versus_monster(a, sa.duplicate(), Monster.new(beast, seed_value))
	made.fighters[0].set_chord_window(Settings.chord_window(0))
	made.fighters[0].invincible = Settings.invincible()
	return made


# --- drawing -----------------------------------------------------------------

func _draw() -> void:
	match screen:
		Screen.MENU:
			BoutView.message(self, "SHIKIGAMI (working title)", 200, 48)
			var saved := Run.restore(Settings.saved_run(), roster)
			var resume := "2   (no run in progress)"
			if saved:
				resume = "2   Continue run: %s, fight %d of %d" % [saved.character.display_name,
						saved.fight + 1, Run.length()]
			var rows: Array[String] = [
				"1   New run: you against the computer, binding the spirits you defeat",
				resume,
				"3   Versus: two players, a training dummy, or the computer",
				"4   Calibrate button timing for your hands and keyboard or pad",
				"",
				"5   Computer difficulty: %s" % CpuController.LEVELS[Settings.difficulty()][0],
				"6   Game speed: %d%%" % roundi(Settings.SPEEDS[Settings.speed()] * 100),
				"7   Player 1 invincible: %s" % ("on" if Settings.invincible() else "off"),
				"8   Yokai: %s" % ("unlocked" if Settings.yokai_unlocked() else "locked until a campaign is completed (8 unlocks them for practice)"),
				"9   Tournament: the Hard computer against itself, every pairing (a few minutes)",
				"",
			]
			for i in 2:
				rows.append("Player %d: presses under %d frames apart count as together%s" % [i + 1,
						Settings.chord_window(i), "" if Settings.calibrated(i) else " (default; calibrate with 4)"])
			rows.append("")
			rows.append("Esc returns here from anywhere.   F1 shows boxes.")
			BoutView.lines(self, Vector2(0, 280), rows, 1280, HORIZONTAL_ALIGNMENT_CENTER, 20)
		Screen.SELECT:
			_draw_select()
		Screen.RUN, Screen.VERSUS:
			_draw_fight()
		Screen.BIND:
			if not run.offer.is_empty():
				var sealed_itself := run.offer[0].source == run.opponent
				BoutView.message(self, ("%s's spirit is sealed" % run.opponent.display_name) if sealed_itself
						else ("%s's spirits are yours to take" % run.opponent.display_name), 220, 40)
				var rows: Array[String] = ["Which will you take?" if not sealed_itself
						else "Which of its specials will the spirit perform?"]
				for k in run.offer.size():
					var b := run.offer[k]
					rows.append("%d   %s: %s" % [k + 1, b.source.display_name, _special_line(b.source, b.move)])
				rows.append("%d   neither: release it" % (run.offer.size() + 1))
				BoutView.lines(self, Vector2(0, 300), rows, 1280, HORIZONTAL_ALIGNMENT_CENTER, 22)
			else:
				BoutView.message(self, "Both slots are full", 220, 40)
				BoutView.lines(self, Vector2(0, 300), [
					"1   replace %s" % run.spirits[0].label(),
					"2   replace %s" % run.spirits[1].label(),
					"3   release %s" % run.pending.label(),
				], 1280, HORIZONTAL_ALIGNMENT_CENTER, 22)
		Screen.RUN_END:
			BoutView.message(self, "Run over", 220, 48)
			BoutView.lines(self, Vector2(0, 300), end_text + ["", "Enter to continue."], 1280,
					HORIZONTAL_ALIGNMENT_CENTER, 22)
		Screen.CALIBRATE:
			_draw_calibration()
		Screen.TOURNAMENT:
			_draw_tournament()


## Humans always; yokai once a campaign has been completed (or unlocked from
## the menu for practice).
func _playable() -> Array[FighterDefinition]:
	var out: Array[FighterDefinition] = []
	out.assign(roster.filter(func(d: FighterDefinition) -> bool:
		return d.kind == FighterDefinition.Kind.HUMAN or Settings.yokai_unlocked()))
	return out


func _draw_select() -> void:
	BoutView.message(self, "Choose your fighter", 70, 36)
	var humans: Array[String] = []
	var yokai: Array[String] = []
	var playable := _playable()
	for d in roster:
		var k := playable.find(d)
		var row := (">  " if k == selected else "    ") + d.display_name + ("" if k >= 0 else "   (locked)")
		(humans if d.kind == FighterDefinition.Kind.HUMAN else yokai).append(row)
	BoutView.lines(self, Vector2(200, 130), ["HUMANS", ""] + humans, 400, HORIZONTAL_ALIGNMENT_LEFT, 20)
	BoutView.lines(self, Vector2(700, 130), ["YOKAI", ""] + yokai, 400, HORIZONTAL_ALIGNMENT_LEFT, 20)
	var d := playable[selected]
	var info: Array[String] = [
		"%s, %s.   Health %d, walking speed %.1f." % [d.display_name, KIND_NAMES[d.kind], d.max_health, d.walk_forward],
		"Special:  %s" % _special_line(d, d.specials[0]),
		"Away + special:  %s" % _special_line(d, d.specials[1]),
		"",
		"A / D to choose, Enter or J to begin.   Humans bind yokai spirits; yokai bind humans.",
	]
	BoutView.lines(self, Vector2(0, 470), info, 1280, HORIZONTAL_ALIGNMENT_CENTER, 18)


## A special's name and what it does, in a few words, from its data.
func _special_line(d: FighterDefinition, id: StringName) -> String:
	var m: MoveDefinition = d.moves[id]
	var traits: Array[String] = []
	if m.counter: traits.append("counter stance")
	if m.throw: traits.append("throw")
	if m.spawn:
		if m.spawn.damage == 0: traits.append("barrier")
		elif m.spawn.motion == Vector2.ZERO: traits.append("trap")
		else: traits.append("projectile")
	if m.teleport_frame >= 0: traits.append("teleport")
	if m.heal > 0: traits.append("heals %d" % m.heal)
	if m.armor > 0: traits.append("armour")
	if m.slows > 0: traits.append("slows")
	if m.motion.y < 0: traits.append("leaps")
	if m.air: traits.append("also in the air")
	var striking := m.spawn if m.spawn else m
	if striking.hitboxes.is_empty() or striking.damage == 0: pass
	elif striking.height == MoveDefinition.Height.HIGH_LOW: traits.append("high and low at once")
	elif striking.height == MoveDefinition.Height.LOW: traits.append("low")
	elif striking.height == MoveDefinition.Height.HIGH: traits.append("overhead")
	if m.hitboxes.any(func(r: Rect2) -> bool: return r.end.x <= 0): traits.append("strikes behind")
	if m.knockback < 0 or (m.spawn and m.spawn.knockback < 0): traits.append("pulls")
	return "%s (%s; recharges in %.1f s)" % [String(id).replace("_", " "), ", ".join(traits) if not traits.is_empty() else "strike", m.cooldown / 60.0]


func _draw_fight() -> void:
	var names: Array[String] = []
	for i in 2:
		var d := bout.fighters[i].definition
		names.append("%s (%s)" % [d.display_name, KIND_NAMES[d.kind]])
	if screen == Screen.RUN:
		var tier: String = ["own kind", "other kind", "monster"][run.tier()]
		names[1] += "  CPU · fight %d of %d (%s)" % [run.fight + 1, Run.length(), tier]
	elif not bout.fighters[1] is Monster:
		names[1] += "  " + ["human", "dummy: " + dummy.mode_name(), "CPU"][versus_driver]
	BoutView.draw(self, bout, names, show_boxes)

	BoutView.lines(self, Vector2(40, 128), BoutView.move_list(bout.fighters[0], "p1_"), 560)
	if screen == Screen.VERSUS and versus_driver == Driver.HUMAN and not bout.fighters[1] is Monster:
		BoutView.lines(self, Vector2(680, 128), BoutView.move_list(bout.fighters[1], "p2_"), 560,
				HORIZONTAL_ALIGNMENT_RIGHT)
	if bout.phase == Bout.Phase.FINISH and bout.round_winner == 0:
		var f := bout.fighters[0]
		var seconds := ceili((Bout.FINISH_FRAMES - bout.phase_frame) / 60.0)
		BoutView.message(self, "SEAL THE SPIRIT:  %s" % ControlsText.describe(Fighter.FINISHER_COMMAND, f.facing, "p1_"), 380, 40)
		BoutView.message(self, "%d" % seconds, 430, 28)
	elif bout.phase == Bout.Phase.FINISH:
		BoutView.message(self, "K.O.")
	if screen == Screen.VERSUS:
		var help := "F2 player 2: human / dummy / CPU   F3 dummy behaviour   F5 restart   F6 / F7 change fighters   Esc menu"
		BoutView.lines(self, Vector2(0, 708), [help], 1280, HORIZONTAL_ALIGNMENT_CENTER, 13, Color(0.7, 0.7, 0.7))


func _draw_tournament() -> void:
	if not tournament.done():
		BoutView.message(self, "Tournament", 220, 40)
		var bar := Rect2(240, 300, 800, 24)
		draw_rect(bar, Color(0.15, 0.15, 0.15))
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * tournament.progress(), bar.size.y)), Color(0.55, 0.5, 0.8))
		draw_rect(bar, Color.WHITE, false, 2.0)
		BoutView.lines(self, Vector2(0, 360), [
			"%d of %d bouts, %s computer on both sides" % [tournament.bouts_done, tournament.total(),
					CpuController.LEVELS[tournament.level][0]],
			"Esc stops it.",
		], 1280, HORIZONTAL_ALIGNMENT_CENTER, 18)
		return
	var lines := tournament.report()
	var split := lines.find("Specials used per bout")
	BoutView.lines(self, Vector2(30, 24), lines.slice(0, split), 620, HORIZONTAL_ALIGNMENT_LEFT, 13)
	BoutView.lines(self, Vector2(650, 24), lines.slice(split) + ["", "Saved to user://tournament_report.txt.  Esc returns to the menu."],
			620, HORIZONTAL_ALIGNMENT_LEFT, 13)


func _draw_calibration() -> void:
	BoutView.message(self, "Calibrate button timing", 120, 40)
	var c := calibration
	var rows: Array[String] = []
	if c.stage == Calibration.Stage.CHOOSE:
		rows = ["Player 1: press %s to begin.    Player 2: press %s to begin." % [
				ControlsText.key("p1_", "light"), ControlsText.key("p2_", "light")]]
	elif c.stage == Calibration.Stage.DONE:
		rows = [
			"Player %d results" % (c.player + 1),
			"Presses meant together landed up to %d frames apart." % c.chord_gaps.max(),
			"Presses meant separately landed at least %d frames apart." % c.sequence_gaps.min(),
			"",
			"Together window: under %d frames (%d ms)." % [c.chord_window(), roundi(c.chord_window() * 1000.0 / 60.0)],
		]
		if c.overlapping():
			rows.append("Some 'together' presses were as far apart as your quick sequences; the window favours together.")
		rows.append("")
		rows.append("Enter to save.   Esc to discard.")
	else:
		var p := "p%d_" % (c.player + 1)
		var k := func(verb: String) -> String: return ControlsText.key(p, verb)
		var prompt := ""
		match c.stage:
			Calibration.Stage.THROW:
				prompt = "Press %s and %s together, as for a throw." % [k.call("light"), k.call("heavy")]
			Calibration.Stage.GUARD:
				prompt = "Press %s and %s together, as for guard." % [k.call("light"), k.call("special")]
			Calibration.Stage.SPIRIT_GUARD:
				prompt = "Press %s, %s and %s together, as for spirit guard." % [k.call("light"),
						k.call("spirit"), k.call("special")]
			Calibration.Stage.TOWARD_SPECIAL:
				prompt = "Press %s and %s together, as for the rush." % [ControlsText.direction(6, 1, p), k.call("special")]
			Calibration.Stage.DOWN_SPIRIT:
				prompt = "Press %s and %s together, as for the second spirit." % [ControlsText.direction(2, 1, p), k.call("spirit")]
			Calibration.Stage.SEQUENCE:
				prompt = "Press %s, then %s: two separate presses, as quickly as you can." % [k.call("light"), k.call("heavy")]
		rows = [
			"Player %d, step %d of %d" % [c.player + 1, c.stage, Calibration.STEPS],
			"",
			prompt,
			"",
			"%d of %d" % [c.count, Calibration.REPS],
			"",
			"Release everything between tries.",
		]
	BoutView.lines(self, Vector2(0, 230), rows, 1280, HORIZONTAL_ALIGNMENT_CENTER, 22)
