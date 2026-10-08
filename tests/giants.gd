extends SceneTree
## Renders a giant at chosen moments of its attacks, through the real game,
## for art review. Needs a display (see shot.gd). Output: /tmp/giant_<name>.png
const Bestiary := preload("res://game/monsters/bestiary.gd")
var main

func snap(name: String) -> void:
	main.queue_redraw()
	for k in 2: await process_frame
	root.get_viewport().get_texture().get_image().get_region(Rect2i(0, 0, 1280, 720)).save_png("/tmp/giant_%s.png" % name)

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
	if m.monster.turns:
		m.facing = -1
	await snap("rest")
	var plan: Dictionary = {
		"ushi_oni": [[&"leg_stab", 0.6], [&"leg_stab", 1.5], [&"stomp", 0.8], [&"stomp", 1.5], [&"charge", 1.3], [&"poison_breath", 1.2], [&"buck", 1.5]],
		"gashadokuro": [[&"left_slam", 0.6], [&"left_slam", 1.5], [&"skull_bite", 0.6], [&"skull_bite", 1.5]],
		"nue": [[&"lightning", 0.9], [&"dive", 0.6], [&"dive", 1.5], [&"tail_strike", 1.4], [&"thrash", 1.4]],
	}
	for pair in plan.get(giant, []):
		at(m, pair[0], pair[1])
		await snap("%s_%s" % [pair[0], pair[1]])
	# Attacks whose pieces must be seen in flight: run the bout forward.
	var stepped: Dictionary = {"gashadokuro": [[&"left_grab", 46], [&"left_grab", 92], [&"high_clap", 48], [&"bone_rain", 44]],
		"nue": [[&"lightning", 63]]}
	for pair in stepped.get(giant, []):
		b.entities.clear()
		at(m, pair[0], 0.0)
		m._rest = 100000
		b.fighters[0].invincible = true
		for n in pair[1]:
			var intents: Array[Intent] = [Intent.new(), Intent.new()]
			b.step(intents)
			# Keep stepping after the attack ends: its pieces may still be out.
		await snap("%s_flight_%d" % [pair[0], pair[1]])
		m.state = Fighter.State.STAND
		m.move = null
	if giant == "ushi_oni":
		m.state = Fighter.State.STAND
		m.move = null
		m.part_health[1] = 0
		m.part_health[2] = 0
		await snap("broken")
		m.part_health[1] = 350
		m.part_health[2] = 350
		at(m, &"charge", 2.5)
		await snap("exposed")
	if giant == "nue":
		# Grounded: its cloud broken.
		m.state = Fighter.State.STAND
		m.move = null
		m.part_health[3] = 0
		m.position.y = 0.0
		b.entities.clear()
		await snap("grounded")
		for pair in [[&"claw", 1.4], [&"tail_lash", 1.4], [&"pounce", 1.4]]:
			at(m, pair[0], pair[1])
			m.position.y = 0.0
			await snap("%s_%s" % [pair[0], pair[1]])
	if giant == "gashadokuro":
		m.state = Fighter.State.STAND
		m.move = null
		m.part_health[1] = 0
		await snap("broken")
	quit()
