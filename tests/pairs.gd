extends SceneTree
## Plays bouts between computer players (Hard) and records each bout's
## winner, one JSON line per bout, appended to a file.
## Usage: godot --headless --path . --script res://tests/pairs.gd -- OUT SEED PER [PAIRS.json]
## Without a pairs file, every ordered pairing is played PER times; with one
## (a JSON list of [a, b] ids), only those.
const Roster := preload("res://game/fighters/roster.gd")
const LIMIT := 60 * 300

func _init():
	var args := OS.get_cmdline_user_args()
	var out_path: String = args[0]
	var rng := RandomNumberGenerator.new()
	rng.seed = int(args[1])
	var per := int(args[2])
	var all := Roster.all()
	var by_id := {}
	for d in all:
		by_id[String(d.id)] = d
	var pairs: Array = []
	if args.size() > 3:
		pairs = JSON.parse_string(FileAccess.get_file_as_string(args[3]))
	else:
		for a in all:
			for b in all:
				if a != b:
					pairs.append([String(a.id), String(b.id)])
	var params: Dictionary = CpuController.LEVELS[3][1]
	var f := FileAccess.open(out_path, FileAccess.READ_WRITE if FileAccess.file_exists(out_path) else FileAccess.WRITE)
	f.seek_end()
	for pair in pairs:
		for n in per:
			var bout := Bout.new(by_id[pair[0]], by_id[pair[1]])
			var cpus := [CpuController.new(params, rng.randi()), CpuController.new(params, rng.randi())]
			var frames := 0
			while bout.winner() < 0 and frames < LIMIT:
				var fs := bout.fighters
				var intents: Array[Intent] = [cpus[0].read(fs[0], fs[1]), cpus[1].read(fs[1], fs[0])]
				bout.step(intents)
				frames += 1
			f.store_line(JSON.stringify({a = pair[0], b = pair[1], winner = bout.winner()}))
	f.close()
	quit()
