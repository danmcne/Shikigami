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
	print("climbing and turning")
	_test_climb_onto_ushi_oni()
	_test_every_fighter_reaches_the_head()
	_test_ride_strike_and_drop_behind()
	_test_riders_are_carried()
	_test_buck_throws_riders_off()
	_test_ushi_oni_turns_slowly()
	_test_teleport_lands_behind_a_monster()
	print("monster pace, Gashadokuro")
	_test_monster_pace_follows_difficulty()
	_test_gashadokuro_hands_open_after_slams()
	_test_gashadokuro_hands_converge_from_half_a_stage()
	_test_gashadokuro_grab_unguarded()
	_test_gashadokuro_grab_guarded_and_escaped()
	_test_gashadokuro_clap_into_the_other_hand()
	_test_free_facing_turns_by_input()
	_test_circular_arena()
	_test_bone_rain_wider_when_easier()
	_test_gashadokuro_rain_has_gaps()
	_test_gashadokuro_broken_hand()
	_test_gashadokuro_has_no_body()
	print("monster pace, Nue")
	_test_monster_windup_and_speed_follow_difficulty()
	_test_bone_rain_before_any_break()
	_test_nue_flies_out_of_jump_reach()
	_test_nue_lightning_marks_then_strikes()
	_test_nue_dives_and_lies_open()
	_test_nue_grounded_when_cloud_breaks()
	print("v12: circular arenas, riding Nue, the run, Rokurokubi")
	_test_all_giants_fought_in_circles()
	_test_ride_nue_into_the_air()
	_test_nue_thrashes_riders_off()
	_test_run_never_repeats()
	_test_rokurokubi_long_neck()
	_test_rokurokubi_head_is_vulnerable()
	_test_lantern_leaves_fire()
	_test_drying_pole_wounds_only_with_its_tip()
	_test_swing_traces_an_arc()
	_test_weapon_tip_wounds_hardest()
	_test_effects_land_with_the_animation()
	_test_rig_side_view_layers()
	_test_rig_diagonal_view_layers()
	_test_rig_front_view_layers()
	_test_rig_reaches_a_point()
	_test_every_fighter_has_a_sound_rig()
	_test_props_appear_when_reached()
	_test_joints_stay_within_limits()
	_test_two_handed_grip()
	_test_kojiro_strikes_with_his_blade()
	_test_water_jet_from_the_head()
	_test_icicle_falls_over_the_opponent()
	_test_pieces_have_pictures()
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


func _kappa_bout(distance: float) -> Bout:
	var b := Bout.new(Roster.by_id(&"kappa"), def)
	b.fighters[0].position.x = -distance / 2.0
	b.fighters[1].position.x = distance / 2.0
	return b


func _test_projectile_travels_and_hits() -> void:
	var b := _kappa_bout(400.0)
	_run(b, 90, _at({0: [4, "C"]}))
	var jet: MoveDefinition = Roster.by_id(&"kappa").moves[&"water_jet"].spawn
	_check("the kappa's water jet crosses the stage and hits, in the air or as the wave it leaves",
			_taken(b, 1) in [jet.damage, jet.leaves.damage], "took %d" % _taken(b, 1))


func _test_one_projectile_at_a_time() -> void:
	var b := _kappa_bout(900.0)
	var most := [0]
	var twice := _at({0: [4, "C"], 65: [4, "C"]})  # after its recharge, while the first is in flight
	_run(b, 100, twice, null, func(x: Bout) -> void: most[0] = maxi(most[0], x.entities.size()))
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
	var kappa := _r(&"kappa")
	var b := _spirit_bout(SpiritBinding.new(kappa, &"water_jet"), 500.0)
	var owners := {}
	_run(b, 120, _at({0: [5, "D"]}), null, func(x: Bout) -> void:
		for e in x.entities:
			owners[e.owner_index] = true)
	_check("a spirit's projectile belongs to the summoner and hits",
			owners.keys() == [0] and _taken(b, 1) in [kappa.moves[&"water_jet"].spawn.damage, kappa.moves[&"water_jet"].spawn.leaves.damage],
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
			SpiritBinding.new(_r(&"kappa"), &"water_jet")]
	var b := Bout.new(def, def, bound, [])
	b.fighters[0].position.x = -400
	b.fighters[1].position.x = 400
	var sources := {}
	_run(b, 90, _at({0: [2, "D"], 50: [2, "D"]}, 2), null, func(x: Bout) -> void:
		for s in x.spirits:
			sources[s.definition.id] = true)
	_check("down+spirit on cooldown summons nothing, not the other slot",
			sources.keys() == [&"kappa"], "summoned %s" % [sources.keys()])


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
	var carrying: Array[SpiritBinding] = [SpiritBinding.new(_r(&"kappa"), &"water_jet")]
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
	# Health resets between rounds, so record every hit as it lands.
	var landed := [0, 0]
	var last := [b.fighters[0].health, b.fighters[1].health]
	for n in 3000:
		var f := b.fighters
		var intents: Array[Intent] = [cpus[0].read(f[0], f[1]), cpus[1].read(f[1], f[0])]
		b.step(intents)
		for i in 2:
			if f[i].health < last[i]:
				landed[1 - i] += 1
			last[i] = f[i].health
	_check("two Hard computers fight each other and both land hits",
			landed[0] > 0 and landed[1] > 0, "hits landed %s" % [landed])


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
	# A beaten giant must be sealed: missing the seal brings it back; landing it ends the fight.
	var missed := _monster_bout(200.0)
	var oni: Monster = missed.fighters[1]
	oni.health = 1
	var throwable := oni.throwable()
	var bindable := def.binds(oni.definition) or Roster.by_id(&"kitsune").binds(oni.definition)
	_run(missed, 30, _at({0: [2, "A"]}, 2))
	var must_seal := missed.phase == Bout.Phase.FINISH and oni.state == Fighter.State.DAZED
	_run(missed, missed.finish_frames + 5, _at({}))
	var reformed := missed.phase == Bout.Phase.FIGHT and oni.health == roundi(oni.definition.max_health * oni.monster.reform_fraction)
	var sealed := _monster_bout(200.0)
	(sealed.fighters[1] as Monster).health = 1
	_run(sealed, 30, _at({0: [2, "A"]}, 2))
	_run(sealed, 80, _at({0: [4, ""], 1: [6, "D"]}))
	_check("a monster can't be thrown or bound; beaten, it must be sealed, or its core reforms",
			not throwable and not bindable and must_seal and reformed and sealed.phase == Bout.Phase.BOUT_OVER
			and sealed.winner() == 0,
			"seal %s reformed %s sealed phase %d" % [must_seal, reformed, sealed.phase])


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


# --- climbing and turning ----------------------------------------------------

## A fighter against Ushi-oni, the monster at x = 200 facing left.
func _oni_setup(fighter: FighterDefinition = def) -> Bout:
	var b := Bout.versus_monster(fighter, [], Monster.new(Bestiary.by_id(&"ushi_oni"), 6))
	b.fighters[1].position.x = 200
	b.fighters[1].facing = -1
	return b


