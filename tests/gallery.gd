extends SceneTree
## Renders every fighter's puppet at rest, through the real game, for art
## review: /tmp/gallery_<id>.png. Needs a display (see shot.gd).
func _init():
	Settings.set_option("yokai_unlocked", true)
	var main = load("res://game/main.gd").new()
	root.add_child(main)
	for i in 3: await process_frame
	main.screen = main.Screen.VERSUS
	for i in main.roster.size():
		var picks: Array[int] = [i, 0]
		main.versus_choice = picks
		main._start_versus()
		main.screen = main.Screen.VERSUS
		main.set_physics_process(false)
		main.bout.phase = Bout.Phase.FIGHT
		main.bout.fighters[0].position = Vector2(0, 0)
		main.bout.fighters[0].facing = 1
		main.bout.fighters[1].position = Vector2(2000, 0)
		main.queue_redraw()
		for k in 2: await process_frame
		var img := root.get_viewport().get_texture().get_image()
		img.get_region(Rect2i(500, 330, 280, 330)).save_png("/tmp/gallery_%02d_%s.png" % [i, main.roster[i].id])
	quit()
