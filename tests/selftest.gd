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
	_test_motion_window_is_per_player()
	_test_escape_while_holding_guard()
	_test_no_sealing_a_held_spirit()
	_test_invincible_takes_no_damage()
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
	var neutral := _move_after(_at({0: [5, "C"]}))
	var down := _move_after(_at({0: [2, "C"]}))
	_check("6C rush, C palm, 2C rising", forward == &"rush" and neutral == &"palm" and down == &"rising",
			"%s / %s / %s" % [forward, neutral, down])


func _test_motion_beats_direction() -> void:
	var id := _move_after(_at({0: [2, ""], 1: [3, ""], 2: [6, "C"]}), 4)
	_check("236C is a projectile, not a rush", id == &"projectile", "got %s" % id)


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


func _test_projectile_travels_and_hits() -> void:
	var b := _bout(400.0)
	_run(b, 90, _at({0: [2, ""], 1: [3, ""], 2: [6, "C"]}))
	_check("projectile crosses the stage and hits",
			_taken(b, 1) == def.moves[&"projectile"].spawn.damage, "took %d" % _taken(b, 1))


func _test_one_projectile_at_a_time() -> void:
	var b := _bout(900.0)
	var most := [0]
	var twice := _at({0: [2, ""], 1: [3, ""], 2: [6, "C"], 40: [2, ""], 41: [3, ""], 42: [6, "C"]})
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

func _spirit_bout(spirit: FighterDefinition, distance: float, summoner: FighterDefinition = def) -> Bout:
	var bound: Array[FighterDefinition] = [spirit]
	var b := Bout.new(summoner, def, bound, [])
	b.fighters[0].position.x = -distance / 2.0
	b.fighters[1].position.x = distance / 2.0
	return b


func _test_spirit_strikes() -> void:
	var heavy := Roster.heavy()
	var b := _spirit_bout(heavy, 150.0)
	_run(b, 50, _at({0: [5, "D"]}))
	_check("a summoned spirit strikes with its own move",
			_taken(b, 1) == heavy.moves[heavy.spirit_move].damage, "took %d" % _taken(b, 1))


func _test_spirit_cooldown() -> void:
	var heavy := Roster.heavy()
	var b := _spirit_bout(heavy, 600.0)
	var seen := {}
	_run(b, 120, _at({0: [5, "D"], 60: [5, "D"]}), null, func(x: Bout) -> void:
		for s in x.spirits:
			seen[s.get_instance_id()] = true)
	_check("a spirit on cooldown cannot be summoned again", seen.size() == 1,
			"summoned %d" % seen.size())


func _test_spirit_with_motion() -> void:
	var balanced := Roster.balanced()
	var b := _spirit_bout(balanced, 200.0, Roster.swift())
	_run(b, 60, _at({0: [5, "D"]}))
	_check("a spirit performing a moving move travels like a fighter",
			_taken(b, 1) == balanced.moves[balanced.spirit_move].damage, "took %d" % _taken(b, 1))


