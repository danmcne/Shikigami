extends RefCounted
## Every monster, for the run's monster tier and for versus.

const UshiOni := preload("res://game/monsters/ushi_oni.gd")


static func all() -> Array[MonsterDefinition]:
	return [UshiOni.definition()]


static func by_id(id: StringName) -> MonsterDefinition:
	for m in all():
		if m.body.id == id:
			return m
	return null
