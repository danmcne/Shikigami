extends SceneTree
## Mechanics self-test. Not part of the game; run it explicitly:
##   godot --headless --path . --script res://tests/selftest.gd
## It checks that rules behave as specified. It says nothing about whether
## the game feels good.

const PrototypeRect := preload("res://game/fighters/prototype_rect.gd")
const Roster := preload("res://game/fighters/roster.gd")

var failures := 0
var def := PrototypeRect.definition()


func _init() -> void:
	print("rules")
	_test_light_hits_standing()
	_test_light_whiffs_over_crouch()
	_test_standing_guard_stops_mid()
	_test_low_beats_standing_guard()
	_test_crouching_guard_stops_low()
	_test_high_beats_crouching_guard()
	_test_standing_guard_stops_high()
	_test_simultaneous_hits_trade()
	_test_ko_ends_round_and_next_round_resets()
	_test_pushboxes_never_overlap()
	print("input")
	_test_motion_is_relative_to_facing()
	_test_direction_selects_special()
	_test_motion_beats_direction()
	_test_dash_needs_a_tap()
	_test_chord_lenient_across_frames()
	print("throws, knockdown, projectiles, invulnerability")
	_test_throw_beats_guard()
	_test_back_throw_swaps_sides()
	_test_throws_cancel()
	_test_strike_beats_throw()
	_test_knockdown_is_invulnerable()
	_test_projectile_travels_and_hits()
	_test_one_projectile_at_a_time()
	_test_rising_is_invulnerable_at_start()
	print("throw escape and full guard")
	_test_throw_escape()
	_test_late_escape_fails()
	_test_full_guard_stops_everything()
	print("spirits")
	_test_spirit_strikes()
	_test_spirit_cooldown()
	_test_spirit_with_motion()
	_test_spirit_releases_projectile_for_summoner()
	print("controls text")
	_test_controls_text()
	print("guard, crawling, input slop")
	_test_holding_away_does_not_guard()
	_test_guard_shuffle_and_crawl()
	_test_no_attacking_while_guarding()
	_test_late_direction_upgrades_special()
	_test_chord_window_is_per_player()
	_test_unavailable_spirit_does_not_fall_through()
	print("kinds, spirit throws, finishers")
	_test_kinds_bind_the_other_kind()
	_test_spirit_throw_can_be_escaped_or_land()
	_test_finisher_binds()
	_test_no_finisher_on_own_kind()
	_test_finisher_times_out()
	print("guard chord, motions, cheats")
	_test_guard_chord_cancels_a_starting_attack()
	_test_motion_without_diagonal()
	_test_escape_while_holding_guard()
	_test_no_sealing_a_held_spirit()
	_test_invincible_takes_no_damage()
	print("signatures, spirit guard, tiers, saving")
	_test_naginata_wheel_strikes_behind()
	_test_two_heavens_beats_either_guard_height()
	_test_fox_step_crosses_over()
	_test_sake_heals_and_recharges()
	_test_spirits_need_spirit_guard()
	_test_command_grab_reaches_further()
	_test_spirit_guard_does_not_stop_ordinary_attacks()
	_test_armour_counter_slow_pull_air()
	_test_roster_data_and_every_special_runs()
	_test_binding_chooses_a_special()
	_test_combo_scaling_juggles_and_wakeup()
	_test_spirit_counter_guards_summoner()
	_test_warding_seal_paralyses()
	_test_time_limit()
	_test_finisher_captures_from_own_kind()
	_test_run_tiers_and_saving()
	_test_kanabo_quake()
	_test_hard_cpu_fights()
	_test_low_projectile_read()
	print("monsters, healing, tournament")
	_test_monster_parts_and_weak_point()
	_test_monster_leg_break_cripples()
	_test_monster_bout_rules()
	_test_monster_fights_on_its_own()
	_test_cpu_drinks_when_safe()
	_test_spirit_recharge_at_least_special()
	_test_tournament_engine()
	print("CPU, run, calibration")
	_test_cpu_enters_motions()
	_test_cpu_attacks()
	_test_run_rules()
	_test_calibration()
	print("selftest: %s" % ("all passed" if failures == 0 else "%d failed" % failures))
	quit(1 if failures > 0 else 0)


# --- helpers ---------------------------------------------------------------

func _bout(distance := 100.0) -> Bout:
	var b := Bout.new(def, def)
	b.fighters[0].position.x = -distance / 2.0
	b.fighters[1].position.x = distance / 2.0
	return b


## An Intent from numpad notation relative to `f`'s facing, plus buttons
## "ABCD" and "G" for guard.
func _in(f: Fighter, n: int, buttons := "") -> Intent:
	return Intent.from_numpad(n, f.facing, buttons)


## A script: frame -> [numpad, buttons]; unlisted frames hold direction `hold`
## and held buttons `held` (guard, "G").
func _at(events: Dictionary, hold := 5, held := "") -> Callable:
	return func(n: int) -> Array: return events.get(n, [hold, held])


## Runs `frames` frames. Player 1 is a script Callable, a DummyController, or
## null (idle). `each` is called after every frame with the bout.
func _run(b: Bout, frames: int, p0: Callable, p1 = null, each := Callable()) -> void:
	for n in frames:
		var a := b.fighters[0]
		var d := b.fighters[1]
		var r0: Array = p0.call(n)
		var i1 := Intent.new()
		if p1 is Callable:
			var r1: Array = p1.call(n)
			i1 = _in(d, r1[0], r1[1])
		elif p1 is DummyController:
			i1 = p1.read(d, a)
		var intents: Array[Intent] = [_in(a, r0[0], r0[1]), i1]
		b.step(intents)
		if each.is_valid():
			each.call(b)


func _taken(b: Bout, i: int) -> int:
	return b.fighters[i].definition.max_health - b.fighters[i].health


func _dmg(id: StringName) -> int:
	return def.moves[id].damage


func _check(name: String, ok: bool, detail := "") -> void:
	if ok:
		print("  pass  ", name)
	else:
		failures += 1
		print("  FAIL  ", name, "  ", detail)


# --- rules -------------------------------------------------------------------

func _test_light_hits_standing() -> void:
	var b := _bout()
	_run(b, 40, _at({0: [5, "A"]}))
	_check("standing light hits a standing opponent",
			_taken(b, 1) == _dmg(&"stand_light"), "took %d" % _taken(b, 1))


func _test_light_whiffs_over_crouch() -> void:
	var b := _bout()
	_run(b, 40, _at({0: [5, "A"]}), DummyController.new(DummyController.Mode.CROUCH))
	_check("standing light whiffs over a crouch", _taken(b, 1) == 0, "took %d" % _taken(b, 1))


func _test_standing_guard_stops_mid() -> void:
	var b := _bout()
	var seen := {}
	_run(b, 40, _at({0: [5, "B"]}), DummyController.new(DummyController.Mode.STAND_GUARD),
			func(x: Bout) -> void: seen[x.fighters[1].state] = true)
	_check("standing guard stops a mid attack",
			_taken(b, 1) == 0 and Fighter.State.BLOCKSTUN in seen, "took %d" % _taken(b, 1))