func _test_spirit_releases_projectile_for_summoner() -> void:
	var swift := Roster.swift()
	var b := _spirit_bout(swift, 500.0)
	var owners := {}
	_run(b, 120, _at({0: [5, "D"]}), null, func(x: Bout) -> void:
		for e in x.entities:
			owners[e.owner_index] = true)
	_check("a spirit's projectile belongs to the summoner and hits",
			owners.keys() == [0] and _taken(b, 1) == swift.moves[&"projectile"].spawn.damage,
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
	wide.fighters[0].set_input_timing(6, InputHistory.DEFAULT_MOTION_WINDOW)
	_run(wide, 40, _at({0: [5, "A"], 4: [5, "B"]}))
	_check("presses 4 frames apart: separate by default, together with a wider window",
			_taken(narrow, 1) != _dmg(&"throw") and _taken(wide, 1) == _dmg(&"throw"),
			"default took %d, wide took %d" % [_taken(narrow, 1), _taken(wide, 1)])


func _test_unavailable_spirit_does_not_fall_through() -> void:
	var bound: Array[FighterDefinition] = [Roster.heavy(), Roster.swift()]
	var b := Bout.new(def, def, bound, [])
	b.fighters[0].position.x = -400
	b.fighters[1].position.x = 400
	var sources := {}
	_run(b, 90, _at({0: [2, "D"], 50: [2, "D"]}, 2), null, func(x: Bout) -> void:
		for s in x.spirits:
			sources[s.definition.id] = true)
	_check("down+spirit on cooldown summons nothing, not the other slot",
			sources.keys() == [&"swift"], "summoned %s" % [sources.keys()])


# --- kinds, spirit throws, finishers -----------------------------------------

func _test_kinds_bind_the_other_kind() -> void:
	var human := Roster.balanced()
	var oni := Roster.heavy()
	var fox := Roster.swift()
	_check("humans bind yokai, yokai bind humans, never their own kind",
			human.binds(oni) and oni.binds(human) and not oni.binds(fox) and not human.binds(human))


func _throwing_spirit() -> FighterDefinition:
	var d := Roster.balanced()
	d.spirit_move = &"throw"
	return d


func _test_spirit_throw_can_be_escaped_or_land() -> void:
	var landed := _spirit_bout(_throwing_spirit(), 80.0, Roster.heavy())
	_run(landed, 50, _at({0: [5, "D"]}))
	var escaped := _spirit_bout(_throwing_spirit(), 80.0, Roster.heavy())
	var seen_grab := [false]
	_run(escaped, 50, _at({0: [5, "D"]}), func(n: int) -> Array:
		return [5, "AB" if seen_grab[0] else ""], func(x: Bout) -> void:
			if x.fighters[1].state == Fighter.State.GRABBED:
				seen_grab[0] = true)
	_check("a spirit's throw lands, or can be escaped like any throw",
			_taken(landed, 1) == _dmg(&"throw") and seen_grab[0] and _taken(escaped, 1) == 0,
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
	var b := _beaten(def, Roster.heavy())
	var dazed := b.phase == Bout.Phase.FINISH and b.fighters[1].state == Fighter.State.DAZED
	_run(b, 80, _at({0: [4, ""], 1: [6, "D"]}))
	_check("a beaten foe of the other kind can be sealed by the finisher",
			dazed and b.bound and b.phase == Bout.Phase.BOUT_OVER,
			"dazed %s bound %s phase %d" % [dazed, b.bound, b.phase])


func _test_no_finisher_on_own_kind() -> void:
	var b := _beaten(def, def)
	_check("no finisher against one's own kind", b.phase == Bout.Phase.BOUT_OVER and not b.bound,
			"phase %d" % b.phase)


func _test_finisher_times_out() -> void:
	var b := _beaten(def, Roster.heavy())
	_run(b, Bout.FINISH_FRAMES + 5, _at({}))
	_check("without a finisher the foe collapses and nothing is bound",
			b.phase == Bout.Phase.BOUT_OVER and not b.bound and b.fighters[1].state == Fighter.State.KO,
			"phase %d bound %s" % [b.phase, b.bound])


# --- CPU, run, calibration ---------------------------------------------------

func _test_cpu_enters_motions() -> void:
	var queue := CpuController.inputs_for("236C", 1)
	var b := _bout(300.0)
	var found := [&""]
	for n in 6:
		var i0: Intent = queue[n] if n < queue.size() else Intent.new()
		var intents: Array[Intent] = [i0, Intent.new()]
		b.step(intents)
		if b.fighters[0].move and found[0] == &"":
			found[0] = b.fighters[0].move.id
	_check("the CPU enters command patterns frame by frame", found[0] == &"projectile",
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
			kinds_ok = kinds_ok and run.opponent.binds(s)
		counts_ok = counts_ok and run.opponent_spirits.size() <= Run.SLOTS
		run._draw_opponent()
	var r := Run.new(all[0], all, 3)
	var first := r.win(all[1])
	var second := r.win(all[2])
	var third := r.win(all[1])
	r.choose(0)
	var fights := 0
	while r.advance():
		fights += 1
	_check("opponent spirits follow the kind rule, at most two",
			kinds_ok and counts_ok)
	_check("binding fills free slots, then asks; a run lasts its length",
			not first and not second and third and r.spirits[0] == all[1] and fights == Run.LENGTH - 1,
			"%s %s %s fights %d" % [first, second, third, fights])


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
		_feed(c, [{x = 1}, {x = 1}, {x = 1, special = true}])       # toward held first: never late
	for rep in Calibration.REPS:
		_feed(c, [{spirit = true}, {down = true}])                  # spirit 1 frame before down
	for rep in Calibration.REPS:
		_feed(c, [{down = true}, {down = true, x = 1}] + _repeat({x = 1}, 8) + [{x = 1, special = true}])
	for rep in Calibration.REPS:
		_feed(c, [{light = true}] + _repeat({}, 6) + [{heavy = true}])  # 7 frames apart
	_check("calibration: window maths, and the whole sequence of trials",
			math_ok and c.stage == Calibration.Stage.DONE and c.player == 0
			and c.chord_gaps.max() == 1 and c.sequence_gaps.min() == 7
			and c.chord_window() == 4 and c.motion_window() == 10 + Calibration.MOTION_MARGIN,
			"stage %d gaps %s seq %s spans %s" % [c.stage, c.chord_gaps, c.sequence_gaps, c.motion_spans])


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
	var id := _move_after(_at({0: [2, ""], 1: [6, "C"]}), 3)
	_check("down then toward + special, skipping the diagonal, is still the projectile",
			id == &"projectile", "got %s" % id)


func _slow_roll(b: Bout) -> StringName:
	var script := _at({0: [2, ""], 1: [3, ""], 24: [6, "C"]}, 3)
	var id := [&""]
	_run(b, 26, script, null, func(x: Bout) -> void:
		if x.fighters[0].move and id[0] == &"":
			id[0] = x.fighters[0].move.id)
	return id[0]


func _test_motion_window_is_per_player() -> void:
	var default := _slow_roll(_bout(300.0))
	var patient := _bout(300.0)
	patient.fighters[0].set_input_timing(InputHistory.DEFAULT_CHORD, 30)
	var wide := _slow_roll(patient)
	_check("a slow roll is a projectile only with a wider roll window",
			default != &"projectile" and wide == &"projectile", "default %s, wide %s" % [default, wide])


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
	var bound: Array[FighterDefinition] = [Roster.heavy()]
	var b := Bout.new(def, Roster.heavy(), bound, [])
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
