extends SceneTree
## Writes every synthesized sound to WAV files, timing each.
## Usage: godot --headless --path . --script res://tests/export_sounds.gd -- OUT_DIR
func _init():
	var out: String = OS.get_cmdline_user_args()[0]
	var sound := Sound.new()
	for name in ["bell", "gong", "hit", "hit_heavy", "giant_hit", "giant_slam", "giant_swing", "thunder", "block", "tick", "menu", "fight"]:
		var started := Time.get_ticks_msec()
		var w := sound.stream(name)
		var took := Time.get_ticks_msec() - started
		w.save_to_wav(out.path_join(name + ".wav"))
		print("%-10s %5.1f s of sound, made in %4d ms" % [name, w.data.size() / 2.0 / Sound.RATE, took])
	sound.free()
	quit()
