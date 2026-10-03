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
	f.move_connected = false
	f.move = f.definition.moves[move_id] if move_id != &"" else null

func _init():
	Settings.set_option("yokai_unlocked", true)
	main = load("res://game/main.gd").new()
	root.add_child(main)
	for i in 3: await process_frame
	await snap("0_menu")
	var picks: Array[int] = [0, 8]
	main.versus_choice = picks
	main._start_versus()
	main.screen = main.Screen.VERSUS
	main.set_physics_process(false)
	main.show_boxes = true
	var m: Fighter = main.bout.fighters[0]
	var s: Fighter = main.bout.fighters[1]
	m.position = Vector2(-120, 0); m.facing = 1
	s.position = Vector2(130, 0); s.facing = -1
	var heavy: MoveDefinition = m.definition.moves[&"stand_heavy"]
	pose(m, Fighter.State.MOVE, m.definition.moves[&"stand_light"].startup + 1, &"stand_light"); pose(s, Fighter.State.STAND)
	await snap("1_light")
	pose(m, Fighter.State.MOVE, heavy.startup, &"stand_heavy"); pose(s, Fighter.State.HITSTUN, 3)
	await snap("2_heavy_start")
	pose(m, Fighter.State.MOVE, heavy.startup + heavy.active - 1, &"stand_heavy")
	await snap("3_heavy_end")
	pose(m, Fighter.State.MOVE, m.definition.moves[&"two_heavens"].startup + 1, &"two_heavens"); pose(s, Fighter.State.GUARD)
	await snap("4_two_heavens")
	var sh: MoveDefinition = s.definition.moves[&"stand_heavy"]
	pose(m, Fighter.State.GUARD)
	pose(s, Fighter.State.MOVE, sh.startup, &"stand_heavy")
	await snap("5_club_start")
	pose(s, Fighter.State.MOVE, sh.startup + sh.active - 1, &"stand_heavy")
	await snap("6_club_end")
	pose(m, Fighter.State.STAND)
	pose(s, Fighter.State.MOVE, s.definition.moves[&"kanabo_quake"].startup + 2, &"kanabo_quake")
	await snap("7_quake")
	pose(s, Fighter.State.MOVE, 40, &"sake")
	await snap("8_sake")
	pose(s, Fighter.State.STAND)
	pose(m, Fighter.State.MOVE, m.definition.moves[&"throw"].startup + 1, &"throw")
	await snap("9_throw")
	quit()
