class_name SpiritBinding
extends RefCounted
## A bound spirit: the fighter it came from and which of that fighter's
## specials it performs when summoned.

var source: FighterDefinition
var move: StringName


func _init(from: FighterDefinition, special: StringName) -> void:
	source = from
	move = special


func label() -> String:
	return "%s: %s" % [source.display_name, String(move).replace("_", " ")]
