extends SceneTree
## Renders scenes of particular moves through the real game, for art review:
## each scene performs a move and runs the bout forward a number of frames.
## Needs a display (see shot.gd). Output: /tmp/scene_<name>.png
var main

func scene(name: String, a: int, b: int, move: StringName, frames: int, distance := 300.0, walk := false, hold := 0) -> void:
	var picks: Array[int] = [a, b]
	main.versus_choice = picks
	main._start_versus()
	main.screen = main.Screen.VERSUS
	main.set_physics_process(false)
	var bout: Bout = main.bout
	bout.phase = Bout.Phase.FIGHT
	bout.fighters[0].position = Vector2(-distance / 2.0, 0)
	bout.fighters[1].position = Vector2(distance / 2.0, 0)
	if move != &"":
		bout.fighters[0].perform(move)
	for n in frames:
		var i0 := Intent.from_numpad(6, bout.fighters[0].facing, "") if walk else Intent.new()
		if hold > 0:
			i0 = Intent.from_numpad(hold, bout.fighters[0].facing, "")
		var intents: Array[Intent] = [i0, Intent.new()]
		bout.step(intents)
		# Draw every frame, as in play (motion trails gather as they are drawn).
		main.queue_redraw()
		await process_frame
	main.queue_redraw()
	for k in 2: await process_frame
	root.get_viewport().get_texture().get_image().get_region(Rect2i(240, 300, 800, 380)).save_png("/tmp/scene_%s.png" % name)

func _init():
	Settings.set_option("yokai_unlocked", true)
	main = load("res://game/main.gd").new()
	root.add_child(main)
	for i in 3: await process_frame
	var ids: Array = main.roster.map(func(d): return d.id)
	var at := func(id: StringName) -> int: return ids.find(id)
	var plan := [["kappa", &"stand_light", -2], ["kitsune", &"stand_heavy", -2], ["jorogumo", &"stand_light", -2]]
	for k in plan.size():
		var i: int = at.call(StringName(plan[k][0]))
		var frames: int = main.roster[i].moves[plan[k][1]].startup + 1
		await scene("tail_%02d" % k, i, 0, plan[k][1], frames, 300.0)
	quit()
