extends SceneTree
## Renders a giant at chosen moments of its attacks, through the real game,
## for art review. Needs a display (see shot.gd). Output: /tmp/giant_<name>.png
const Bestiary := preload("res://game/monsters/bestiary.gd")
var main

func snap(name: String) -> void:
	main.queue_redraw()
	for k in 2: await process_frame
	root.get_viewport().get_texture().get_image().get_region(Rect2i(0, 200, 1280, 480)).save_png("/tmp/giant_%s.png" % name)

func at(m: Monster, id: StringName, t: float) -> void:
	for a in m.monster.attacks:
		if a.move.id == id:
			m.attack = a
			m._begin(a.move)
			var mv: MoveDefinition = a.move
			m.state_frame = int(t * mv.startup) if t < 1.0 else mv.startup + int((t - 1.0) * mv.active) if t < 2.0 else mv.startup + mv.active + int((t - 2.0) * mv.recovery)
			return

func _init():
	Settings.set_option("yokai_unlocked", true)
	main = load("res://game/main.gd").new()
	root.add_child(main)
	for i in 3: await process_frame
	var giant: String = OS.get_cmdline_user_args()[0] if OS.get_cmdline_user_args().size() > 0 else "ushi_oni"
	main.bout = Bout.versus_monster(main.roster[0], [], Monster.new(Bestiary.by_id(StringName(giant)), 1))
	main.screen = main.Screen.VERSUS
	main.set_physics_process(false)
	var b: Bout = main.bout
	b.phase = Bout.Phase.FIGHT
	b.fighters[0].position = Vector2(-230, 0)
	var m: Monster = b.fighters[1]
	m.position.x = 120
	m.facing = -1
	await snap("rest")
	for pair in [[&"leg_stab", 0.6], [&"leg_stab", 1.5], [&"stomp", 0.8], [&"stomp", 1.5], [&"charge", 1.3], [&"poison_breath", 1.2], [&"buck", 1.5]]:
		at(m, pair[0], pair[1])
		await snap("%s_%s" % [pair[0], pair[1]])
	m.state = Fighter.State.STAND
	m.move = null
	m.part_health[1] = 0
	await snap("broken")
	m.part_health[1] = 350
	at(m, &"charge", 2.5)
	await snap("exposed")
	quit()