func _test_low_beats_standing_guard() -> void:
	var b := _bout()
	_run(b, 40, _at({0: [2, "A"]}, 2), DummyController.new(DummyController.Mode.STAND_GUARD))
	_check("low attack beats a standing guard",
			_taken(b, 1) == _dmg(&"crouch_light"), "took %d" % _taken(b, 1))


func _test_crouching_guard_stops_low() -> void:
	var b := _bout()
	_run(b, 40, _at({0: [2, "A"]}, 2), DummyController.new(DummyController.Mode.CROUCH_GUARD))
	_check("crouching guard stops a low attack", _taken(b, 1) == 0, "took %d" % _taken(b, 1))


func _airborne(f: Fighter, at: Vector2) -> void:
	f.position = at
	f.airborne = true
	f.velocity = Vector2.ZERO
	f.state = Fighter.State.JUMP


func _test_high_beats_crouching_guard() -> void:
	var b := _bout()
	_airborne(b.fighters[0], Vector2(-40, -60))
	_run(b, 40, _at({0: [5, "A"]}), DummyController.new(DummyController.Mode.CROUCH_GUARD))
	_check("jumping attack beats a crouching guard",
			_taken(b, 1) == _dmg(&"jump_light"), "took %d" % _taken(b, 1))


func _test_standing_guard_stops_high() -> void:
	var b := _bout()
	_airborne(b.fighters[0], Vector2(-40, -60))
	_run(b, 40, _at({0: [5, "A"]}), DummyController.new(DummyController.Mode.STAND_GUARD))
	_check("standing guard stops a jumping attack", _taken(b, 1) == 0, "took %d" % _taken(b, 1))


func _test_simultaneous_hits_trade() -> void:
	var b := _bout()
	_run(b, 30, _at({0: [5, "A"]}), _at({0: [5, "A"]}))
	var dmg := _dmg(&"stand_light")
	_check("simultaneous hits trade", _taken(b, 0) == dmg and _taken(b, 1) == dmg,
			"took %d / %d" % [_taken(b, 0), _taken(b, 1)])


func _test_ko_ends_round_and_next_round_resets() -> void:
	var b := _bout()
	b.fighters[1].health = 10
	_run(b, 20, _at({0: [5, "A"]}))
	var ended := b.phase == Bout.Phase.ROUND_OVER and b.wins[0] == 1 and b.round_winner == 0
	_run(b, Bout.ROUND_OVER_FRAMES + 1, _at({}))
	var reset := b.phase == Bout.Phase.FIGHT and b.round_number == 2 \
			and b.fighters[1].health == def.max_health
	_check("KO ends the round and awards it", ended, "phase %d wins %s" % [b.phase, b.wins])
	_check("next round starts at full health", reset, "phase %d round %d" % [b.phase, b.round_number])


func _test_pushboxes_never_overlap() -> void:
	var b := _bout(300.0)
	var overlapped := [false]
	var jumpy := func(n: int) -> Array: return [9 if n % 60 == 0 else 6, ""]
	_run(b, 240, jumpy, _at({}, 6), func(x: Bout) -> void:
		var r := x.fighters[0].pushbox().intersection(x.fighters[1].pushbox())
		if r.size.x > 0.01 and r.size.y > 0.01:
			overlapped[0] = true)
	_check("pushboxes never overlap", not overlapped[0])


# --- input -------------------------------------------------------------------

func _history(steps: Array) -> InputHistory:
	var h := InputHistory.new()
	for s in steps:
		var i := Intent.new()
		i.x = s[0]
		i.down = s[1]
		i.special = s[2]
		h.push(i)
	return h


func _test_motion_is_relative_to_facing() -> void:
	var cmd := Command.parse("236C", &"x")
	var rightward := _history([[0, true, false], [1, true, false], [1, false, true]])
	var leftward := _history([[0, true, false], [-1, true, false], [-1, false, true]])
	_check("236 toward the right matches when facing right", rightward.matches(cmd, 1, -1))
	_check("the same input does not match when facing left", not rightward.matches(cmd, -1, -1))
	_check("the mirrored input matches when facing left", leftward.matches(cmd, -1, -1))


func _move_after(script: Callable, frames := 3) -> StringName:
	var b := _bout(300.0)
	var id := [&""]
	_run(b, frames, script, null, func(x: Bout) -> void:
		if x.fighters[0].move and id[0] == &"":
			id[0] = x.fighters[0].move.id)
	return id[0]


func _test_direction_selects_special() -> void:
	var forward := _move_after(_at({0: [6, "C"]}))
	var down := _move_after(_at({0: [2, "C"]}))
	_check("toward + special is the rush, down + special the rising", forward == &"rush" and down == &"rising",
			"%s / %s" % [forward, down])


func _test_motion_beats_direction() -> void:
	var h := InputHistory.new()
	for step in [[0, true, false], [1, true, false], [1, false, true]]:
		var i := Intent.new()
		i.x = step[0]
		i.down = step[1]
		i.special = step[2]
		h.push(i)
	var motion := Command.parse("236C", &"m")
	var direction := Command.parse("6C", &"d")
	_check("the grammar still ranks a motion above its last direction",
			h.matches(motion, 1, -1) and h.matches(direction, 1, -1) and motion.rank() > direction.rank())


func _test_dash_needs_a_tap() -> void:
	var tapped := _move_after(_at({0: [6, ""], 1: [6, ""], 2: [5, ""], 3: [6, ""]}), 5)
	var held := _move_after(_at({}, 6), 30)
	_check("tapping 6 5 6 dashes", tapped == &"dash_forward", "got %s" % tapped)
	_check("holding 6 only walks", held == &"", "got %s" % held)


func _test_chord_lenient_across_frames() -> void:
	var b := _bout(70.0)
	_run(b, 30, _at({0: [5, "A"], 1: [5, "B"]}))
	_check("A then B a frame later is still a throw", _taken(b, 1) == _dmg(&"throw"),
			"took %d" % _taken(b, 1))


# --- throws, knockdown, projectiles, invulnerability -------------------------

func _test_throw_beats_guard() -> void:
	var b := _bout(70.0)
	var seen := {}
	_run(b, 30, _at({0: [5, "AB"]}), _at({}, 5, "G"),
			func(x: Bout) -> void: seen[x.fighters[1].state] = true)
	_check("throw beats a standing guard",
			_taken(b, 1) == _dmg(&"throw") and Fighter.State.KNOCKDOWN in seen,
			"took %d" % _taken(b, 1))


func _test_back_throw_swaps_sides() -> void:
	var b := _bout(70.0)
	_run(b, 30, _at({0: [4, "AB"]}, 4))
	var a := b.fighters[0]
	var d := b.fighters[1]
	_check("back throw lands the victim behind",
			_taken(b, 1) == _dmg(&"throw") and d.position.x < a.position.x,
			"attacker %.0f victim %.0f" % [a.position.x, d.position.x])


func _test_throws_cancel() -> void:
	var b := _bout(70.0)
	_run(b, 30, _at({0: [5, "AB"]}), _at({0: [5, "AB"]}))
	_check("simultaneous throws cancel", _taken(b, 0) == 0 and _taken(b, 1) == 0,
			"took %d / %d" % [_taken(b, 0), _taken(b, 1)])


