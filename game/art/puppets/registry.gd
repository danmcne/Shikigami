extends RefCounted
## Which fighters have puppets yet. The rest are still drawn as rectangles.

const Musashi := preload("res://game/art/puppets/musashi.gd")
const Shuten := preload("res://game/art/puppets/shuten.gd")

## Built afresh when asked for: a few dozen small objects, cheaper than the
## engine's trouble with static caches of script-built objects at exit.
static func for_id(id: StringName) -> PuppetDefinition:
	match id:
		&"musashi":
			return Musashi.definition()
		&"shuten":
			return Shuten.definition()
	return null
