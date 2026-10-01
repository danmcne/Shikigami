class_name DummyController
extends RefCounted
## A training dummy. It sees the same two fighters a player would and answers
## with an Intent.
##
## IDLE and CROUCH defend against nothing. STAND_GUARD and CROUCH_GUARD hold
## plain guard at one height, so lows, overheads and spirits get through.
## FULL_GUARD guards at the height of each incoming attack, switching to
## spirit guard when a spirit is the threat, showing that an attentive
## defender can stop every strike. All guarding modes escape every throw.

enum Mode { IDLE, CROUCH, STAND_GUARD, CROUCH_GUARD, FULL_GUARD }

var mode := Mode.IDLE


func _init(initial := Mode.IDLE) -> void:
	mode = initial


func read(me: Fighter, them: Fighter) -> Intent:
	var i := Intent.new()
	var guards := mode in [Mode.STAND_GUARD, Mode.CROUCH_GUARD, Mode.FULL_GUARD]
	if guards:
		var against_spirit := mode == Mode.FULL_GUARD and me.spirit_threatened
		i.held = Intent.SPIRIT_GUARD if against_spirit else Intent.GUARD
	i.down = mode == Mode.CROUCH or mode == Mode.CROUCH_GUARD
	if mode == Mode.FULL_GUARD and them.state == Fighter.State.MOVE:
		i.down = them.move.height == MoveDefinition.Height.LOW
	if guards and me.state == Fighter.State.GRABBED:
		i.light = true
		i.heavy = true
	return i


func mode_name() -> String:
	return Mode.keys()[mode].to_lower().replace("_", " ")