func _test_strike_beats_throw() -> void:
	var b := _bout(70.0)
	_run(b, 30, _at({1: [5, "AB"]}), _at({0: [5, "A"]}))
	_check("a strike landing with a throw beats it",
			_taken(b, 0) == _dmg(&"stand_light") and _taken(b, 1) == 0,
			"took %d / %d" % [_taken(b, 0), _taken(b, 1)])


func _test_knockdown_is_invulnerable() -> void:
	var b := _bout()
	var d := b.fighters[1]
	d.state = Fighter.State.KNOCKDOWN
	d.stun = 40
	_run(b, 20, _at({0: [5, "A"]}))
	_check("a knocked-down fighter cannot be hit", _taken(b, 1) == 0, "took %d" % _taken(b, 1))


func _kitsune_bout(distance: float) -> Bout:
	var b := Bout.new(Roster.by_id(&"kitsune"), def)
	b.fighters[0].position.x = -distance / 2.0
	b.fighters[1].position.x = distance / 2.0
	return b


func _test_projectile_travels_and_hits() -> void:
	var b := _kitsune_bout(400.0)
	_run(b, 90, _at({0: [4, "C"]}))
	_check("the kitsune.s foxfire crosses the stage and hits",
			_taken(b, 1) == Roster.by_id(&"kitsune").moves[&"foxfire"].spawn.damage, "took %d" % _taken(b, 1))


func _test_one_projectile_at_a_time() -> void:
	var b := _kitsune_bout(900.0)
	var most := [0]
	var twice := _at({0: [4, "C"], 40: [4, "C"]})
	_run(b, 80, twice, null, func(x: Bout) -> void: most[0] = maxi(most[0], x.entities.size()))
	_check("only one projectile at a time", most[0] == 1, "saw %d" % most[0])


func _test_rising_is_invulnerable_at_start() -> void:
	var b := _bout()
	var would_have_hit := [false]
	_run(b, 20, _at({0: [5, "A"]}), _at({4: [2, "C"]}), func(x: Bout) -> void:
		var d := x.fighters[1]
		if d.invulnerable():
			for box in x.fighters[0].active_hitboxes():
				if box.intersects(d.hurtbox()):
					would_have_hit[0] = true)
	_check("rising is invulnerable through a light that overlaps it",
			would_have_hit[0] and _taken(b, 1) == 0,
			"overlapped %s, took %d" % [would_have_hit[0], _taken(b, 1)])


# --- throw escape and full guard --------------------------------------------

func _test_throw_escape() -> void:
	var b := _bout(70.0)
	# The throw connects on frame 4; the victim answers 5 frames later.
	_run(b, 40, _at({0: [5, "AB"]}), _at({9: [5, "AB"]}))
	_check("A+B while held escapes the throw", _taken(b, 0) == 0 and _taken(b, 1) == 0,
			"took %d / %d" % [_taken(b, 0), _taken(b, 1)])


func _test_late_escape_fails() -> void:
	var b := _bout(70.0)
	_run(b, 40, _at({0: [5, "AB"]}), _at({4 + Bout.TECH_WINDOW + 2: [5, "AB"]}))
	_check("escaping after the window is too late", _taken(b, 1) == _dmg(&"throw"),
			"took %d" % _taken(b, 1))


func _test_full_guard_stops_everything() -> void:
	var results := []
	for attempt in [[[5, "B"], false], [[2, "A"], false], [[5, "A"], true], [[5, "AB"], false]]:
		var b := _bout(70.0)
		if attempt[1]:
			_airborne(b.fighters[0], Vector2(-40, -60))
		var script := _at({0: attempt[0]}, attempt[0][0] if attempt[0][0] == 2 else 5)
		_run(b, 40, script, DummyController.new(DummyController.Mode.FULL_GUARD))
		results.append(_taken(b, 1))
	_check("full guard stops mid, low, overhead and throw", results == [0, 0, 0, 0],
			"took %s" % [results])


# --- spirits -----------------------------------------------------------------

func _spirit_bout(spirit: SpiritBinding, distance: float, summoner: FighterDefinition = def) -> Bout:
	var bound: Array[SpiritBinding] = [spirit]
	var b := Bout.new(summoner, def, bound, [])
	b.fighters[0].position.x = -distance / 2.0
	b.fighters[1].position.x = distance / 2.0
	return b


func _test_spirit_strikes() -> void:
	var shuten := _r(&"shuten")
	var b := _spirit_bout(SpiritBinding.new(shuten, &"sake"), 600.0)
	b.fighters[0].health = 500
	_run(b, 80, _at({0: [5, "D"]}))
	_check("an oni spirit bound with Sake heals its summoner",
			b.fighters[0].health == 500 + shuten.moves[&"sake"].heal, "health %d" % b.fighters[0].health)


func _test_spirit_cooldown() -> void:
	var b := _spirit_bout(SpiritBinding.new(_r(&"shuten"), &"kanabo_quake"), 600.0)
	var seen := {}
	_run(b, 120, _at({0: [5, "D"], 60: [5, "D"]}), null, func(x: Bout) -> void:
		for s in x.spirits:
			seen[s.get_instance_id()] = true)
	_check("a spirit on cooldown cannot be summoned again", seen.size() == 1,
			"summoned %d" % seen.size())


func _test_spirit_with_motion() -> void:
	var kitsune := _r(&"kitsune")
	var b := _spirit_bout(SpiritBinding.new(kitsune, &"fox_step"), 300.0)
	var crossed := [false]
	_run(b, 60, _at({0: [5, "D"]}), null, func(x: Bout) -> void:
		for s in x.spirits:
			if s.position.x > x.fighters[1].position.x:
				crossed[0] = true)
	_check("a fox spirit steps behind the opponent and strikes",
			crossed[0] and _taken(b, 1) == kitsune.moves[&"fox_step"].damage, "took %d" % _taken(b, 1))


func _test_spirit_releases_projectile_for_summoner() -> void:
	var kitsune := _r(&"kitsune")
	var b := _spirit_bout(SpiritBinding.new(kitsune, &"foxfire"), 500.0)
	var owners := {}
	_run(b, 120, _at({0: [5, "D"]}), null, func(x: Bout) -> void:
		for e in x.entities:
			owners[e.owner_index] = true)
	_check("a spirit's projectile belongs to the summoner and hits",
			owners.keys() == [0] and _taken(b, 1) == kitsune.moves[&"foxfire"].spawn.damage,
			"owners %s, took %d" % [owners.keys(), _taken(b, 1)])


# --- controls text -----------------------------------------------------------

func _test_controls_text() -> void:
	var right := ControlsText.describe("236C", 1, "p1_")
	var left := ControlsText.describe("236C", -1, "p1_")
	var tap := ControlsText.describe("656", 1, "p1_")
	_check("commands render as player 1's keys for each facing",
			right == "S, S+D, D + L" and left == "S, S+A, A + L" and tap == "D, release, D",
			"%s | %s | %s" % [right, left, tap])


# --- guard button, crawling, input slop --------------------------------------

func _test_holding_away_does_not_guard() -> void:
	var b := _bout()
	_run(b, 40, _at({0: [5, "B"]}), _at({}, 4))
	_check("holding away only walks; it does not guard",
			_taken(b, 1) == _dmg(&"stand_heavy"), "took %d" % _taken(b, 1))


