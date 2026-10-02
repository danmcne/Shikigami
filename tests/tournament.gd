extends SceneTree
## Balance tournament. Not part of the game; run it explicitly:
##   godot --headless --path . --script res://tests/tournament.gd -- [bouts] [level] [spirits] [seed]
## bouts:   bouts per ordered pairing (default 2; each fighter plays both sides)
## level:   index into CpuController.LEVELS (default 3, Hard)
## spirits: 1 to give each fighter two random spirits it could bind (default 0)
## seed:    random seed (default 1); runs with different seeds are independent
##          samples that can be pooled
##
## Each run also writes its win matrix to user://tournament_<seed>.txt.
##
## Both sides are the same computer, so a result says how well this computer
## does with each kit. That is evidence about balance, not a measurement of it:
## a kit the computer uses badly will look weak whatever its strength. Rounds
## are limited to 60 seconds, after which the larger share of health wins.

const Roster := preload("res://game/fighters/roster.gd")
const ROUND_FRAMES := 60 * 60
const MAX_FRAMES := 4 * ROUND_FRAMES


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var per := int(args[0]) if args.size() > 0 else 2
	var level := int(args[1]) if args.size() > 1 else 3
	var with_spirits := args.size() > 2 and args[2] == "1"
	var params: Dictionary = CpuController.LEVELS[level][1]
	var all := Roster.all()
	var n := all.size()
	var wins := []
	for i in n:
		wins.append([])
		for j in n:
			wins[i].append(0.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(args[3]) if args.size() > 3 else 1
	var timeouts := 0
	var frames_total := 0
	var started := Time.get_ticks_msec()
	for i in n:
		for j in n:
			if i == j:
				continue
			for k in per:
				var result := _bout(all[i], all[j], params, rng, all, with_spirits)
				wins[i][j] += result[0]
				timeouts += result[1]
				frames_total += result[2]
	var bouts := n * (n - 1) * per
	var out := FileAccess.open("user://tournament_%s.txt" % (args[3] if args.size() > 3 else "1"), FileAccess.WRITE)
	for i in n:
		out.store_line(" ".join(wins[i].map(func(v: float) -> String: return str(v))))
	out.close()

	print("Tournament: %s computer, %d bouts per ordered pairing, %d bouts, spirits %s, %.0f s"
			% [CpuController.LEVELS[level][0], per, bouts, "on" if with_spirits else "off",
			(Time.get_ticks_msec() - started) / 1000.0])
	print("Rounds decided on time: %d.  Mean bout length: %.0f s of game time." % [timeouts, frames_total / 60.0 / bouts])
	print("")
	var overall := []
	for i in n:
		var won := 0.0
		for j in n:
			if i != j:
				# Bouts i won as player 1, plus bouts j lost to i as player 2.
				won += wins[i][j] + (per - wins[j][i])
		overall.append([won / (2.0 * per * (n - 1)), all[i].display_name])
	overall.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0])
	print("Overall win rate")
	for row in overall:
		print("  %5.1f%%  %s" % [row[0] * 100.0, row[1]])
	print("")
	print("Most lopsided pairings (both sides combined)")
	var pairs := []
	for i in n:
		for j in range(i + 1, n):
			var rate: float = (wins[i][j] + per - wins[j][i]) / (2.0 * per)
			pairs.append([absf(rate - 0.5), rate, all[i].display_name, all[j].display_name])
	pairs.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0])
	for row in pairs.slice(0, 10):
		print("  %s beats %s %.0f%% of the time" % ([row[2], row[3], row[1] * 100.0] if row[1] >= 0.5
				else [row[3], row[2], (1.0 - row[1]) * 100.0]))
	quit()


## Plays one bout; returns [1.0 / 0.5 / 0.0 for player 1, rounds on time, frames].
func _bout(a: FighterDefinition, b: FighterDefinition, params: Dictionary, rng: RandomNumberGenerator,
		all: Array[FighterDefinition], with_spirits: bool) -> Array:
	var bout := Bout.new(a, b, _loadout(a, all, rng, with_spirits), _loadout(b, all, rng, with_spirits))
	bout.time_limit = ROUND_FRAMES
	bout.offer_finisher = false
	var cpus := [CpuController.new(params, rng.randi()), CpuController.new(params, rng.randi())]
	var timeouts := 0
	var frames := 0
	while bout.phase != Bout.Phase.BOUT_OVER and frames < MAX_FRAMES:
		var f := bout.fighters
		var intents: Array[Intent] = [cpus[0].read(f[0], f[1]), cpus[1].read(f[1], f[0])]
		var was := bout.phase
		bout.step(intents)
		if was == Bout.Phase.FIGHT and bout.phase != Bout.Phase.FIGHT and bout.round_frame >= ROUND_FRAMES:
			timeouts += 1
		frames += 1
	var w := bout.winner()
	return [1.0 if w == 0 else (0.0 if w == 1 else 0.5), timeouts, frames]


func _loadout(d: FighterDefinition, all: Array[FighterDefinition], rng: RandomNumberGenerator,
		with_spirits: bool) -> Array[SpiritBinding]:
	var bound: Array[SpiritBinding] = []
	if not with_spirits:
		return bound
	var candidates := all.filter(func(o: FighterDefinition) -> bool: return d.binds(o))
	for k in 2:
		var pick: FighterDefinition = candidates.pop_at(rng.randi() % candidates.size())
		bound.append(SpiritBinding.new(pick, pick.specials[rng.randi() % 2]))
	return bound
