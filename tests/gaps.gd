extends SceneTree
## Prints each fighter's preferred distance (from its damage across distances).
const Roster := preload("res://game/fighters/roster.gd")
func _init():
	for d in Roster.all():
		print("%-11s %4d" % [d.id, roundi(d.preferred_gap)])
	quit()
