extends SceneTree
## Mechanics self-test. Not part of the game; run it explicitly:
##   godot --headless --path . --script res://tests/selftest.gd
## It checks that rules behave as specified (guards, heights, trades, KO,
## pushboxes). It says nothing about whether the game feels good.

const PrototypeRect := preload("res://game/fighters/prototype_rect.gd")

var failures := 0


func _init() -> void:
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
	print("selftest: %s" % ("all passed" if failures == 0 else "%d failed" % failures))
	quit(1 if failures > 0 else 0)


# --- helpers ---------------------------------------------------------------

func _bout(distance := 100.0) -> Bout:
	var d := PrototypeRect.definition()
	var b := Bout.new(d, d)
	b.fighters[0].position.x = -distance / 2.0
	b.fighters[1].position.x = distance / 2.0
	return b


## Player 0 presses `button` on frame 0 (holding down if `crouch`); player 1 is
## driven by `defender`. Runs `frames` frames.
func _attack_run(b: Bout, button: String, defender: Object, crouch := false, frames := 40) -> Array:
	var seen: Array = []
	for n in frames:
		var i0 := Intent.new()
		i0.down = crouch
		i0.light = n == 0 and button == "light"
		i0.heavy = n == 0 and button == "heavy"
		var i1: Intent = defender.read(b.fighters[1], b.fighters[0]) if defender else Intent.new()
		var intents: Array[Intent] = [i0, i1]
		b.step(intents)
		seen.append(b.fighters[1].state)
	return seen


func _damage_taken(b: Bout, i: int) -> int:
	return b.fighters[i].definition.max_health - b.fighters[i].health


func _dmg(key: StringName) -> int:
	return PrototypeRect.definition().attacks[key].damage


func _check(name: String, ok: bool, detail := "") -> void:
	if ok:
		print("  pass  ", name)
	else:
		failures += 1
		print("  FAIL  ", name, "  ", detail)


# --- tests -----------------------------------------------------------------

func _test_light_hits_standing() -> void:
	var b := _bout()
	_attack_run(b, "light", null)
	_check("standing light hits a standing opponent",
			_damage_taken(b, 1) == _dmg(&"stand_light"), "took %d" % _damage_taken(b, 1))


func _test_light_whiffs_over_crouch() -> void:
	var b := _bout()
	_attack_run(b, "light", DummyController.new(DummyController.Mode.CROUCH))
	_check("standing light whiffs over a crouch", _damage_taken(b, 1) == 0,
			"took %d" % _damage_taken(b, 1))


func _test_standing_guard_stops_mid() -> void:
	var b := _bout()
	var seen := _attack_run(b, "heavy", DummyController.new(DummyController.Mode.GUARD))
	_check("standing guard stops a mid attack",
			_damage_taken(b, 1) == 0 and Fighter.State.BLOCKSTUN in seen,
			"took %d, blockstun seen: %s" % [_damage_taken(b, 1), Fighter.State.BLOCKSTUN in seen])


func _test_low_beats_standing_guard() -> void:
	var b := _bout()
	_attack_run(b, "light", DummyController.new(DummyController.Mode.GUARD), true)
	_check("low attack beats a standing guard",
			_damage_taken(b, 1) == _dmg(&"crouch_light"), "took %d" % _damage_taken(b, 1))


func _test_crouching_guard_stops_low() -> void:
	var b := _bout()
	_attack_run(b, "light", DummyController.new(DummyController.Mode.CROUCH_GUARD), true)
	_check("crouching guard stops a low attack", _damage_taken(b, 1) == 0,
			"took %d" % _damage_taken(b, 1))


func _airborne_attacker(b: Bout) -> void:
	var a := b.fighters[0]
	a.position = Vector2(-40, -60)
	a.airborne = true
	a.velocity = Vector2.ZERO
	a.state = Fighter.State.JUMP


func _test_high_beats_crouching_guard() -> void:
	var b := _bout()
	_airborne_attacker(b)
	_attack_run(b, "light", DummyController.new(DummyController.Mode.CROUCH_GUARD))
	_check("jumping attack beats a crouching guard",
			_damage_taken(b, 1) == _dmg(&"jump_light"), "took %d" % _damage_taken(b, 1))


func _test_standing_guard_stops_high() -> void:
	var b := _bout()
	_airborne_attacker(b)
	var seen := _attack_run(b, "light", DummyController.new(DummyController.Mode.GUARD))
	_check("standing guard stops a jumping attack",
			_damage_taken(b, 1) == 0 and Fighter.State.BLOCKSTUN in seen,
			"took %d" % _damage_taken(b, 1))


func _test_simultaneous_hits_trade() -> void:
	var b := _bout()
	for n in 30:
		var i0 := Intent.new()
		var i1 := Intent.new()
		i0.light = n == 0
		i1.light = n == 0
		var intents: Array[Intent] = [i0, i1]
		b.step(intents)
	var dmg := _dmg(&"stand_light")
	_check("simultaneous hits trade",
			_damage_taken(b, 0) == dmg and _damage_taken(b, 1) == dmg,
			"took %d / %d" % [_damage_taken(b, 0), _damage_taken(b, 1)])


func _test_ko_ends_round_and_next_round_resets() -> void:
	var b := _bout()
	b.fighters[1].health = 10
	_attack_run(b, "light", null, false, 20)
	var ended := b.phase == Bout.Phase.ROUND_OVER and b.wins[0] == 1 and b.round_winner == 0
	_attack_run(b, "", null, false, Bout.ROUND_OVER_FRAMES + 1)
	var reset := b.phase == Bout.Phase.FIGHT and b.round_number == 2 \
			and b.fighters[1].health == b.fighters[1].definition.max_health
	_check("KO ends the round and awards it", ended,
			"phase %d wins %s" % [b.phase, b.wins])
	_check("next round starts at full health", reset,
			"phase %d round %d" % [b.phase, b.round_number])


func _test_pushboxes_never_overlap() -> void:
	var b := _bout(300.0)
	var overlapped := false
	for n in 240:
		var i0 := Intent.new()
		var i1 := Intent.new()
		i0.x = 1
		i1.x = -1
		# Player 0 also jumps now and then, to test landing on top of player 1.
		i0.up = n % 60 == 0
		var intents: Array[Intent] = [i0, i1]
		b.step(intents)
		var a := b.fighters[0].pushbox()
		var c := b.fighters[1].pushbox()
		if a.intersects(c) and a.intersection(c).size.x > 0.01:
			overlapped = true
	_check("pushboxes never overlap", not overlapped)
