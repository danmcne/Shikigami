extends SceneTree
## Mechanics self-test. Not part of the game; run it explicitly:
##   godot --headless --path . --script res://tests/selftest.gd
## It checks that rules behave as specified. It says nothing about whether
## the game feels good.

const PrototypeRect := preload("res://game/fighters/prototype_rect.gd")

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
	print("selftest: %s" % ("all passed" if failures == 0 else "%d failed" % failures))
	quit(1 if failures > 0 else 0)


# --- helpers ---------------------------------------------------------------

func _bout(distance := 100.0) -> Bout:
	var b := Bout.new(def, def)
	b.fighters[0].position.x = -distance / 2.0
	b.fighters[1].position.x = distance / 2.0
	return b


## An Intent from numpad notation relative to `f`'s facing, plus buttons "ABCD".
func _in(f: Fighter, n: int, buttons := "") -> Intent:
	var i := Intent.new()
	i.x = ((n - 1) % 3 - 1) * f.facing
	i.up = n >= 7
	i.down = n <= 3
	i.light = "A" in buttons
	i.heavy = "B" in buttons
	i.special = "C" in buttons
	i.spirit = "D" in buttons
	return i


## A script: frame -> [numpad, buttons], holding `hold` on unlisted frames.
func _at(events: Dictionary, hold := 5) -> Callable:
	return func(n: int) -> Array: return events.get(n, [hold, ""])


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
	_run(b, 40, _at({0: [5, "B"]}), DummyController.new(DummyController.Mode.GUARD),
			func(x: Bout) -> void: seen[x.fighters[1].state] = true)
	_check("standing guard stops a mid attack",
			_taken(b, 1) == 0 and Fighter.State.BLOCKSTUN in seen, "took %d" % _taken(b, 1))


func _test_low_beats_standing_guard() -> void:
	var b := _bout()
	_run(b, 40, _at({0: [2, "A"]}, 2), DummyController.new(DummyController.Mode.GUARD))
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
	_run(b, 40, _at({0: [5, "A"]}), DummyController.new(DummyController.Mode.GUARD))
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
	_run(b, 30, _at({0: [5, "AB"]}), DummyController.new(DummyController.Mode.GUARD),
			func(x: Bout) -> void: seen[x.fighters[1].state] = true)
	_check("throw beats a standing guard",
			_taken(b, 1) == _dmg(&"throw") and Fighter.State.KNOCKDOWN in seen,
			"took %d" % _taken(b, 1))


func _test_back_throw_swaps_sides() -> void:
	var b := _bout(70.0)
	_run(b, 12, _at({0: [4, "AB"]}, 4))
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
