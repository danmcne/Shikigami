class_name PlayerController
extends RefCounted
## Reads one player's InputMap actions (keyboard or gamepad) into an Intent.

var prefix: String


func _init(action_prefix: String) -> void:
	prefix = action_prefix


func read(_me: Fighter, _them: Fighter) -> Intent:
	var i := Intent.new()
	i.x = int(Input.is_action_pressed(prefix + "right")) - int(Input.is_action_pressed(prefix + "left"))
	i.up = Input.is_action_pressed(prefix + "up")
	i.down = Input.is_action_pressed(prefix + "down")
	i.light = Input.is_action_just_pressed(prefix + "light")
	i.heavy = Input.is_action_just_pressed(prefix + "heavy")
	return i
