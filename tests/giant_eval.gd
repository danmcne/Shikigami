extends SceneTree
## Every fighter against each giant: wins, and how much of the giant's health
## it removes on average before the fight ends (a relative measure for
## spotting outliers, since the computer player is not a strong giant-fighter).
## The fighter is the computer at Hard; the giants at Normal pace.
## Usage: godot --headless --path . --script res://tests/giant_eval.gd -- [bouts] [giant ids...]
const Roster := preload("res://game/fighters/roster.gd")
const Bestiary := preload("res://game/monsters/bestiary.gd")
const LIMIT := 60 * 180

func _init():
	var args := OS.get_cmdline_user_args()
	var per := int(args[0]) if args.size() > 0 else 2
	var giants: Array = args.slice(1) if args.size() > 1 else ["ushi_oni", "gashadokuro", "nue"]
	var params: Dictionary = CpuController.LEVELS[3][1]
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var header := "%-11s" % ""
	for g in giants:
		header += "  %-22s" % g
	print(header)
	for d in Roster.all():
		var row := "%-11s" % d.id
		for g in giants:
			var won := 0
			var dealt := 0.0
			for n in per:
				var no_spirits: Array[SpiritBinding] = []
				var bout := Bout.versus_monster(d, no_spirits, Monster.new(Bestiary.by_id(StringName(g)), 2))
				var cpu := CpuController.new(params, rng.randi())
				var frames := 0
				while bout.winner() < 0 and frames < LIMIT:
					var intents: Array[Intent] = [cpu.read(bout.fighters[0], bout.fighters[1]), Intent.new()]
					bout.step(intents)
					frames += 1
				var giant: Monster = bout.fighters[1]
				if bout.winner() == 0:
					won += 1
					dealt += 1.0
				else:
					dealt += 1.0 - float(giant.health) / giant.definition.max_health
			row += "  won %3d%%  took %3d%%     " % [roundi(100.0 * won / per), roundi(100.0 * dealt / per)]
		print(row)
	quit()
