class_name DummyController
extends RefCounted
## A training dummy. The seed of CPU opponents: it sees the same two fighters
## a player would and answers with an Intent.

enum Mode { IDLE, CROUCH, GUARD, CROUCH_GUARD }

var mode := Mode.IDLE


func _init(initial := Mode.IDLE) -> void:
	mode = initial


func read(me: Fighter, them: Fighter) -> Intent:
	var i := Intent.new()
	i.down = mode == Mode.CROUCH or mode == Mode.CROUCH_GUARD
	var guards := mode == Mode.GUARD or mode == Mode.CROUCH_GUARD
	if guards and (them.state == Fighter.State.ATTACK or me.state == Fighter.State.BLOCKSTUN):
		i.x = -me.facing
	return i


func mode_name() -> String:
	return Mode.keys()[mode].to_lower().replace("_", " ")