func _test_guard_shuffle_and_crawl() -> void:
	var b := _bout(400.0)
	var start := b.fighters[0].position.x
	_run(b, 30, _at({}, 6, "G"))
	var guarded := b.fighters[0].position.x - start
	b = _bout(400.0)
	_run(b, 30, _at({}, 3))
	var crawled := b.fighters[0].position.x - start
	var expect_guard := 30 * def.walk_forward * def.guard_factor
	var expect_crawl := 30 * def.walk_forward * def.crawl_factor
	_check("guarding shuffles and crouching crawls at their own speeds",
			is_equal_approx(guarded, expect_guard) and is_equal_approx(crawled, expect_crawl),
			"guard %.1f (want %.1f), crawl %.1f (want %.1f)" % [guarded, expect_guard, crawled, expect_crawl])


func _test_no_attacking_while_guarding() -> void:
	var b := _bout()
	_run(b, 30, _at({0: [5, "AG"]}, 5, "G"))
	_check("attack buttons do nothing while guard is held", _taken(b, 1) == 0,
			"took %d" % _taken(b, 1))


func _test_late_direction_upgrades_special() -> void:
	var b := _bout(300.0)
	_run(b, 4, _at({0: [5, "C"], 1: [2, ""]}, 2))
	var m := b.fighters[0].move
	var id: StringName = m.id if m else &""
	_check("down arriving a frame after special still gives the down special", id == &"rising",
			"got %s" % id)


func _test_chord_window_is_per_player() -> void:
	var narrow := _bout(70.0)
	_run(narrow, 40, _at({0: [5, "A"], 4: [5, "B"]}))
	var wide := _bout(70.0)
	wide.fighters[0].set_chord_window(6)
	_run(wide, 40, _at({0: [5, "A"], 4: [5, "B"]}))
	_check("presses 4 frames apart: separate by default, together with a wider window",
			_taken(narrow, 1) != _dmg(&"throw") and _taken(wide, 1) == _dmg(&"throw"),
			"default took %d, wide took %d" % [_taken(narrow, 1), _taken(wide, 1)])


func _test_unavailable_spirit_does_not_fall_through() -> void:
	var bound: Array[SpiritBinding] = [SpiritBinding.new(_r(&"shuten"), &"kanabo_quake"),
			SpiritBinding.new(_r(&"kitsune"), &"foxfire")]
	var b := Bout.new(def, def, bound, [])
	b.fighters[0].position.x = -400
	b.fighters[1].position.x = 400
	var sources := {}
	_run(b, 90, _at({0: [2, "D"], 50: [2, "D"]}, 2), null, func(x: Bout) -> void:
		for s in x.spirits:
			sources[s.definition.id] = true)
	_check("down+spirit on cooldown summons nothing, not the other slot",
			sources.keys() == [&"kitsune"], "summoned %s" % [sources.keys()])


# --- kinds, spirit throws, finishers -----------------------------------------

func _test_kinds_bind_the_other_kind() -> void:
	var human := _r(&"musashi")
	var oni := _r(&"shuten")
	var fox := _r(&"kitsune")
	_check("humans bind yokai, yokai bind humans, never their own kind",
			human.binds(oni) and oni.binds(human) and not oni.binds(fox) and not human.binds(human))


func _throwing_spirit() -> SpiritBinding:
	return SpiritBinding.new(_r(&"musashi"), &"throw")


func _test_spirit_throw_can_be_escaped_or_land() -> void:
	var landed := _spirit_bout(_throwing_spirit(), 80.0, _r(&"shuten"))
	_run(landed, 50, _at({0: [5, "D"]}))
	var escaped := _spirit_bout(_throwing_spirit(), 80.0, _r(&"shuten"))
	var seen_grab := [false]
	_run(escaped, 50, _at({0: [5, "D"]}), func(n: int) -> Array:
		return [5, "AB" if seen_grab[0] else ""], func(x: Bout) -> void:
			if x.fighters[1].state == Fighter.State.GRABBED:
				seen_grab[0] = true)
	var throw_damage: int = _r(&"musashi").moves[&"throw"].damage
	_check("a spirit's throw lands, or can be escaped like any throw",
			_taken(landed, 1) == throw_damage and seen_grab[0] and _taken(escaped, 1) == 0,
			"landed took %d, escaped took %d" % [_taken(landed, 1), _taken(escaped, 1)])


func _beaten(winner_def: FighterDefinition, loser_def: FighterDefinition) -> Bout:
	var b := Bout.new(winner_def, loser_def)
	b.fighters[0].position.x = -50
	b.fighters[1].position.x = 50
	b.wins[0] = 1
	b.fighters[1].health = 10
	_run(b, 20, _at({0: [5, "A"]}))
	return b


func _test_finisher_binds() -> void:
	var b := _beaten(def, _r(&"shuten"))
	var dazed := b.phase == Bout.Phase.FINISH and b.fighters[1].state == Fighter.State.DAZED
	_run(b, 80, _at({0: [4, ""], 1: [6, "D"]}))
	_check("a beaten foe of the other kind is sealed by the shared finisher input",
			dazed and b.bound and b.phase == Bout.Phase.BOUT_OVER,
			"dazed %s bound %s phase %d" % [dazed, b.bound, b.phase])


func _test_no_finisher_on_own_kind() -> void:
	var b := _beaten(def, def)
	_check("no finisher against one's own kind", b.phase == Bout.Phase.BOUT_OVER and not b.bound,
			"phase %d" % b.phase)


func _test_finisher_times_out() -> void:
	var b := _beaten(def, _r(&"shuten"))
	_run(b, Bout.FINISH_FRAMES + 5, _at({}))
	_check("without a finisher the foe collapses and nothing is bound",
			b.phase == Bout.Phase.BOUT_OVER and not b.bound and b.fighters[1].state == Fighter.State.KO,
			"phase %d bound %s" % [b.phase, b.bound])


# --- CPU, run, calibration ---------------------------------------------------

func _test_cpu_enters_motions() -> void:
	var queue := CpuController.inputs_for("2C", 1)
	var b := _bout(300.0)
	var found := [&""]
	for n in 6:
		var i0: Intent = queue[n] if n < queue.size() else Intent.new()
		var intents: Array[Intent] = [i0, Intent.new()]
		b.step(intents)
		if b.fighters[0].move and found[0] == &"":
			found[0] = b.fighters[0].move.id
	_check("the CPU enters command patterns frame by frame", found[0] == &"rising",
			"got %s" % found[0])


func _test_cpu_attacks() -> void:
	var b := _bout(300.0)
	var cpu := CpuController.new(CpuController.EASY, 7)
	for n in 1500:
		var intents: Array[Intent] = [cpu.read(b.fighters[0], b.fighters[1]), Intent.new()]
		b.step(intents)
	_check("the easy CPU closes in and lands hits on an idle opponent", _taken(b, 1) > 0,
			"took %d" % _taken(b, 1))