func _test_climb_onto_ushi_oni() -> void:
	var b := _oni_setup()
	var f := b.fighters[0]
	var oni: Monster = b.fighters[1]
	oni.health = 99999
	_airborne(f, Vector2(-10, -200))
	_run(b, 30, _at({}))
	var on_head := not f.airborne and is_equal_approx(f.position.y, -130.0)
	_run(b, 60, _at({0: [9, ""]}))
	var on_back := not f.airborne and is_equal_approx(f.position.y, -210.0)
	_check("a fighter can jump onto Ushi-oni's head, and from there onto its back",
			on_head and on_back, "head %s back %s at y %.0f" % [on_head, on_back, f.position.y])


func _test_every_fighter_reaches_the_head() -> void:
	var head_top := 130.0
	var short := []
	for d in Roster.all():
		if d.jump_velocity * d.jump_velocity / (2.0 * d.gravity) < head_top + 10.0:
			short.append(d.display_name)
	_check("every fighter's jump clears Ushi-oni's head", short.is_empty(), "too short: %s" % [short])


func _rider() -> Bout:
	var b := _oni_setup()
	var f := b.fighters[0]
	(b.fighters[1] as Monster).health = 99999
	_airborne(f, Vector2(200, -260))
	_run(b, 20, _at({}))
	return b


func _test_ride_strike_and_drop_behind() -> void:
	var b := _rider()
	var f := b.fighters[0]
	var oni: Monster = b.fighters[1]
	var riding := f.on_raised_ground() and oni.ridden
	var before := oni.health
	_run(b, 20, _at({0: [5, "A"]}))
	var struck := before - oni.health == roundi(_dmg(&"stand_light") * 0.5)
	# Walk off the back (away from the head, to the right) and land behind it,
	# with the monster kept from acting (bucking is tested separately).
	oni._rest = 100000
	_run(b, 80, func(n: int) -> Array: return [6 if f.facing == 1 else 4, ""])
	var behind := not f.airborne and f.position.y == 0.0 and f.position.x > oni.position.x
	_check("riding it, striking the shell from above, and dropping off behind",
			riding and struck and behind,
			"riding %s struck %s behind %s (x %.0f vs %.0f)" % [riding, struck, behind, f.position.x, oni.position.x])


func _test_riders_are_carried() -> void:
	var b := _rider()
	var f := b.fighters[0]
	var oni: Monster = b.fighters[1]
	var charge: MonsterDefinition.Attack = oni.monster.attacks.filter(
			func(a: MonsterDefinition.Attack) -> bool: return a.move.id == &"charge")[0]
	oni.attack = charge
	oni._begin(charge.move)
	var gap_before := f.position.x - oni.position.x
	var moved := oni.position.x
	_run(b, 50, _at({}))
	moved = absf(oni.position.x - moved)
	_check("a rider is carried when the monster charges",
			moved > 100.0 and absf((f.position.x - oni.position.x) - gap_before) < 1.0 and f.on_raised_ground(),
			"monster moved %.0f, rider offset changed by %.1f" % [moved, (f.position.x - oni.position.x) - gap_before])


func _test_buck_throws_riders_off() -> void:
	var b := _rider()
	var f := b.fighters[0]
	var thrown := [false]
	_run(b, 400, _at({}), null, func(x: Bout) -> void:
		if not x.fighters[0].on_raised_ground() and x.fighters[0].state in [Fighter.State.KNOCKDOWN, Fighter.State.HITSTUN]:
			thrown[0] = true)
	_check("Ushi-oni bucks a rider off its back", thrown[0] and not f.on_raised_ground())


func _test_ushi_oni_turns_slowly() -> void:
	var b := _oni_setup()
	var oni: Monster = b.fighters[1]
	oni.health = 99999
	b.fighters[0].position.x = 520
	b.fighters[0].invincible = true
	var turned_at := [-1]
	_run(b, 300, _at({}, 2, "G"), null, func(x: Bout) -> void:
		if turned_at[0] < 0 and (x.fighters[1] as Monster).facing == 1:
			turned_at[0] = x.phase_frame)
	_check("with you behind it, Ushi-oni turns, but only after its turn delay",
			turned_at[0] >= oni.monster.turn_delay, "turned at frame %d" % turned_at[0])


func _test_teleport_lands_behind_a_monster() -> void:
	var b := _oni_setup(_r(&"kitsune"))
	(b.fighters[1] as Monster).health = 99999
	b.fighters[0].position.x = -250
	_run(b, 30, _at({0: [5, "C"]}))
	var oni: Monster = b.fighters[1]
	var far_edge := oni.position.x + oni.definition.pushbox.size.x / 2.0
	_check("Fox Step reappears beyond the far side of a monster, not inside it",
			b.fighters[0].position.x > far_edge, "at %.0f, far edge %.0f" % [b.fighters[0].position.x, far_edge])


# --- monster pace, Gashadokuro ------------------------------------------------

func _turn_frame(level: int) -> int:
	var b := Bout.versus_monster(def, [], Monster.new(Bestiary.by_id(&"ushi_oni"), 6, CpuController.LEVELS[level][1]))
	b.fighters[1].position.x = 200
	b.fighters[1].facing = -1
	(b.fighters[1] as Monster).health = 99999
	b.fighters[0].position.x = 520
	b.fighters[0].invincible = true
	var turned := [-1]
	_run(b, 600, _at({}), null, func(x: Bout) -> void:
		if turned[0] < 0 and (x.fighters[1] as Monster).facing == 1:
			turned[0] = x.phase_frame)
	return turned[0]


func _test_monster_pace_follows_difficulty() -> void:
	var practice := _turn_frame(0)
	var easy := _turn_frame(1)
	var hard := _turn_frame(3)
	_check("monsters turn more slowly on easier difficulties",
			practice > easy and easy > hard and practice >= 180, "Practice %d, Easy %d, Hard %d" % [practice, easy, hard])


func _gasha_bout(distance := 200.0) -> Bout:
	# The fighter on the left, the skeleton on the right: the fighter stands
	# under its left hand when they are 200 apart.
	var b := Bout.versus_monster(def, [], Monster.new(Bestiary.by_id(&"gashadokuro"), 8))
	b.fighters[0].position.x = -distance / 2.0
	b.fighters[1].position.x = distance / 2.0
	(b.fighters[1] as Monster)._rest = 100000
	return b


func _gasha_perform(g: Monster, id: StringName) -> MonsterDefinition.Attack:
	var a: MonsterDefinition.Attack = g.monster.attacks.filter(
			func(x: MonsterDefinition.Attack) -> bool: return x.move.id == id)[0]
	g.attack = a
	g._begin(a.move)
	return a


