class_name Settings
extends RefCounted
## Settings that persist between sessions, in user://settings.cfg: each
## player's input timing, and the game options chosen on the menu.

const PATH := "user://settings.cfg"
const SPEEDS := [1.0, 0.75, 0.5]


static func chord_window(player: int) -> int:
	return _read("input", "chord_window_%d" % player, InputHistory.DEFAULT_CHORD)


static func motion_window(player: int) -> int:
	return _read("input", "motion_window_%d" % player, InputHistory.DEFAULT_MOTION_WINDOW)


static func set_timing(player: int, chord: int, motion: int) -> void:
	_write("input", "chord_window_%d" % player, chord)
	_write("input", "motion_window_%d" % player, motion)


## Index into CpuController.LEVELS.
static func difficulty() -> int:
	return _read("game", "difficulty", 0)


## Index into SPEEDS.
static func speed() -> int:
	return _read("game", "speed", 0)


static func invincible() -> bool:
	return _read("game", "invincible", false)


static func set_option(key: String, value: Variant) -> void:
	_write("game", key, value)


static func _read(section: String, key: String, default: Variant) -> Variant:
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	return cfg.get_value(section, key, default)


static func _write(section: String, key: String, value: Variant) -> void:
	var cfg := ConfigFile.new()
	cfg.load(PATH)
	cfg.set_value(section, key, value)
	cfg.save(PATH)
