class_name Settings
extends RefCounted
## Settings that persist between sessions, in user://settings.cfg: each
## player's input timing, the game options chosen on the menu, and the run in
## progress.
##
## Timing keys carry a version: when the calibration's method changes, older
## results no longer mean the same thing and are ignored.

const PATH := "user://settings.cfg"
const SPEEDS := [1.0, 0.75, 0.5]
const TIMING_VERSION := 2


static func chord_window(player: int) -> int:
	return _read("input", _timing_key(player), InputHistory.DEFAULT_CHORD)


static func calibrated(player: int) -> bool:
	return _read("input", _timing_key(player), -1) >= 0


static func set_chord_window(player: int, frames: int) -> void:
	_write("input", _timing_key(player), frames)


## The saved run, or an empty dictionary.
static func saved_run() -> Dictionary:
	return _read("run", "state", {})


static func save_run(state: Dictionary) -> void:
	_write("run", "state", state)


static func _timing_key(player: int) -> String:
	return "chord_window_v%d_%d" % [TIMING_VERSION, player]


## Index into CpuController.LEVELS.
static func difficulty() -> int:
	return _read("game", "difficulty", 0)


## Index into SPEEDS.
static func speed() -> int:
	return _read("game", "speed", 0)


static func invincible() -> bool:
	return _read("game", "invincible", false)


static func yokai_unlocked() -> bool:
	return _read("game", "yokai_unlocked", false)


static func sound_on() -> bool:
	return _read("game", "sound", true)


static func music_on() -> bool:
	return _read("game", "music", true)


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