func _test_gashadokuro_hands_open_after_slams() -> void:
	var b := _gasha_bout(200.0)
	var g: Monster = b.fighters[1]
	var nothing_at_rest := g.hurtboxes().is_empty()
	var slam := _gasha_perform(g, &"left_slam")
	var open_during_recovery := false
	var open_before := false
	for n in slam.move.total_frames():
		var intents: Array[Intent] = [Intent.new(), Intent.new()]
		b.step(intents)
		var open := not g.hurtboxes().is_empty()
		if open and g.state_frame < slam.move.startup + slam.move.active:
			open_before = true
		if open:
			open_during_recovery = true
	_check("Gashadokuro: nothing to strike at rest; its left hand slams whoever is under it, then lies open",
			nothing_at_rest and open_during_recovery and not open_before and _taken(b, 0) == slam.move.damage
			and g.facing == 1,
			"rest %s open %s early %s took %d" % [nothing_at_rest, open_during_recovery, open_before, _taken(b, 0)])


## Damage taken by a fighter at `x`, holding `script`, from one Gashadokuro attack.
func _gasha_case(id: StringName, x: float, hold: int, held: String) -> int:
	var b := Bout.versus_monster(def, [], Monster.new(Bestiary.by_id(&"gashadokuro"), 8))
	b.fighters[0].position.x = x
	b.fighters[1].position.x = 0
	(b.fighters[1] as Monster)._rest = 100000
	_gasha_perform(b.fighters[1], id)
	_run(b, 140, _at({}, hold, held))
	return _taken(b, 0)


func _test_gashadokuro_rain_has_gaps() -> void:
	var b := _gasha_bout(200.0)
	_gasha_perform(b.fighters[1], &"bone_rain")
	_run(b, 34, _at({}))
	var boxes := []
	var heights := {}
	for e in b.entities:
		boxes.append(e.active_hitboxes()[0])
		heights[roundi(e.position.y)] = true
	boxes.sort_custom(func(p: Rect2, q: Rect2) -> bool: return p.position.x < q.position.x)
	var fighter_width: float = def.stand_hurtbox.size.x
	var gaps_ok := boxes.size() == 3
	for k in boxes.size() - 1:
		var gap: float = boxes[k + 1].position.x - boxes[k].end.x
		gaps_ok = gaps_ok and gap >= fighter_width and gap <= fighter_width + 20.0
	_check("bone rain: three bones at different heights, with gaps just wide enough to stand in",
			gaps_ok and heights.size() == 3, "%d bones, %d heights" % [boxes.size(), heights.size()])


func _test_gashadokuro_broken_hand() -> void:
	var b := _gasha_bout(200.0)
	var g: Monster = b.fighters[1]
	g._rest = 10
	g.health = 99999
	b.fighters[0].invincible = true
	g.part_health[1] = 0  # the right hand broken; the fighter stays on its left
	var used := {}
	_run(b, 2500, _at({}), null, func(x: Bout) -> void:
		var m: Monster = x.fighters[1]
		if m.state == Fighter.State.MOVE:
			used[m.move.id] = true)
	var no_clap := not used.has(&"high_clap") and not used.has(&"low_clap")
	var no_right := not used.has(&"right_slam") and not used.has(&"right_grab")
	_check("with its right hand broken: no claps and nothing from that hand, but the left still grabs; bones rain",
			no_clap and no_right and used.has(&"left_grab") and used.has(&"bone_rain"), "used %s" % [used.keys()])


func _test_gashadokuro_has_no_body() -> void:
	var b := _gasha_bout(100.0)
	var w := b.fighters[0]
	_run(b, 60, func(n: int) -> Array: return [6 if w.facing == 1 else 4, ""])
	_check("you can walk straight beneath Gashadokuro", w.position.x > b.fighters[1].position.x + 50.0,
			"walker at %.0f, skeleton at %.0f" % [w.position.x, b.fighters[1].position.x])


# --- Gashadokuro 10.2: grabs, claps, free facing, the circular arena ----------

## A fighter at `x` facing `face`, Gashadokuro at 0 with one attack begun.
func _gasha_scene(id: StringName, x: float, face: int, fighter: FighterDefinition = def) -> Bout:
	var b := Bout.versus_monster(fighter, [], Monster.new(Bestiary.by_id(&"gashadokuro"), 8))
	b.fighters[0].position.x = x
	b.fighters[0].facing = face
	b.fighters[1].position.x = 0
	(b.fighters[1] as Monster).health = 99999
	(b.fighters[1] as Monster)._rest = 100000
	if id != &"":
		_gasha_perform(b.fighters[1], id)
	return b


func _test_gashadokuro_hands_converge_from_half_a_stage() -> void:
	var b := _gasha_scene(&"high_clap", -300, 1)
	var starts := []
	var ends := []
	_run(b, 40, _at({}), null, func(x: Bout) -> void:
		for e in x.entities:
			if starts.size() < 2 and not e.position.x in starts:
				starts.append(e.position.x))
	_run(b, 80, _at({}), null, func(x: Bout) -> void:
		ends = x.entities.map(func(e: Entity) -> float: return e.position.x))
	starts.sort()
	_check("its hands start half a stage from its centreline and meet beneath it",
			starts == [-600.0, 600.0] and ends.all(func(v: float) -> bool: return is_equal_approx(v, 0.0)),
			"start %s end %s" % [starts, ends])


func _test_gashadokuro_grab_unguarded() -> void:
	var b := _gasha_scene(&"left_grab", -300, 1)  # facing the skeleton, the hand comes from behind
	var seized := [false]
	_run(b, 240, _at({}, 5, "G"), null, func(x: Bout) -> void:
		if x.fighters[0].state == Fighter.State.GRABBED:
			seized[0] = true)
	var g: Monster = b.fighters[1]
	var expected: int = g.monster.attacks.filter(func(a: MonsterDefinition.Attack) -> bool:
		return a.move.id == &"left_grab")[0].move.spawn.damage + g.monster.attacks.filter(
		func(a: MonsterDefinition.Attack) -> bool: return a.move.id == &"left_grab")[0].follow_up.move.damage
	_check("a grab from behind ignores your guard: you are carried beneath the skull and chewed",
			seized[0] and _taken(b, 0) == expected, "seized %s took %d (want %d)" % [seized[0], _taken(b, 0), expected])


func _test_gashadokuro_grab_guarded_and_escaped() -> void:
	var b := _gasha_scene(&"left_grab", -300, -1)  # facing the incoming hand
	var f := b.fighters[0]
	var pushed_to := [INF]
	var released := [false]
	_run(b, 240, func(n: int) -> Array:
		# Guard until the hand stops, then walk right out from under the skull.
		if not released[0]:
			return [5, "G"]
		return [6 if f.facing == 1 else 4, ""], null, func(x: Bout) -> void:
			for e in x.entities:
				if e.arrived and not released[0]:
					released[0] = true
					pushed_to[0] = x.fighters[0].position.x)
	_check("guarding a grab, facing it: pushed unhurt beneath the skull, then free to escape the jaws",
			released[0] and absf(pushed_to[0]) < 120.0 and _taken(b, 0) == 0,
			"pushed to %.0f, took %d" % [pushed_to[0], _taken(b, 0)])


