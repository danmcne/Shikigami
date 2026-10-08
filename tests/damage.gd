extends SceneTree
## Where each fighter's damage comes from: plays bouts between the computer
## players (Hard) and credits every point of damage to the move (or piece)
## that dealt it. Usage: godot --headless --path . --script res://tests/damage.gd -- [bouts per pairing]
const Roster := preload("res://game/fighters/roster.gd")

func _init():
	var per := int(OS.get_cmdline_user_args()[0]) if OS.get_cmdline_user_args().size() > 0 else 1
	var all := Roster.all()
	var dealt := {}
	var taken := {}
	var per_foe := {}
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var params: Dictionary = CpuController.LEVELS[3][1]
	for a in all:
		dealt[a.id] = {}
		taken[a.id] = 0
	for a in all:
		for b in all:
			if a == b:
				continue
			for n in per:
				var bout := Bout.new(a, b)
				var cpus := [CpuController.new(params, rng.randi()), CpuController.new(params, rng.randi())]
				var frames := 0
				while bout.winner() < 0 and frames < 60 * 200:
					var f := bout.fighters
					var before := [f[0].health, f[1].health]
					var intents: Array[Intent] = [cpus[0].read(f[0], f[1]), cpus[1].read(f[1], f[0])]
					bout.step(intents)
					frames += 1
					for i in 2:
						var lost: int = before[1 - i] - f[1 - i].health
						if lost > 0:
							var by := "?"
							if f[i].state == Fighter.State.MOVE and f[i].move:
								by = String(f[i].move.id)
							else:
								for e in bout.entities:
									if e.owner_index == i:
										by = String(e.move.id)
							var d: Dictionary = dealt[f[i].definition.id]
							d[by] = d.get(by, 0) + lost
							var key := [f[i].definition.id, f[1 - i].definition.id]
							var pf: Dictionary = per_foe.get(key, {})
							pf[by] = pf.get(by, 0) + lost
							per_foe[key] = pf
							taken[f[1 - i].definition.id] += lost
	for a in all:
		var d: Dictionary = dealt[a.id]
		var total := 0
		for k in d:
			total += d[k]
		var keys := d.keys()
		keys.sort_custom(func(x, y): return d[x] > d[y])
		# Which move did the most damage against each opponent: a move best
		# against nearly everyone is an outlier to fix.
		var tops := {}
		for b in all:
			if b == a:
				continue
			var pf: Dictionary = per_foe.get([a.id, b.id], {})
			var best := ""
			for k in pf:
				if best == "" or pf[k] > pf[best]:
					best = k
			tops[best] = tops.get(best, 0) + 1
		var top_move := ""
		for k in tops:
			if top_move == "" or tops[k] > tops[top_move]:
				top_move = k
		var row := "%-11s dealt %6d taken %6d  best vs %2d/15: %-14s " % [a.id, total, taken[a.id], tops.get(top_move, 0), top_move]
		for k in keys.slice(0, 3):
			row += "%s %d%%  " % [k, roundi(100.0 * d[k] / maxf(total, 1))]
		print(row)
	quit()
