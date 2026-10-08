extends RefCounted
## Every fighter's puppet: Musashi and Shuten-dōji in detail, the rest as
## basic rigs built from descriptions.

const Musashi := preload("res://game/art/puppets/musashi.gd")
const Shuten := preload("res://game/art/puppets/shuten.gd")
const Basic := preload("res://game/art/puppets/basic.gd")

## Built afresh when asked for: a few dozen small objects, cheaper than the
## engine's trouble with static caches of script-built objects at exit.
## Each fighter's world scale (puppet units to world units), set by the
## roster once it knows the fighter's size, so the verbs aim at world heights.
static var scales: Dictionary = {}


static func for_id(id: StringName) -> PuppetDefinition:
	var scale: float = scales.get(id, 1.0)
	match id:
		&"musashi":
			return Musashi.definition(scale)
		&"shuten":
			return Shuten.definition()
	return Basic.definition(id, scale)