func _test_gashadokuro_clap_into_the_other_hand() -> void:
	var guarded := _gasha_scene(&"low_clap", -300, -1)  # facing the left hand, guarding low
	_run(guarded, 140, _at({}, 2, "G"))
	var crouched := _gasha_scene(&"high_clap", -300, -1)
	_run(crouched, 140, _at({}, 2, ""))
	_check("guarding one clapping hand pushes you into the other, which strikes your back; crouch under the high clap",
			_taken(guarded, 0) > 0 and _taken(crouched, 0) == 0,
			"guarded took %d, crouched took %d" % [_taken(guarded, 0), _taken(crouched, 0)])


func _test_free_facing_turns_by_input() -> void:
	var musashi := _r(&"musashi")
	# Walking past it, you keep facing the way you face.
	var past := _gasha_scene(&"", -200, 1)
	var walker := past.fighters[0]
	_run(past, 120, _at({}, 6))
	var kept := walker.facing == 1 and walker.position.x > 0.0
	# Double tap back: still the backdash, without turning.
	var tap := _gasha_scene(&"", -200, 1)
	var start_x := tap.fighters[0].position.x
	var dashed := [false]
	_run(tap, 6, _at({0: [4, ""], 1: [4, ""], 2: [5, ""], 3: [4, ""]}, 5), null, func(x: Bout) -> void:
		var m := x.fighters[0].move
		if m and m.id == &"dash_back":
			dashed[0] = true)
	var turned_in_place: bool = dashed[0] and tap.fighters[0].facing == 1
	# Hold back: turn and run that way.
	var hold := _gasha_scene(&"", -200, 1)
	var holder := hold.fighters[0]
	_run(hold, 40, func(n: int) -> Array: return [4 if holder.facing == 1 else 6, ""])  # screen left, held
	var turned_and_ran := hold.fighters[0].facing == -1 and hold.fighters[0].position.x < start_x - 60.0
	# A quick back + special is still the away special.
	var quick := _gasha_scene(&"", -200, 1, musashi)
	_run(quick, 3, _at({0: [4, "C"]}, 5))
	var m := quick.fighters[0].move
	var special_ok := m != null and m.id == &"void_stance" and quick.fighters[0].facing == 1
	_check("free facing: no turning to face it; holding back turns and runs; the backdash and back + special still work",
			kept and turned_in_place and turned_and_ran and special_ok,
			"kept %s tap %s hold %s special %s" % [kept, turned_in_place, turned_and_ran, special_ok])


func _test_circular_arena() -> void:
	var b := _gasha_scene(&"", 0, 1)
	b.fighters[1].position.x = 2000  # further than half the circle: it is really 400 to the left
	_run(b, 1, _at({}))
	var wrapped := absf(b.fighters[1].position.x + 400.0) < 5.0  # allowing for its own drift
	b.fighters[0].position.x = 2500
	b.fighters[1].position.x = 2300
	_run(b, 1, _at({}))
	var relapped := absf(b.fighters[0].position.x - 100.0) < 1.0 and absf(b.fighters[1].position.x + 100.0) < 3.0
	_check("in its circular arena, positions keep the shortest way round, and the lap resets",
			wrapped and relapped, "wrapped %s (%.0f), relapped %s (%.0f, %.0f)" % [wrapped,
					b.fighters[1].position.x, relapped, b.fighters[0].position.x, b.fighters[1].position.x])


func _test_bone_rain_wider_when_easier() -> void:
	var gaps := []
	for level in [0, 2]:
		var b := Bout.versus_monster(def, [], Monster.new(Bestiary.by_id(&"gashadokuro"), 8, CpuController.LEVELS[level][1]))
		(b.fighters[1] as Monster)._rest = 100000
		_gasha_perform(b.fighters[1], &"bone_rain")
		_run(b, 34, _at({}))
		var xs := b.entities.map(func(e: Entity) -> float: return e.position.x)
		xs.sort()
		gaps.append(xs[1] - xs[0])
	_check("bone rain spreads wider on Practice than on Normal", gaps[0] > gaps[1], "spacing %s" % [gaps])


# --- monster pace, Nue -------------------------------------------------------

func _test_monster_windup_and_speed_follow_difficulty() -> void:
	var timings := []
	for level in [0, 2]:
		var m := Monster.new(Bestiary.by_id(&"gashadokuro"), 1, CpuController.LEVELS[level][1])
		var grab: MonsterDefinition.Attack = m.monster.attacks.filter(
				func(a: MonsterDefinition.Attack) -> bool: return a.move.id == &"left_grab")[0]
		var played := m.paced(grab.move)
		timings.append([played.startup, played.spawn.motion.x])
	_check("on easier settings a monster's attacks wind up longer and travel slower",
			timings[0][0] > timings[1][0] and timings[0][1] < timings[1][1], "Practice %s, Normal %s" % timings)


func _test_bone_rain_before_any_break() -> void:
	var b := _gasha_bout(200.0)
	var g: Monster = b.fighters[1]
	g._rest = 10
	g.health = 99999
	b.fighters[0].invincible = true
	var rained := [false]
	_run(b, 4000, _at({}), null, func(x: Bout) -> void:
		var m: Monster = x.fighters[1]
		if m.state == Fighter.State.MOVE and m.move.id == &"bone_rain":
			rained[0] = true)
	_check("bone rain appears now and then even with both hands whole", rained[0] and not g.crippled())


func _nue_bout(distance := 300.0) -> Bout:
	var b := Bout.versus_monster(def, [], Monster.new(Bestiary.by_id(&"nue"), 4))
	b.fighters[0].position.x = -distance / 2.0
	b.fighters[1].position.x = distance / 2.0
	return b


func _test_nue_flies_out_of_jump_reach() -> void:
	var b := _nue_bout(120.0)
	var nue: Monster = b.fighters[1]
	nue._rest = 100000
	nue.health = 99999
	var height := -nue.position.y
	# A jumping heavy at the top of the jump, under it.
	var jumped := _nue_bout(120.0)
	var jn: Monster = jumped.fighters[1]
	jn._rest = 100000
	jn.health = 99999
	_run(jumped, 60, _at({0: [8, ""], 9: [8, "B"]}, 5))
	var jump_hurt := 99999 - jn.health
	# The shared rising anti-air.
	var rose := _nue_bout(120.0)
	var rn: Monster = rose.fighters[1]
	rn._rest = 100000
	rn.health = 99999
	_run(rose, 60, _at({0: [2, "C"]}, 2))
	var rise_hurt := 99999 - rn.health
	_check("Nue flies above a jump's reach, but a rising anti-air reaches it",
			is_equal_approx(height, nue.monster.altitude) and jump_hurt == 0 and rise_hurt > 0,
			"height %.0f; jump did %d, rising did %d" % [height, jump_hurt, rise_hurt])