func _test_run_rules() -> void:
	var all := Roster.all()
	var run := Run.new(all[0], all, 11)
	var kinds_ok := true
	var counts_ok := true
	for k in 300:
		for s in run.opponent_spirits:
			kinds_ok = kinds_ok and run.opponent.binds(s.source) and s.move in s.source.specials
		counts_ok = counts_ok and run.opponent_spirits.size() == Run.CARRIED[run.place_in_tier()]
		run.fight = k % Run.length()
		run._draw_opponent()
	_check("opponents carry 0, 1, 2, 2 spirits through each tier, of the kind they can bind",
			kinds_ok and counts_ok)
	# Walk a run: grant at fight 2, captures from humans, seals of yokai.
	var r := Run.new(_r(&"musashi"), all, 3)
	var granted_ok := true
	var offers_ok := true
	while true:
		var before := r.spirits.size()
		if r.grants_on_victory():
			r.after_victory(false)
			granted_ok = granted_ok and r.spirits.size() == before + 1
		elif r.place_in_tier() >= 2:
			var choice := r.after_victory(true)
			var own_kind := r.tier() == 0
			for b in r.offer:
				offers_ok = offers_ok and (b.source.kind != r.character.kind)
				offers_ok = offers_ok and (b.source == r.opponent) != own_kind
			if choice:
				if r.choose_offer(0):
					r.choose_slot(1)
		if not r.advance():
			break
	_check("the second fight's spirit is granted; humans' carried spirits and yokai themselves are offered",
			granted_ok and offers_ok and r.spirits.size() == Run.SLOTS, "spirits %d" % r.spirits.size())


func _test_calibration() -> void:
	var separable: Array[int] = [0, 1, 1, 2]
	var quick: Array[int] = [5, 6, 7]
	var close: Array[int] = [0, 3]
	var overlap: Array[int] = [2, 4]
	var math_ok := Calibration.window_for(separable, quick) == 4 \
			and Calibration.window_for(close, overlap) == 4
	var c := Calibration.new()
	_feed(c, [{light = true}])  # player 1 chooses
	for rep in Calibration.REPS:
		_feed(c, [{light = true}, {heavy = true}])                 # throw, 1 frame apart
	for rep in Calibration.REPS:
		_feed(c, [{light = true, special = true}])                 # guard, same frame
	for rep in Calibration.REPS:
		_feed(c, [{light = true, spirit = true}, {special = true}])  # spirit guard, 1 frame
	for rep in Calibration.REPS:
		_feed(c, [{x = 1}, {x = 1}, {x = 1, special = true}])       # toward held first: never late
	for rep in Calibration.REPS:
		_feed(c, [{spirit = true}, {down = true}])                  # spirit 1 frame before down
	for rep in Calibration.REPS:
		_feed(c, [{light = true}] + _repeat({}, 6) + [{heavy = true}])  # 7 frames apart
	_check("calibration: window maths, and the whole sequence of trials",
			math_ok and c.stage == Calibration.Stage.DONE and c.player == 0
			and c.chord_gaps.max() == 1 and c.sequence_gaps.min() == 7
			and c.chord_window() == 4,
			"stage %d gaps %s seq %s" % [c.stage, c.chord_gaps, c.sequence_gaps])


func _repeat(frame: Dictionary, n: int) -> Array:
	var out := []
	for k in n:
		out.append(frame)
	return out


## Feeds frames (dictionaries of Intent fields) for player 1, then a pause.
func _feed(c: Calibration, frames: Array) -> void:
	for f in frames + _repeat({}, 35):
		var i := Intent.new()
		for key in f:
			i.set(key, f[key])
		var intents: Array[Intent] = [i, Intent.new()]
		c.observe(intents)


# --- guard chord, motions, cheats --------------------------------------------

func _test_guard_chord_cancels_a_starting_attack() -> void:
	var b := _bout()
	var seen := {}
	_run(b, 30, _at({0: [5, "A"], 1: [5, "CG"]}, 5, "G"), null, func(x: Bout) -> void:
		seen[x.fighters[0].state] = true)
	_check("light, then special a frame later while holding light, becomes guard",
			Fighter.State.GUARD in seen and _taken(b, 1) == 0 and b.fighters[0].state == Fighter.State.GUARD,
			"took %d, state %s" % [_taken(b, 1), Fighter.State.keys()[b.fighters[0].state]])


func _test_motion_without_diagonal() -> void:
	var h := InputHistory.new()
	for step in [[0, true, false], [1, false, true]]:
		var i := Intent.new()
		i.x = step[0]
		i.down = step[1]
		i.special = step[2]
		h.push(i)
	_check("a motion may skip its middle diagonal", h.matches(Command.parse("236C", &"m"), 1, -1))


func _test_escape_while_holding_guard() -> void:
	var b := _bout(70.0)
	var grabbed := [false]
	_run(b, 40, _at({0: [5, "AB"]}), func(n: int) -> Array:
		return [5, "BG" if grabbed[0] else "G"], func(x: Bout) -> void:
			if x.fighters[1].state == Fighter.State.GRABBED:
				grabbed[0] = true)
	_check("while holding guard, pressing heavy escapes a throw", grabbed[0] and _taken(b, 1) == 0,
			"grabbed %s, took %d" % [grabbed[0], _taken(b, 1)])


func _test_no_sealing_a_held_spirit() -> void:
	var bound: Array[SpiritBinding] = [SpiritBinding.new(_r(&"shuten"), &"sake")]
	var b := Bout.new(def, _r(&"shuten"), bound, [])
	b.fighters[0].position.x = -50
	b.fighters[1].position.x = 50
	b.wins[0] = 1
	b.fighters[1].health = 10
	_run(b, 20, _at({0: [5, "A"]}))
	_check("a spirit already held cannot be sealed again", b.phase == Bout.Phase.BOUT_OVER and not b.bound,
			"phase %d" % b.phase)


func _test_invincible_takes_no_damage() -> void:
	var b := _bout()
	b.fighters[1].invincible = true
	var seen := {}
	_run(b, 40, _at({0: [5, "B"]}), null, func(x: Bout) -> void: seen[x.fighters[1].state] = true)
	_check("an invincible fighter is still hit but loses no health",
			_taken(b, 1) == 0 and Fighter.State.HITSTUN in seen, "took %d" % _taken(b, 1))


# --- signatures, spirit guard, tiers, saving ---------------------------------


func _test_fox_step_crosses_over() -> void:
	var kitsune := _r(&"kitsune")
	var b := Bout.new(kitsune, def)
	b.fighters[0].position.x = -100
	b.fighters[1].position.x = 100
	_run(b, 40, _at({0: [5, "C"]}))
	_check("Fox Step reappears behind the opponent and strikes",
			b.fighters[0].position.x > b.fighters[1].position.x
			and _taken(b, 1) == kitsune.moves[&"fox_step"].damage,
			"at %.0f vs %.0f, took %d" % [b.fighters[0].position.x, b.fighters[1].position.x, _taken(b, 1)])


func _test_sake_heals_and_recharges() -> void:
	var shuten := _r(&"shuten")
	var b := Bout.new(shuten, def)
	b.fighters[0].position.x = -400
	b.fighters[1].position.x = 400
	b.fighters[0].health = 500
	_run(b, 140, _at({0: [5, "C"], 80: [5, "C"]}))
	_check("Sake heals once, then must recharge",
			b.fighters[0].health == 500 + shuten.moves[&"sake"].heal, "health %d" % b.fighters[0].health)


