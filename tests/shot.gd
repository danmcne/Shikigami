extends SceneTree
## Renders posed scenes of the real game to PNGs, for art review only.
var main

func snap(name: String) -> void:
	main.queue_redraw()
	for i in 2: await process_frame
	root.get_viewport().get_texture().get_image().save_png("/tmp/art_%s.png" % name)

func pose(f: Fighter, state: Fighter.State, frame := 0, move_id := &"", crouch := false) -> void:
	f.state = state
	f.state_frame = frame
	f.crouching = crouch
	f.airborne = false
	if move_id != &"":
		f.move = f.definition.moves[move_id]
	else:
		f.move = null

func _init():
	Settings.set_option("yokai_unlocked", true)
	main = load("res://game/main.gd").new()
	root.add_child(main)
	for i in 3: await process_frame
	var picks: Array[int] = [0, 8]
	main.versus_choice = picks
	main._start_versus()
	main.screen = main.Screen.VERSUS
	main.set_physics_process(false)
	var m: Fighter = main.bout.fighters[0]
	var s: Fighter = main.bout.fighters[1]
	m.position = Vector2(-140, 0); m.facing = 1
	s.position = Vector2(150, 0); s.facing = -1
	pose(m, Fighter.State.STAND); pose(s, Fighter.State.STAND)
	await snap("1_idle")
	pose(m, Fighter.State.MOVE, 15, &"two_heavens"); pose(s, Fighter.State.HITSTUN, 4)
	await snap("2_two_heavens")
	pose(m, Fighter.State.GUARD); pose(s, Fighter.State.MOVE, 18, &"stand_heavy")
	await snap("3_heavy_on_guard")
	pose(m, Fighter.State.CROUCH, 0, &"", true); pose(s, Fighter.State.KNOCKDOWN, 10)
	await snap("4_crouch_knockdown")
	main.run = Run.new(main.roster[0], main.roster, 1)
	main.run.opponent = main.roster[8]
	main.screen = main.Screen.RUN
	pose(m, Fighter.State.MOVE, 3, &"stand_light"); pose(s, Fighter.State.WALK)
	await snap("5_campaign_tori")
	quit()