func _test_nue_lightning_marks_then_strikes() -> void:
	var b := _nue_bout(300.0)
	var nue: Monster = b.fighters[1]
	nue._rest = 100000
	var l: MonsterDefinition.Attack = nue.monster.attacks.filter(
			func(a: MonsterDefinition.Attack) -> bool: return a.move.id == &"lightning")[0]
	nue.attack = l
	nue._begin(l.move)
	var bolts := [0]
	var hurt_before_bolt := [false]
	_run(b, 30, _at({}), null, func(x: Bout) -> void:
		bolts[0] = maxi(bolts[0], x.entities.size())
		if _taken(x, 0) > 0:
			hurt_before_bolt[0] = true)
	_run(b, 60, _at({}))
	_check("lightning marks three spots around you, then strikes them",
			bolts[0] == 3 and not hurt_before_bolt[0] and _taken(b, 0) > 0,
			"%d marks, early hurt %s, took %d" % [bolts[0], hurt_before_bolt[0], _taken(b, 0)])


func _test_nue_dives_and_lies_open() -> void:
	var b := _nue_bout(500.0)  # out of the dive's path
	var nue: Monster = b.fighters[1]
	nue._rest = 100000
	nue.health = 99999
	b.fighters[0].invincible = true
	var d: MonsterDefinition.Attack = nue.monster.attacks.filter(
			func(a: MonsterDefinition.Attack) -> bool: return a.move.id == &"dive")[0]
	nue.attack = d
	nue._begin(d.move)
	_run(b, d.move.startup + d.move.active + 4, _at({}))
	var landed := nue.position.y > -1.0
	var before := nue.health
	_run(b, 40, _at({20: [6, "B"]}, 6))  # walk up and strike while it is down
	_check("Nue dives to the ground and lies open there to ordinary attacks",
			landed and nue.health < before,
			"landed %s, struck %s" % [landed, nue.health < before])


func _test_nue_grounded_when_cloud_breaks() -> void:
	var b := _nue_bout(200.0)
	var nue: Monster = b.fighters[1]
	nue.health = 99999
	b.fighters[0].invincible = true
	var hit := MoveDefinition.new()
	hit.damage = 500
	nue.receive(hit, 1, false, 1.0, nue.to_world(nue.monster.parts[3].box).grow(-5))
	var used := {}
	_run(b, 1500, _at({}), null, func(x: Bout) -> void:
		var m: Monster = x.fighters[1]
		if m.state == Fighter.State.MOVE:
			used[m.move.id] = true)
	var on_ground := nue.position.y > -1.0
	var ground_moves := used.has(&"claw") or used.has(&"tail_lash") or used.has(&"pounce")
	var no_air_moves := not used.has(&"dive") and not used.has(&"lightning")
	_check("breaking Nue's thundercloud grounds it for good, and it fights on as a beast",
			on_ground and ground_moves and no_air_moves and not nue.flying(), "used %s" % [used.keys()])


# --- v12: circular arenas, riding Nue, the run, Rokurokubi ---------------------

func _test_all_giants_fought_in_circles() -> void:
	var walled := Bestiary.all().filter(func(m: MonsterDefinition) -> bool: return m.arena_length <= 0.0)
	_check("every giant is fought in a circular arena, so none can corner you", walled.is_empty(),
			"walled: %s" % [walled.map(func(m: MonsterDefinition) -> String: return m.body.display_name)])


## Nue on the ground at x = 200, idle, with a fighter standing on its back.
func _nue_ridden(rest := 100000) -> Bout:
	var b := Bout.versus_monster(def, [], Monster.new(Bestiary.by_id(&"nue"), 4))
	var nue: Monster = b.fighters[1]
	nue.position = Vector2(200, 0)
	nue.health = 99999
	nue._rest = rest
	nue.state = Fighter.State.MOVE  # holds it on the ground while the fighter lands
	nue.move = MoveDefinition.new()
	nue.move.recovery = 30
	_airborne(b.fighters[0], Vector2(200, -200))
	_run(b, 30, _at({}))
	return b


func _test_ride_nue_into_the_air() -> void:
	var b := _nue_ridden()
	var f := b.fighters[0]
	var nue: Monster = b.fighters[1]
	var landed := f.on_raised_ground()
	# Release it to fly, kept from thrashing (that is tested separately).
	nue.move = null
	nue.state = Fighter.State.STAND
	nue._rest = 100000
	_run(b, 120, _at({}))
	var carried_up := f.on_raised_ground() and nue.position.y < -200.0 and f.position.y < nue.position.y - 80.0
	_check("you can land on Nue's back on the ground and ride it up into the air",
			landed and carried_up, "landed %s, Nue at %.0f, rider at %.0f" % [landed, nue.position.y, f.position.y])


func _test_nue_thrashes_riders_off() -> void:
	var b := _nue_ridden(10)
	var thrown := [false]
	_run(b, 300, _at({}), null, func(x: Bout) -> void:
		if not x.fighters[0].on_raised_ground() and x.fighters[0].state in [Fighter.State.KNOCKDOWN, Fighter.State.HITSTUN]:
			thrown[0] = true)
	_check("Nue thrashes a rider off its back", thrown[0])


func _test_run_never_repeats() -> void:
	var all := Roster.all()
	var ok := true
	for seed_number in range(1, 6):
		var r := Run.new(all[seed_number], all, seed_number)
		var seen := [r.opponent.id]
		var resumed := false
		while r.advance():
			if r.fight == 3 and not resumed:
				r = Run.restore(r.to_dict(), all)
				resumed = true
			seen.append(r.opponent.id)
		var fighters := seen.slice(0, Run.FIGHTS_PER_TIER * Run.TIERS)
		var unique := {}
		for id in fighters:
			unique[id] = true
		ok = ok and unique.size() == fighters.size() and not r.character.id in fighters
	_check("a run never pits you against your own fighter or anyone twice, even after resuming", ok)


func _test_rokurokubi_long_neck() -> void:
	var roku := _r(&"rokurokubi")
	var head_move: MoveDefinition = roku.moves[&"long_neck"].spawn
	# Against an opponent far away: the head arcs out and strikes them.
	var b := Bout.new(roku, def)
	b.fighters[0].position.x = -250
	b.fighters[1].position.x = 150
	var peak := [0.0]
	_run(b, 90, _at({0: [5, "C"]}), null, func(x: Bout) -> void:
		for e in x.entities:
			peak[0] = minf(peak[0], e.position.y))
	var struck: bool = _taken(b, 1) == head_move.damage
	# With no one there: it turns back at mid-height and retraces its path.
	var empty := Bout.new(roku, def)
	empty.fighters[0].position.x = -500
	empty.fighters[1].position.x = 500
	var start := [Vector2.INF]
	var lowest := [-INF]
	var last := [Vector2.ZERO]
	var returned := [false]
	_run(empty, 90, _at({0: [5, "C"]}), null, func(x: Bout) -> void:
		for e in x.entities:
			if e.move.tethered:
				if start[0] == Vector2.INF:
					start[0] = e.position
				lowest[0] = maxf(lowest[0], e.position.y)
				last[0] = e.position
				if e.returning:
					returned[0] = true)
	var stays_up: bool = lowest[0] <= head_move.turn_height + 15.0
	var came_back: bool = returned[0] and last[0].distance_to(start[0]) < 30.0
	_check("Long Neck: her head arcs out, turns back at mid-height or on striking, and returns along its path",
			peak[0] < -200.0 and struck and stays_up and came_back,
			"peak %.0f, struck %s, lowest %.0f, back to within %.0f" % [peak[0], struck, lowest[0], last[0].distance_to(start[0])])


