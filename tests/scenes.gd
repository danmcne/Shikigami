extends SceneTree
## Renders scenes of particular moves through the real game, for art review:
## each scene performs a move and runs the bout forward a number of frames.
## Needs a display (see shot.gd). Output: /tmp/scene_<name>.png
var main

func scene(name: String, a: int, b: int, move: StringName, frames: int, distance := 300.0, walk := false) -> void:
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
	await scene("kojiro_heavy_up", at.call(&"kojiro"), 0, &"stand_heavy", 9)
	await scene("kojiro_heavy_down", at.call(&"kojiro"), 0, &"stand_heavy", 15)
	await scene("kojiro_swallow", at.call(&"kojiro"), 0, &"swallow_cut", 9)
	await scene("kojiro_lunge", at.call(&"kojiro"), 0, &"drying_pole", 12, 360.0)
	await scene("oni_drink_arc", at.call(&"shuten"), 0, &"sake", 32)
	await scene("seimei_birds", at.call(&"onmyoji"), 0, &"paper_birds", 22, 500.0)
	await scene("roku_lantern", at.call(&"rokurokubi"), 0, &"lantern", 30, 500.0)
	await scene("roku_neck", at.call(&"rokurokubi"), 0, &"long_neck", 34, 500.0)
	await scene("kappa_jet", at.call(&"kappa"), 0, &"water_jet", 30, 500.0)
	await scene("yuki_frost", at.call(&"yuki_onna"), 0, &"frost_breath", 13, 200.0)
	await scene("yuki_icicle", at.call(&"yuki_onna"), 0, &"icicle", 30, 400.0)
	await scene("joro_web", at.call(&"jorogumo"), 0, &"web", 22, 500.0)
	await scene("tanuki_drum", at.call(&"tanuki"), 0, &"belly_drum", 16, 300.0)
	await scene("tanuki_leaf", at.call(&"tanuki"), 0, &"leaf_disguise", 6, 300.0)
	await scene("hanzo_star", at.call(&"hanzo"), 0, &"shuriken", 14, 500.0)
	await scene("musashi_walk", at.call(&"musashi"), 0, &"", 26, 500.0, true)
	quit()
