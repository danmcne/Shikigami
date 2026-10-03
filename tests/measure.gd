extends SceneTree
## Damage by distance for traced moves, against standing and crouching
## opponents (development aid, run on request).
const PR := preload("res://game/fighters/prototype_rect.gd")
const Roster := preload("res://game/fighters/roster.gd")

func damage(who: FighterDefinition, move_id: StringName, d: float, crouch: bool) -> int:
	var b := Bout.new(who, PR.definition())
	b.fighters[0].position.x = -d / 2.0
	b.fighters[1].position.x = d / 2.0
	b.fighters[0].perform(move_id)
	for n in 60:
		var them := Intent.from_numpad(2, b.fighters[1].facing, "") if crouch else Intent.new()
		var intents: Array[Intent] = [Intent.new(), them]
		b.step(intents)
	return 1000 - b.fighters[1].health

func _init():
	for id in [&"musashi", &"shuten"]:
		var who: FighterDefinition = Roster.by_id(id)
		for move_id in [&"stand_light", &"stand_heavy", &"crouch_light", &"crouch_heavy", &"two_heavens", &"kanabo_quake"]:
			if not who.moves.has(move_id):
				continue
			var standing := []
			var crouching := []
			for d in [60, 100, 140, 180, 220, 260]:
				standing.append(damage(who, move_id, d, false))
				crouching.append(damage(who, move_id, d, true))
			print("%-8s %-13s reach %4.0f  standing %s  crouching %s" % [id, move_id,
					CpuController._reach(who.moves[move_id]), standing, crouching])
	quit()