func _test_rokurokubi_head_is_vulnerable() -> void:
	var roku := _r(&"rokurokubi")
	var b := Bout.new(roku, def)
	b.fighters[0].position.x = -200
	b.fighters[1].position.x = 300
	_run(b, 20, _at({0: [5, "C"]}))
	var head: Entity = null
	for e in b.entities:
		if e.move.tethered:
			head = e
	var ok := head != null
	var before := b.fighters[0].health
	if ok:
		# A strike from the opponent, right where the head is.
		var blow := MoveDefinition.new()
		blow.damage = 50
		blow.hitstun = 15
		blow.startup = 0
		blow.active = 10
		blow.hitboxes.assign([Rect2(-30, -30, 60, 60)])
		b.entities.append(Entity.new(blow, head.position, -1, 1))
		_run(b, 3, _at({}))
		ok = b.fighters[0].health == before - 50 \
				and not b.entities.any(func(e: Entity) -> bool: return e.move.tethered)
	_check("striking Rokurokubi's flying head hurts her and snaps it back", ok,
			"head %s, health %d -> %d" % [head != null, before, b.fighters[0].health])


func _test_lantern_leaves_fire() -> void:
	var roku := _r(&"rokurokubi")
	var b := Bout.new(roku, def)
	b.fighters[0].position.x = -300
	b.fighters[1].position.x = 300
	var fire_seen := [false]
	var fire_x := [0.0]
	_run(b, 70, _at({0: [4, "C"]}, 4), null, func(x: Bout) -> void:
		for e in x.entities:
			if e.move.id == &"lantern_fire":
				fire_seen[0] = true
				fire_x[0] = e.position.x)
	# Now walk someone into the fire.
	var burned := Bout.new(roku, def)
	burned.fighters[0].position.x = -300
	burned.fighters[1].position.x = 600
	_run(burned, 80, _at({0: [4, "C"]}, 4))  # until it has landed
	var fx := 0.0
	for e in burned.entities:
		if e.move.id == &"lantern_fire":
			fx = e.position.x
	burned.fighters[1].position.x = fx + 10
	_run(burned, 10, _at({}, 5))
	_check("the lantern lands in an arc and leaves a fire that burns whoever stands in it",
			fire_seen[0] and _taken(burned, 1) == roku.moves[&"lantern"].spawn.leaves.damage,
			"fire %s at %.0f; burned %d" % [fire_seen[0], fire_x[0], _taken(burned, 1)])


func _test_drying_pole_wounds_only_with_its_tip() -> void:
	var kojiro := _r(&"kojiro")
	var far := Bout.new(kojiro, def)
	far.fighters[0].position.x = -110
	far.fighters[1].position.x = 110
	_run(far, 30, _at({0: [4, "C"]}, 4))
	var close := Bout.new(kojiro, def)
	close.fighters[0].position.x = -40
	close.fighters[1].position.x = 40
	_run(close, 30, _at({0: [4, "C"]}, 4))
	var spent: bool = close.fighters[0].move_cooldowns.get(&"drying_pole", 0) > 0
	_check("the Drying Pole wounds at its proper distance; too close, it passes harmlessly and is spent",
			_taken(far, 1) == kojiro.moves[&"drying_pole"].damage and _taken(close, 1) == 0 and spent,
			"far %d, close %d, spent %s" % [_taken(far, 1), _taken(close, 1), spent])


# --- weapons: hitboxes traced from the posed weapon ---------------------------

func _test_swing_traces_an_arc() -> void:
	var heavy: MoveDefinition = _r(&"musashi").moves[&"stand_heavy"]
	var tops: Array = []
	for frame in heavy.frame_strikes:
		var top := INF
		for strike in frame:
			top = minf(top, strike[0].position.y)
		tops.append(top)
	var traced := heavy.frame_strikes.size() == heavy.active and tops.all(func(v: float) -> bool: return v < INF)
	_check("Musashi's heavy cut is traced from the katana, and its boxes sweep down through the swing",
			traced and tops[0] < tops[-1] - 60.0, "tops %s" % [tops])


func _test_weapon_tip_wounds_hardest() -> void:
	var shuten := _r(&"shuten")
	var damage := {}
	for distance in [170.0, 60.0]:
		var b := Bout.new(shuten, def)
		b.fighters[0].position.x = -distance / 2.0
		b.fighters[1].position.x = distance / 2.0
		_run(b, 40, _at({0: [5, "B"]}))
		damage[distance] = _taken(b, 1)
	_check("the kanabō wounds hardest with its head; closer in it still hurts, but less",
			damage[170.0] > damage[60.0] and damage[60.0] > 0, "at the head %d, closer %d" % [damage[170.0], damage[60.0]])


func _test_effects_land_with_the_animation() -> void:
	# A move with its own boxes (a quake's ground wave, a throw's grab, a
	# finisher) whose animation is a swing must reach its impact pose exactly
	# when its active frames begin, and hold it through them: nothing takes
	# effect before the blow visibly lands.
	const Registry := preload("res://game/art/puppets/registry.gd")
	var bad: Array[String] = []
	for d in Roster.all():
		var puppet: PuppetDefinition = Registry.for_id(d.id)
		if puppet == null:
			continue
		var moves: Array = d.moves.values() + [d.summon_move, d.finisher_move]
		for m in d.moves.values():
			if m.counter:
				moves.append(m.counter)
		for m in moves:
			if m == null or m.hitboxes.is_empty() or not m.frame_strikes.is_empty():
				continue
			var swing: Dictionary = puppet.swings.get(String(m.id), {})
			if swing.is_empty():
				continue
			var at_start: Dictionary = puppet.swing_pose(swing, m, m.startup).angles
			var at_end: Dictionary = puppet.swing_pose(swing, m, m.startup + m.active - 1).angles
			if at_start != at_end:
				bad.append("%s %s" % [d.id, m.id])
	_check("every animated move with its own boxes lands its blow as its active frames begin", bad.is_empty(),
			"early or late: %s" % [bad])


# --- the humanoid rig --------------------------------------------------------

func _order_names(p: PuppetDefinition, v: int) -> Array:
	return p.draw_order(v).map(func(part: PuppetDefinition.Part) -> String: return part.name)


func _before(order: Array, a: String, b: String) -> bool:
	return order.find(a) >= 0 and order.find(b) >= 0 and order.find(a) < order.find(b)


