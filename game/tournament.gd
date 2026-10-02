class_name Tournament
extends RefCounted
## Every fighter against every other, the same computer on both sides, in
## both positions, rounds limited to 60 seconds. It runs a little at a time,
## so the game can show progress, and reports win rates, the human/yokai
## split, the most lopsided pairings, and how often each special was used.
##
## Results describe this computer playing each kit. They are evidence about
## balance, not a measurement of it: a kit the computer plays badly looks
## weak whatever its strength.

const ROUND_FRAMES := 60 * 60
const MAX_FRAMES := 4 * ROUND_FRAMES

var roster: Array[FighterDefinition]
var level := 3
var per := 2
var with_spirits := false
var seed_value := 1
var rng := RandomNumberGenerator.new()
## wins[i][j]: bouts fighter i won as player 1 against j.
var wins: Array = []
var bouts_done := 0
var timeouts := 0
var frames_total := 0
## By fighter id: bouts played, uses of each special, health restored.
var played := {}
var uses := {}
var restored := {}
var elapsed_ms := 0

var _pairs: Array = []
var _bout: Bout = null
var _cpus: Array = []
var _pair: Array = []
var _frames := 0


func _init(all: Array[FighterDefinition], level_index := 3, bouts_per_pairing := 2,
		spirits := false, seed_number := 1) -> void:
	roster = all
	level = level_index
	per = bouts_per_pairing
	with_spirits = spirits
	seed_value = seed_number
	rng.seed = seed_number
	var n := roster.size()
	for i in n:
		wins.append([])
		for j in n:
			wins[i].append(0.0)
			if i != j:
				for k in per:
					_pairs.append([i, j])
	for d in roster:
		played[d.id] = 0
		restored[d.id] = 0
		uses[d.id] = {}
		for s in d.specials:
			uses[d.id][s] = 0


func total() -> int:
	return roster.size() * (roster.size() - 1) * per


func done() -> bool:
	return _pairs.is_empty() and _bout == null


func progress() -> float:
	return float(bouts_done) / maxi(total(), 1)


## Plays for about `budget_ms` of real time. Returns true when finished.
func step(budget_ms: int) -> bool:
	var start := Time.get_ticks_msec()
	while not done() and Time.get_ticks_msec() - start < budget_ms:
		if _bout == null:
			_begin_bout()
		for k in 120:
			if _advance():
				break
	elapsed_ms += Time.get_ticks_msec() - start
	return done()


func report() -> Array[String]:
	var n := roster.size()
	var out: Array[String] = []
	out.append("Tournament: %s computer, %d bouts (%d per ordered pairing), spirits %s, seed %d, %.0f s" % [
			CpuController.LEVELS[level][0], bouts_done, per, "on" if with_spirits else "off", seed_value,
			elapsed_ms / 1000.0])
	out.append("Rounds decided on time: %d.  Mean bout length: %.0f s of game time." % [
			timeouts, frames_total / 60.0 / maxi(bouts_done, 1)])
	out.append("")
	var rates := []
	var by_kind := {}
	for i in n:
		var won := 0.0
		for j in n:
			if i != j:
				won += wins[i][j] + (per - wins[j][i])
		var games := 2.0 * per * (n - 1)
		var rate := won / games
		var margin := 1.96 * sqrt(rate * (1.0 - rate) / games)
		rates.append([rate, margin, roster[i].display_name])
		var kind := roster[i].kind
		if not by_kind.has(kind):
			by_kind[kind] = []
		by_kind[kind].append(rate)
	rates.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0])
	out.append("Overall win rate (with a 95% margin)")
	for r in rates:
		out.append("  %5.1f%% ± %4.1f  %s" % [r[0] * 100.0, r[1] * 100.0, r[2]])
	var kinds: Array[String] = []
	for kind in by_kind:
		var mean: float = by_kind[kind].reduce(func(a: float, b: float) -> float: return a + b, 0.0) / by_kind[kind].size()
		kinds.append("%s %.1f%%" % [["humans", "yokai", "monsters"][kind], mean * 100.0])
	out.append("By kind: " + ", ".join(kinds))
	out.append("")
	out.append("Most lopsided pairings (both positions combined)")
	var pairs := []
	for i in n:
		for j in range(i + 1, n):
			var rate: float = (wins[i][j] + per - wins[j][i]) / (2.0 * per)
			pairs.append([absf(rate - 0.5), rate, roster[i].display_name, roster[j].display_name])
	pairs.sort_custom(func(a: Array, b: Array) -> bool: return a[0] > b[0])
	for p in pairs.slice(0, 8):
		out.append("  %s beats %s %.0f%%" % ([p[2], p[3], p[1] * 100.0] if p[1] >= 0.5
				else [p[3], p[2], (1.0 - p[1]) * 100.0]))
	out.append("")
	out.append("Specials used per bout")
	for d in roster:
		var parts: Array[String] = []
		var bouts: int = maxi(played[d.id], 1)
		for s in d.specials:
			parts.append("%s %.1f" % [String(s).replace("_", " "), float(uses[d.id][s]) / bouts])
		var line := "  %s: %s" % [d.display_name, ", ".join(parts)]
		if restored[d.id] > 0:
			line += "  (health restored %.0f per bout)" % (float(restored[d.id]) / bouts)
		out.append(line)
	return out


func _begin_bout() -> void:
	_pair = _pairs.pop_front()
	var a := roster[_pair[0]]
	var b := roster[_pair[1]]
	_bout = Bout.new(a, b, _loadout(a), _loadout(b))
	_bout.time_limit = ROUND_FRAMES
	_bout.offer_finisher = false
	var params: Dictionary = CpuController.LEVELS[level][1]
	_cpus = [CpuController.new(params, rng.randi()), CpuController.new(params, rng.randi())]
	_frames = 0
	for d in [a, b]:
		played[d.id] += 1


## One frame of the current bout. Returns true when the bout ends.
func _advance() -> bool:
	var f := _bout.fighters
	var health_before := [f[0].health, f[1].health]
	var intents: Array[Intent] = [_cpus[0].read(f[0], f[1]), _cpus[1].read(f[1], f[0])]
	var was := _bout.phase
	_bout.step(intents)
	_frames += 1
	for k in 2:
		var fighter := f[k]
		if fighter.state == Fighter.State.MOVE and fighter.state_frame == 0 \
				and fighter.move.id in fighter.definition.specials:
			uses[fighter.definition.id][fighter.move.id] += 1
		if was == Bout.Phase.FIGHT and fighter.health > health_before[k]:
			restored[fighter.definition.id] += fighter.health - health_before[k]
	if was == Bout.Phase.FIGHT and _bout.phase != Bout.Phase.FIGHT and _bout.round_frame >= ROUND_FRAMES:
		timeouts += 1
	if _bout.phase == Bout.Phase.BOUT_OVER or _frames >= MAX_FRAMES:
		var w := _bout.winner()
		wins[_pair[0]][_pair[1]] += 1.0 if w == 0 else (0.0 if w == 1 else 0.5)
		frames_total += _frames
		bouts_done += 1
		_bout = null
		return true
	return false


func _loadout(d: FighterDefinition) -> Array[SpiritBinding]:
	var bound: Array[SpiritBinding] = []
	if not with_spirits:
		return bound
	var candidates := roster.filter(func(o: FighterDefinition) -> bool: return d.binds(o))
	for k in mini(2, candidates.size()):
		var pick: FighterDefinition = candidates.pop_at(rng.randi() % candidates.size())
		bound.append(SpiritBinding.new(pick, pick.specials[rng.randi() % pick.specials.size()]))
	return bound