func _spirit_guard_case(guard: String) -> int:
	var bound: Array[SpiritBinding] = [SpiritBinding.new(_r(&"tomoe"), &"naginata_wheel")]
	var b := Bout.new(_r(&"kitsune"), def, bound, [])
	b.fighters[0].position.x = -50
	b.fighters[1].position.x = 50
	_run(b, 40, _at({0: [5, "D"]}), _at({}, 5, guard))
	return _taken(b, 1)


func _test_spirits_need_spirit_guard() -> void:
	var plain := _spirit_guard_case("G")
	var spirit := _spirit_guard_case("P")
	_check("plain guard does not stop a spirit; spirit guard does", plain > 0 and spirit == 0,
			"plain took %d, spirit guard took %d" % [plain, spirit])


func _test_run_tiers_and_saving() -> void:
	var all := Roster.all()
	var r := Run.new(all[0], all, 5)
	var kinds_ok := true
	var opponents: Array = []
	var yokai: FighterDefinition = all.filter(func(d: FighterDefinition) -> bool:
		return d.kind == FighterDefinition.Kind.YOKAI)[0]
	while true:
		var own := r.opponent.kind == r.character.kind
		kinds_ok = kinds_ok and own == (r.tier() == 0)
		opponents.append(r.opponent.id)
		if r.fight == 2:
			r.spirits.append(SpiritBinding.new(yokai, yokai.specials[1]))
			var saved := r.to_dict()
			var resumed := Run.restore(saved, all)
			var later: Array = []
			var original: Array = []
			while resumed.advance():
				later.append(resumed.opponent.id)
			var copy := Run.restore(saved, all)
			while copy.advance():
				original.append(copy.opponent.id)
			kinds_ok = kinds_ok and later == original and resumed.spirits[0].source.id == yokai.id \
					and resumed.spirits[0].move == yokai.specials[1]
		if not r.advance():
			break
	_check("the first tier is your own kind, the rest the other; a saved run resumes identically",
			kinds_ok and opponents.size() == Run.length(), "opponents %s" % [opponents])


func _r(id: StringName) -> FighterDefinition:
	return Roster.by_id(id)


func _test_naginata_wheel_strikes_behind() -> void:
	var tomoe := _r(&"tomoe")
	var b := Bout.new(tomoe, def)
	var a := b.fighters[0]
	a.position.x = 0
	b.fighters[1].position.x = 70
	a.facing = -1
	a.perform(&"naginata_wheel")
	_run(b, 30, _at({}))
	_check("Tomoe's naginata wheel strikes behind as well as in front",
			_taken(b, 1) == tomoe.moves[&"naginata_wheel"].damage, "took %d" % _taken(b, 1))


func _test_two_heavens_beats_either_guard_height() -> void:
	var musashi := _r(&"musashi")
	var taken := []
	for guard in [5, 2]:
		var b := Bout.new(musashi, def)
		b.fighters[0].position.x = -50
		b.fighters[1].position.x = 50
		_run(b, 40, _at({0: [5, "C"]}), _at({}, guard, "G"))
		taken.append(_taken(b, 1))
	var dmg: int = musashi.moves[&"two_heavens"].damage
	_check("Two Heavens strikes high and low together: neither guard height stops it",
			taken == [dmg, dmg], "took %s" % [taken])


func _test_spirit_guard_does_not_stop_ordinary_attacks() -> void:
	var b := _bout()
	_run(b, 40, _at({0: [5, "B"]}), _at({}, 5, "P"))
	_check("spirit guard does not stop an ordinary attack", _taken(b, 1) == _dmg(&"stand_heavy"),
			"took %d" % _taken(b, 1))


func _test_command_grab_reaches_further() -> void:
	var benkei := _r(&"benkei")
	var grabbed := Bout.new(benkei, def)
	grabbed.fighters[0].position.x = -60
	grabbed.fighters[1].position.x = 60
	_run(grabbed, 40, _at({0: [4, "C"]}, 4))
	var thrown := Bout.new(benkei, def)
	thrown.fighters[0].position.x = -60
	thrown.fighters[1].position.x = 60
	_run(thrown, 40, _at({0: [5, "AB"]}))
	_check("Benkei's grapple reaches where a normal throw does not",
			_taken(grabbed, 1) == benkei.moves[&"seven_weapons"].damage and _taken(thrown, 1) == 0,
			"grab %d, throw %d" % [_taken(grabbed, 1), _taken(thrown, 1)])


func _test_armour_counter_slow_pull_air() -> void:
	# Armour: Benkei's Standing Death takes a light without being interrupted.
	var armoured := Bout.new(_r(&"benkei"), def)
	armoured.fighters[0].position.x = -40
	armoured.fighters[1].position.x = 70
	var interrupted := [false]
	_run(armoured, 30, _at({3: [5, "C"]}), _at({0: [5, "A"]}), func(x: Bout) -> void:
		if x.fighters[0].state == Fighter.State.HITSTUN:
			interrupted[0] = true)
	var armour_ok: bool = _taken(armoured, 0) > 0 and not interrupted[0]
	# Counter: Musashi's Void stance answers a strike.
	var countered := Bout.new(_r(&"musashi"), def)
	countered.fighters[0].position.x = -50
	countered.fighters[1].position.x = 50
	_run(countered, 40, _at({0: [4, "C"]}, 4), _at({4: [5, "A"]}))
	var counter_ok: bool = _taken(countered, 0) == 0 and _taken(countered, 1) > 0
	# Kawarimi: Hanzō's counter reappears behind the attacker.
	var subbed := Bout.new(_r(&"hanzo"), def)
	subbed.fighters[0].position.x = -50
	subbed.fighters[1].position.x = 50
	_run(subbed, 30, _at({0: [5, "C"]}), _at({4: [5, "A"]}))
	var kawarimi_ok: bool = subbed.fighters[0].position.x > subbed.fighters[1].position.x and _taken(subbed, 0) == 0
	# Slow: frost breath halves walking.
	var frozen := Bout.new(_r(&"yuki_onna"), def)
	frozen.fighters[0].position.x = -50
	frozen.fighters[1].position.x = 50
	_run(frozen, 40, _at({0: [5, "C"]}))
	var slow_ok: bool = frozen.fighters[1].slow_frames > 0
	# Pull: the web draws the victim toward the spider.
	var webbed := Bout.new(_r(&"jorogumo"), def)
	webbed.fighters[0].position.x = -200
	webbed.fighters[1].position.x = 200
	_run(webbed, 90, _at({0: [5, "C"]}))
	var pull_ok: bool = _taken(webbed, 1) > 0 and webbed.fighters[1].position.x < 200
	# Air: Tomoe's wheel works in the air; Musashi's Two Heavens does not.
	var flying := Bout.new(_r(&"tomoe"), def)
	_airborne(flying.fighters[0], Vector2(-40, -80))
	_run(flying, 4, _at({0: [5, "C"]}))
	var grounded := Bout.new(_r(&"musashi"), def)
	_airborne(grounded.fighters[0], Vector2(-40, -80))
	_run(grounded, 4, _at({0: [5, "C"]}))
	var m1 := flying.fighters[0].move
	var m2 := grounded.fighters[0].move
	var air_ok: bool = m1 != null and m1.id == &"naginata_wheel" and (m2 == null or m2.id != &"two_heavens")
	_check("armour, counters, kawarimi, slow, pull and air specials behave as specified",
			armour_ok and counter_ok and kawarimi_ok and slow_ok and pull_ok and air_ok,
			"armour %s counter %s kawarimi %s slow %s pull %s air %s" % [armour_ok, counter_ok, kawarimi_ok, slow_ok, pull_ok, air_ok])