func _test_rig_side_view_layers() -> void:
	const Registry := preload("res://game/art/puppets/registry.gd")
	var p: PuppetDefinition = Registry.for_id(&"musashi")
	var o := _order_names(p, PuppetDefinition.View.SIDE)
	var ok := _before(o, "trail_upper", "torso") and _before(o, "trail_thigh", "torso") \
			and _before(o, "torso", "lead_thigh") and _before(o, "lead_thigh", "hips") \
			and _before(o, "lapel", "lead_upper") and _before(o, "trail_weapon", "torso") \
			and _before(o, "lead_thigh", "pleat_1") and _before(o, "pleat_1", "lead_shin")
	var shaded := p.shade_of(p.find("trail_upper"), PuppetDefinition.View.SIDE) > 0.0 \
			and p.shade_of(p.find("trail_blade"), PuppetDefinition.View.SIDE) > 0.0 \
			and p.shade_of(p.find("lead_upper"), PuppetDefinition.View.SIDE) == 0.0
	_check("side view: far arm and leg behind the torso, near leg under the clothing, near arm on top; far parts shaded",
			ok and shaded, "%s" % [o])


func _test_rig_diagonal_view_layers() -> void:
	const Registry := preload("res://game/art/puppets/registry.gd")
	var p: PuppetDefinition = Registry.for_id(&"shuten")
	var v := PuppetDefinition.View.DIAGONAL
	var o := _order_names(p, v)
	var ok := _before(o, "lead_thigh", "trail_thigh") and _before(o, "trail_thigh", "hips") \
			and _before(o, "trail_thigh", "head") and _before(o, "head", "lead_upper") \
			and _before(o, "lead_upper", "trail_upper") and _before(o, "trail_upper", "lead_fore") \
			and _before(o, "trail_fore", "trail_weapon") and _before(o, "club", "studs_1")
	var depth := p.depth_of("lead", v) == PuppetDefinition.Depth.FAR and p.depth_of("trail", v) == PuppetDefinition.Depth.NEAR
	var shaded := p.shade_of(p.find("lead_thigh"), v) > 0.0 and p.shade_of(p.find("trail_thigh"), v) == 0.0 \
			and p.shade_of(p.find("lead_upper"), v) == 0.0
	var placed := p.pose_transforms(p.base_angles("stand"))
	var shoulders: bool = placed["lead_upper"].origin.x > 0.0 and placed["trail_upper"].origin.x < 0.0
	_check("diagonal view: the lead side is far (its leg behind and shaded), arms over the torso from its edges",
			ok and depth and shaded and shoulders, "%s" % [o])


func _test_rig_front_view_layers() -> void:
	const Registry := preload("res://game/art/puppets/registry.gd")
	var p: PuppetDefinition = Registry.for_id(&"shuten")
	var v := PuppetDefinition.View.FRONT
	var o := _order_names(p, v)
	var ok := _before(o, "lead_thigh", "head") and _before(o, "trail_thigh", "hips") \
			and _before(o, "head", "lead_upper") and _before(o, "trail_upper", "lead_fore") \
			and _before(o, "lead_fore", "lead_hand") and p.depth_of("lead", v) == p.depth_of("trail", v)
	_check("front view: torso and legs, then head and clothing, upper arms, forearms, hands", ok, "%s" % [o])


func _test_rig_reaches_a_point() -> void:
	const Registry := preload("res://game/art/puppets/registry.gd")
	var p: PuppetDefinition = Registry.for_id(&"shuten")
	var a := p.base_angles("stand")
	a.head = -22.0
	p.reach_with(a, "lead", "mouth", -1.0)
	var placed := p.pose_transforms(a)
	var mouth: Vector2 = placed["head"] * p.points.mouth[1]
	var hand: Vector2 = placed["lead_hand"].origin
	var far_away := p.base_angles("stand")
	p.reach_with(far_away, "lead", Vector2(400, -100), 1.0)
	var stretched: Vector2 = p.pose_transforms(far_away)["lead_hand"].origin
	var shoulder: Vector2 = p.pose_transforms(far_away)["lead_upper"].origin
	var full := p.find("lead_fore").pivot.length() + p.find("lead_hand").pivot.length()
	_check("the rig reaches a hand to a named point, and toward one out of reach without stretching",
			hand.distance_to(mouth) < 2.0 and stretched.distance_to(shoulder) <= full + 0.5,
			"hand %.1f from the mouth; reach %.1f of %.1f" % [hand.distance_to(mouth), stretched.distance_to(shoulder), full])


func _test_every_fighter_has_a_sound_rig() -> void:
	const Registry := preload("res://game/art/puppets/registry.gd")
	var problems: Array[String] = []
	for d in Roster.all():
		var p: PuppetDefinition = Registry.for_id(d.id)
		if p == null:
			problems.append("%s has no puppet" % d.id)
			continue
		for part in p.parts:
			if part.parent != "" and p.find(part.parent) == null:
				problems.append("%s.%s has no parent %s" % [d.id, part.name, part.parent])
		var order := _order_names(p, p.view)
		if order.size() != p.parts.size():
			problems.append("%s draws %d of %d parts" % [d.id, order.size(), p.parts.size()])
		for part in p.parts:
			if part.kind == PuppetDefinition.Kind.APPENDAGE and not _before(order, part.name, "torso"):
				problems.append("%s.%s is not behind the torso" % [d.id, part.name])
		# Basic rigs draw their weapons but leave the hitboxes alone.
		if not d.id in [&"musashi", &"shuten", &"kojiro"]:
			for m in d.moves.values():
				if not m.frame_strikes.is_empty():
					problems.append("%s.%s is traced" % [d.id, m.id])
	_check("every fighter has a puppet whose parts join up, appendages behind; basic rigs leave hitboxes alone",
			problems.is_empty(), "%s" % [problems])


func _test_props_appear_when_reached() -> void:
	const Registry := preload("res://game/art/puppets/registry.gd")
	var oni: PuppetDefinition = Registry.for_id(&"shuten")
	var sake: MoveDefinition = Roster.by_id(&"shuten").moves[&"sake"]
	var before := int(sake.startup * 0.2)
	var after := int(sake.startup * 0.6)
	var at_hip_first: bool = oni.shows(oni.find("gourd_hip"), sake, before) and not oni.shows(oni.find("gourd_hand"), sake, before)
	var in_hand_later: bool = oni.shows(oni.find("gourd_hand"), sake, after) and not oni.shows(oni.find("gourd_hip"), sake, after)
	var roku: PuppetDefinition = Registry.for_id(&"rokurokubi")
	var neck: MoveDefinition = Roster.by_id(&"rokurokubi").moves[&"long_neck"]
	var away := neck.startup + 5
	var head_gone: bool = not roku.shows(roku.find("head"), neck, away) and not roku.shows(roku.find("hair"), neck, away) \
			and roku.shows(roku.find("neck"), neck, away) and roku.shows(roku.find("head"), neck, 0)
	_check("the gourd stays at the hip until the hand reaches it; Rokurokubi's head (and hair) is away while it flies",
			at_hip_first and in_hand_later and head_gone,
			"hip first %s, hand later %s, head away %s" % [at_hip_first, in_hand_later, head_gone])


