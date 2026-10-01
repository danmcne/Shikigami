class_name Settings
extends RefCounted
## Per-player settings that persist between sessions, in user://settings.cfg.

const PATH := "user://settings.cfg"


static func chord_window(player: int) -> int:
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	return cfg.get_value("input", "chord_window_%d" % player, InputHistory.DEFAULT_CHORD)


static func set_chord_window(player: int, frames: int) -> void:
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	cfg.set_value("input", "chord_window_%d" % player, frames)
	cfg.save(PATH)