func _test_roster_data_and_every_special_runs() -> void:
	var all := Roster.all()
	var ids := {}
	var humans := 0
	var shape_ok := true
	var ran := true
	for d in all:
		ids[d.id] = true
		humans += int(d.kind == FighterDefinition.Kind.HUMAN)
		shape_ok = shape_ok and d.specials.size() == 2 and d.finisher_move != null
		for id in d.specials:
			var m: MoveDefinition = d.moves[id]
			shape_ok = shape_ok and m.cooldown > 0
			var b := Bout.new(d, def)
			b.fighters[0].perform(id)
			_run(b, 150, _at({}))
			var f := b.fighters[0]
			ran = ran and not (f.state == Fighter.State.MOVE and f.move == m)
	_check("sixteen fighters, eight of each kind, two recharging specials each; every special completes",
			all.size() == 16 and ids.size() == 16 and humans == 8 and shape_ok and ran,
			"%d fighters, %d humans" % [all.size(), humans])


func _test_binding_chooses_a_special() -> void:
	var all := Roster.all()
	var r := Run.new(_r(&"musashi"), all, 9)
	r.fight = Run.FIGHTS_PER_TIER + 2
	r.opponent = _r(&"shuten")
	r.after_victory(true)
	var offered := r.offer.map(func(b: SpiritBinding) -> StringName: return b.move)
	r.choose_offer(1)
	var kept := r.spirits.size() == 1 and r.spirits[0].move == &"kanabo_quake"
	r.opponent = _r(&"kitsune")
	r.after_victory(true)
	r.choose_offer(-1)
	_check("sealing offers both specials, records the choice, and can be declined",
			offered == [&"sake", &"kanabo_quake"] and kept and r.spirits.size() == 1,
			"offered %s" % [offered])


func _test_combo_scaling_juggles_and_wakeup() -> void:
	# A light landing as the fourth hit of a combo.
	var scaled := _bout()
	var a := scaled.fighters[0]
	a.perform(&"stand_light")
	a.state_frame = a.move.startup
	scaled.combo[1] = 3
	scaled._resolve_hits()
	var scale_ok := _taken(scaled, 1) == roundi(_dmg(&"stand_light") * (1.0 - 3 * Bout.COMBO_STEP))
	var f := Fighter.new(def)
	f.reset(0, 1)
	f.airborne = true
	f.state = Fighter.State.KNOCKDOWN
	var falling_hittable := not f.invulnerable()
	f.juggle_hits = Fighter.JUGGLE_LIMIT
	var juggle_capped := f.invulnerable()
	var g := Fighter.new(def)
	g.reset(0, 1)
	g.state = Fighter.State.KNOCKDOWN
	g.stun = 1
	g.record(Intent.new())
	g.step()
	var woke_safe := g.state == Fighter.State.STAND and g.invulnerable()
	for k in Fighter.WAKE_FRAMES:
		g.record(Intent.new())
		g.step()
	var then_open := not g.invulnerable()
	_check("combo damage scales; falling foes can be juggled up to a limit; rising is briefly safe",
			scale_ok and falling_hittable and juggle_capped and woke_safe and then_open,
			"scale %s falling %s capped %s woke %s open %s" % [scale_ok, falling_hittable, juggle_capped, woke_safe, then_open])


func _test_spirit_counter_guards_summoner() -> void:
	var bound: Array[SpiritBinding] = [SpiritBinding.new(_r(&"tanuki"), &"leaf_disguise")]
	var b := Bout.new(def, def, bound, [])
	b.fighters[0].position.x = -50
	b.fighters[1].position.x = 50
	_run(b, 50, _at({0: [5, "D"]}), _at({8: [5, "A"]}))
	_check("a spirit's counter stance takes a strike for its summoner and answers it",
			_taken(b, 0) == 0 and _taken(b, 1) > 0, "summoner took %d, attacker took %d" % [_taken(b, 0), _taken(b, 1)])


func _test_warding_seal_paralyses() -> void:
	var b := Bout.new(_r(&"miko"), def)
	b.fighters[0].position.x = -150
	b.fighters[1].position.x = 150
	var held := [0]
	_run(b, 160, _at({0: [4, "C"]}, 4), _at({}, 6), func(x: Bout) -> void:
		var d := x.fighters[1]
		if d.state == Fighter.State.HITSTUN:
			held[0] += 1)
	var seal: MoveDefinition = _r(&"miko").moves[&"warding_seal"].spawn
	_check("stepping on the warding seal holds the victim in place",
			held[0] >= seal.paralyse - 2 and _taken(b, 1) == seal.damage,
			"held %d frames, took %d" % [held[0], _taken(b, 1)])


func _test_time_limit() -> void:
	var b := _bout()
	b.time_limit = 30
	b.fighters[0].health = 900
	_run(b, 40, _at({}))
	_check("when time runs out, the larger share of health takes the round",
			b.wins[1] == 1 and b.wins[0] == 0, "wins %s" % [b.wins])


func _test_finisher_captures_from_own_kind() -> void:
	var carrying: Array[SpiritBinding] = [SpiritBinding.new(_r(&"kitsune"), &"foxfire")]
	var b := Bout.new(def, def, [], carrying)
	b.fighters[0].position.x = -50
	b.fighters[1].position.x = 50
	b.wins[0] = 1
	b.fighters[1].health = 10
	_run(b, 20, _at({0: [5, "A"]}))
	_check("a beaten human carrying a yokai spirit can be finished to capture it",
			b.phase == Bout.Phase.FINISH, "phase %d" % b.phase)


func _test_kanabo_quake() -> void:
	var shuten := _r(&"shuten")
	var results := []
	# Opponent behind and standing; behind and guarding low; behind and in the air.
	for case in [["", false], ["G", false], ["", true]]:
		var b := Bout.new(shuten, def)
		var a := b.fighters[0]
		a.position.x = 0
		b.fighters[1].position.x = 150
		a.facing = -1
		if case[1]:
			_airborne(b.fighters[1], Vector2(150, -400))  # still falling when the quake passes
		a.perform(&"kanabo_quake")
		var downed := [false]
		_run(b, 40, _at({}), _at({}, 2 if case[0] == "G" else 5, case[0]), func(x: Bout) -> void:
			if x.fighters[1].state == Fighter.State.KNOCKDOWN:
				downed[0] = true)
		results.append(downed[0])
	_check("the quake knocks down a standing foe behind the oni, not one guarding low or in the air",
			results == [true, false, false], "knocked down: %s" % [results])