func _test_joints_stay_within_limits() -> void:
	const Registry := preload("res://game/art/puppets/registry.gd")
	var bad: Array[String] = []
	for d in Roster.all():
		var p: PuppetDefinition = Registry.for_id(d.id)
		if not p.limits.has("fore"):
			continue
		var lo: float = p.limits.fore[0] - 0.5
		var hi: float = p.limits.fore[1] + 0.5
		var check := func(a: Dictionary, what: String) -> void:
			for side in ["lead", "trail"]:
				var v: float = a.get(side + "_fore", 0.0)
				if v < lo or v > hi:
					bad.append("%s %s %s_fore %.0f" % [d.id, what, side, v])
		check.call(p.base_angles("stand"), "rest")
		for id in p.swings:
			var m: MoveDefinition = d.moves.get(StringName(id), null)
			if m == null:
				continue
			for frame in range(0, m.total_frames(), 3):
				check.call(p.swing_pose(p.swings[id], m, frame).angles, String(id))
		# The placeholder reach of moves without swings.
		var f := Fighter.new(d)
		for id in [&"stand_light", &"stand_heavy", &"crouch_heavy"]:
			if p.swings.has(String(id)):
				continue
			f.state = Fighter.State.MOVE
			f.move = d.moves[id]
			f.state_frame = f.move.startup
			check.call(Puppet._pose(f, p, d.stand_hurtbox.size.y / p.height * Puppet.FIT).angles, String(id))
	_check("no elbow bends backward, at rest, in any swing, or in a placeholder reach", bad.is_empty(), "%s" % [bad.slice(0, 6)])


func _test_two_handed_grip() -> void:
	const Registry := preload("res://game/art/puppets/registry.gd")
	var p: PuppetDefinition = Registry.for_id(&"kojiro")
	var d := Roster.by_id(&"kojiro")
	var on_grip := func(a: Dictionary) -> float:
		var placed := p.pose_transforms(a)
		var g: Dictionary = p.grips.trail
		var t: Transform2D = placed[g.part]
		var hand: Vector2 = placed["trail_hand"].origin
		return Geometry2D.get_closest_point_to_segment(hand, t * (g.from as Vector2), t * (g.to as Vector2)).distance_to(hand)
	var rest := p.base_angles("stand")
	p.apply_grips(rest)
	var gap_at_rest: float = on_grip.call(rest)
	var lunge: MoveDefinition = d.moves[&"drying_pole"]
	var gap_in_lunge: float = on_grip.call(p.swing_pose(p.swings.drying_pole, lunge, lunge.startup + 1).angles)
	var heavy: MoveDefinition = d.moves[&"stand_heavy"]
	var gap_in_heavy: float = on_grip.call(p.swing_pose(p.swings.stand_heavy, heavy, heavy.startup + 1).angles)
	_check("Kojirō holds his blade in both hands, the second sliding on the grip, and lets go to lunge",
			gap_at_rest < 3.0 and gap_in_heavy < 3.0 and gap_in_lunge > 12.0,
			"rest %.1f, heavy %.1f, lunge %.1f" % [gap_at_rest, gap_in_heavy, gap_in_lunge])


func _test_kojiro_strikes_with_his_blade() -> void:
	var k := _r(&"kojiro")
	var pole: MoveDefinition = k.moves[&"drying_pole"]
	var near_reach := INF
	for frame in pole.frame_strikes:
		for strike in frame:
			near_reach = minf(near_reach, strike[0].position.x)
	var far := Bout.new(k, def)
	far.fighters[0].position.x = -125
	far.fighters[1].position.x = 125
	_run(far, 40, _at({0: [4, "C"]}, 4))
	var close := Bout.new(k, def)
	close.fighters[0].position.x = -40
	close.fighters[1].position.x = 40
	_run(close, 40, _at({0: [4, "C"]}, 4))
	_check("Kojirō's moves are traced from his blade; the Drying Pole lunges, and wounds only with its tip",
			not k.moves[&"stand_light"].frame_strikes.is_empty() and near_reach > 90.0
			and _taken(far, 1) == pole.damage and _taken(close, 1) == 0,
			"nearest wounding box at %.0f; far %d, close %d" % [near_reach, _taken(far, 1), _taken(close, 1)])


func _test_water_jet_from_the_head() -> void:
	var kappa := _r(&"kappa")
	var b := Bout.new(kappa, def)
	b.fighters[0].position.x = -500
	b.fighters[1].position.x = 500
	var heights := []
	var waves := [0]
	var wave_moved := [0.0, 0.0]
	_run(b, 70, _at({0: [4, "C"]}, 4), null, func(x: Bout) -> void:
		for e in x.entities:
			if e.move.id == &"water":
				heights.append(e.position.y)
			elif e.move.id == &"water_wave":
				waves[0] += 1
				if wave_moved[0] == 0.0:
					wave_moved[0] = e.position.x
				wave_moved[1] = e.position.x)
	var starts_high: bool = not heights.is_empty() and heights[0] < -100.0
	var descends: bool = heights.size() > 2 and heights[-1] > heights[0]
	_check("the water jet leaves his head, drives down, and runs on along the ground as a low wave",
			starts_high and descends and waves[0] > 0 and wave_moved[1] > wave_moved[0],
			"first %.0f, descends %s, wave frames %d" % [heights[0] if heights else 0.0, descends, waves[0]])


func _test_icicle_falls_over_the_opponent() -> void:
	var yuki := _r(&"yuki_onna")
	var spots := []
	for x in [100.0, 450.0]:
		var b := Bout.new(yuki, def)
		b.fighters[0].position.x = -200
		b.fighters[1].position.x = x
		_run(b, 20, _at({0: [4, "C"]}, 4), null, func(z: Bout) -> void:
			for e in z.entities:
				if e.move.id == &"icicle_shard" and spots.size() < 2 and (spots.is_empty() or spots[-1][0] != x):
					spots.append([x, e.position.x]))
	# Over a giant it forms above the core; Ushi-oni's rideable back reaches up
	# to meet it, so it strikes him at once.
	var giant := Bout.versus_monster(yuki, [], Monster.new(Bestiary.by_id(&"ushi_oni"), 3))
	giant.fighters[1].position.x = 300
	var oni: Monster = giant.fighters[1]
	oni._rest = 100000
	var before := oni.health
	_run(giant, 30, _at({0: [4, "C"]}, 4))
	var ok := spots.size() == 2 and spots.all(func(s: Array) -> bool: return absf(s[0] - s[1]) < 1.0) and oni.health < before
	_check("the icicle falls from above the opponent wherever they are, and on a giant", ok,
			"%s; giant %d -> %d" % [spots, before, oni.health])


func _test_pieces_have_pictures() -> void:
	var missing: Array[String] = []
	for id in [&"shuriken_star", &"paper_bird", &"water", &"water_wave", &"icicle_shard", &"web_strand",
			&"thrown_lantern", &"lantern_fire", &"flying_head"]:
		if not Pieces.has_art(id):
			missing.append(String(id))
	_check("projectiles, traps and the flying head have pictures", missing.is_empty(), "%s" % [missing])
