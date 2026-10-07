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
	await scene("seimei_crouch", at.call(&"onmyoji"), 0, &"", 10, 500.0, false, 2)
	await scene("yuki_jump", at.call(&"yuki_onna"), 0, &"", 14, 500.0, false, 8)
	await scene("roku_stride", at.call(&"rokurokubi"), 0, &"", 40, 600.0, true)
	await scene("yuki_stride", at.call(&"yuki_onna"), 0, &"", 47, 600.0, true)
	quit()