func _test_hard_cpu_fights() -> void:
	var a := _r(&"musashi")
	var b := Bout.new(a, _r(&"shuten"))
	var cpus := [CpuController.new(CpuController.HARD, 1), CpuController.new(CpuController.HARD, 2)]
	for n in 3000:
		var f := b.fighters
		var intents: Array[Intent] = [cpus[0].read(f[0], f[1]), cpus[1].read(f[1], f[0])]
		b.step(intents)
	_check("two Hard computers fight each other and both land hits",
			b.fighters[0].health < b.fighters[0].definition.max_health or b.wins[1] > 0,
			"healths %d / %d" % [b.fighters[0].health, b.fighters[1].health])


func _test_low_projectile_read() -> void:
	var kappa := _r(&"kappa")
	var b := Bout.new(kappa, def)
	b.fighters[0].position.x = -250
	b.fighters[1].position.x = 250
	_run(b, 90, _at({0: [4, "C"]}, 4), DummyController.new(DummyController.Mode.FULL_GUARD))
	_check("full guard reads a low projectile in flight and guards it crouching", _taken(b, 1) == 0,
			"took %d" % _taken(b, 1))


# --- monsters, healing, tournament -------------------------------------------

const Bestiary := preload("res://game/monsters/bestiary.gd")


func _monster_bout(distance := 400.0) -> Bout:
	var b := Bout.versus_monster(def, [], Monster.new(Bestiary.by_id(&"ushi_oni"), 3))
	b.fighters[0].position.x = -distance / 2.0
	b.fighters[1].position.x = distance / 2.0
	return b


func _test_monster_parts_and_weak_point() -> void:
	var b := _monster_bout()
	var oni: Monster = b.fighters[1]
	var head := 3
	var hidden_at_rest := not oni.exposed(head)
	var charge: MonsterDefinition.Attack = oni.monster.attacks.filter(
			func(a: MonsterDefinition.Attack) -> bool: return a.move.id == &"charge")[0]
	oni.attack = charge
	oni._begin(charge.move)
	var pushless_mid_charge := false
	var head_open_after := false
	for n in charge.move.total_frames():
		var intents: Array[Intent] = [Intent.new(), Intent.new()]
		b.fighters[0].health = def.max_health  # keep the fighter standing
		b.step(intents)
		if oni.state == Fighter.State.MOVE and oni.move.is_active_on(oni.state_frame) and not oni.pushbox().has_area():
			pushless_mid_charge = true
		if oni.exposed(head):
			head_open_after = true
	# Damage by part: a shell hit is halved, a leg hit full.
	var shell_hit := MoveDefinition.new()
	shell_hit.damage = 100
	var before := oni.health
	oni.receive(shell_hit, 1, false, 1.0, oni.to_world(oni.monster.parts[0].box).grow(-10))
	var shell_loss := before - oni.health
	before = oni.health
	oni.receive(shell_hit, 1, false, 1.0, oni.to_world(oni.monster.parts[1].box).grow(-10))
	var leg_loss := before - oni.health
	_check("Ushi-oni: head hidden at rest and open after a charge, charge passes through, shell halves damage",
			hidden_at_rest and head_open_after and pushless_mid_charge and shell_loss == 50 and leg_loss == 100,
			"hidden %s open %s pushless %s shell %d leg %d" % [hidden_at_rest, head_open_after, pushless_mid_charge, shell_loss, leg_loss])


func _test_monster_leg_break_cripples() -> void:
	var oni := Monster.new(Bestiary.by_id(&"ushi_oni"), 4)
	oni.reset(0, -1)
	var hit := MoveDefinition.new()
	hit.damage = 400
	oni.receive(hit, 1, false, 1.0, oni.to_world(oni.monster.parts[1].box).grow(-10))
	var stomp_left := oni.monster.attacks.any(func(a: MonsterDefinition.Attack) -> bool:
		return a.move.id == &"stomp" and not a.requires.any(func(n: String) -> bool: return oni.broken(n)))
	_check("breaking a leg staggers and cripples it, and it can no longer stomp",
			oni.state == Fighter.State.HITSTUN and oni.crippled() and not stomp_left and oni.notice.contains("BROKEN"),
			"state %s crippled %s" % [Fighter.State.keys()[oni.state], oni.crippled()])


func _test_monster_bout_rules() -> void:
	var b := _monster_bout(200.0)
	var oni: Monster = b.fighters[1]
	oni.health = 1
	var throwable := oni.throwable()
	var bindable := def.binds(oni.definition) or Roster.by_id(&"kitsune").binds(oni.definition)
	_run(b, 30, _at({0: [2, "A"]}, 2))
	_check("a monster can't be thrown or bound, and is fought in one round",
			not throwable and not bindable and b.phase == Bout.Phase.BOUT_OVER and b.winner() == 0 and not b.bound,
			"phase %d winner %d" % [b.phase, b.winner()])


func _test_monster_fights_on_its_own() -> void:
	var b := _monster_bout()
	var used := {}
	for n in 2400:
		var intents: Array[Intent] = [Intent.new(), Intent.new()]
		b.fighters[0].health = def.max_health
		b.step(intents)
		var oni: Monster = b.fighters[1]
		if oni.state == Fighter.State.MOVE:
			used[oni.move.id] = true
	_check("left alone, Ushi-oni walks in and uses several of its attacks", used.size() >= 3,
			"used %s" % [used.keys()])


func _test_cpu_drinks_when_safe() -> void:
	# A hurt oni starting far from an idle opponent: how many of eight seeded
	# computers drink before closing in, at the easiest and hardest levels.
	var counts := []
	for level in [0, 3]:
		var drinks := 0
		for seed_number in range(1, 9):
			var b := Bout.new(_r(&"shuten"), def)
			b.fighters[0].position.x = -400
			b.fighters[1].position.x = 400
			b.fighters[0].health = 500
			var cpu := CpuController.new(CpuController.LEVELS[level][1], seed_number)
			for n in 600:
				var f := b.fighters
				var intents: Array[Intent] = [cpu.read(f[0], f[1]), Intent.new()]
				b.step(intents)
				if f[0].state == Fighter.State.MOVE and f[0].move.id == &"sake":
					drinks += 1
					break
		counts.append(drinks)
	_check("the computer drinks its sake when hurt and safe: most of the time, at every difficulty",
			counts[0] >= 4 and counts[1] >= 6, "drank in %d / 8 (Practice) and %d / 8 (Hard)" % counts)


func _test_spirit_recharge_at_least_special() -> void:
	var b := _spirit_bout(SpiritBinding.new(_r(&"shuten"), &"sake"), 600.0)
	_run(b, 20, _at({0: [5, "D"]}))
	_check("a bound spirit recharges no faster than the special it performs",
			b.fighters[0].cooldowns[0] > _r(&"shuten").spirit_cooldown, "cooldown %d" % b.fighters[0].cooldowns[0])


func _test_tournament_engine() -> void:
	var two: Array[FighterDefinition] = [_r(&"musashi"), _r(&"shuten")]
	var t := Tournament.new(two, 3, 1, false, 9)
	while not t.step(1000):
		pass
	var lines := t.report()
	_check("the tournament engine plays every pairing and reports win rates and special use",
			t.bouts_done == 2 and lines.any(func(l: String) -> bool: return l.begins_with("Overall"))
			and lines.any(func(l: String) -> bool: return l.contains("sake")),
			"%d bouts" % t.bouts_done)
