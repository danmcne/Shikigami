class_name Verbs
extends RefCounted
## The verbs of attack: each turns a short description into a swing (key
## poses over a move's phases) for any puppet, from its own shoulder, arm
## length and weapon, in either view. Contact is reached as the active frames
## begin and held through them, so a move keeps its own hitboxes honestly
## until it is traced from the rig.
##
## A description:
##   verb   thrust | arc | sweep | uppercut | kick | body | grab | toss | gesture | limbs
##   arm    lead | trail (which arm strikes; a two-handed hold moves both)
##   height high | mid | low
##   turn   degrees the upper body turns at contact (a jab -50, a cross +105)
##   reach  fraction of full arm length at contact (1.0 straight)
##   base   stand | crouch | air
##   lean   torso angle at contact;  style  underhand | sidearm | overhand (toss)
##   limbs  {part: angle} for the limbs verb (spider legs, tails)
##   strikes / zones  as for any swing, when the move is traced
##   traced  the move's hitboxes come from the rig: an arc, sweep or uppercut
##           then cuts through its active frames (entering at the top of its
##           arc, finishing at the bottom) instead of holding at contact


static func swing(d: Dictionary, p: PuppetDefinition) -> Dictionary:
	var verb: String = d.get("verb", "thrust")
	var arm: String = d.get("arm", "lead")
	var base: String = d.get("base", "stand")
	var rest := p.base_angles(base)
	var yaw0: float = rest.get("yaw", p.yaw_at_rest())
	var yaw1: float = yaw0 + d.get("turn", 0.0)
	var lean: float = d.get("lean", 10.0)
	var drop := Vector2(0, PuppetDefinition.CROUCH_DROP if base == "crouch" else 0.0)
	var probe := rest.duplicate()
	probe.yaw = yaw1
	probe.torso = lean
	var placed := p.pose_transforms(probe, drop)
	var shoulder: Vector2 = placed[arm + "_upper"].origin if placed.has(arm + "_upper") else Vector2(0, -130)
	var length := 52.0
	if p.find(arm + "_fore") and p.find(arm + "_hand"):
		length = p.find(arm + "_fore").pivot.length() + p.find(arm + "_hand").pivot.length()
	var reach: float = d.get("reach", 1.15) * length
	var height: String = d.get("height", "mid")
	var dy: float = {"high": -6.0, "mid": 24.0, "low": 60.0}[height]
	if base == "air":
		dy += 30.0
	var weapon := arm + "_weapon"
	var armed := p.find(weapon) != null
	var chamber := shoulder + Vector2(10, 18)
	var at_contact: Dictionary = {}
	var before: Dictionary = {}
	var after_keys: Array = []
	match verb:
		"thrust":
			before = _reach(arm, chamber, yaw0, lean - 6.0)
			at_contact = _reach(arm, shoulder + Vector2(reach, dy), yaw1, lean)
			if armed:
				before["aim"] = {weapon: -70.0}
				at_contact["aim"] = {weapon: -90.0 + (35.0 if height == "low" or base == "air" else 0.0)}
		"arc":
			# Raise, then cut down and forward.
			before = _reach(arm, shoulder + Vector2(-4, -62), yaw0, lean - 10.0)
			at_contact = _reach(arm, shoulder + Vector2(reach * 0.8, dy + 10.0), yaw1, lean + 6.0)
			if armed:
				before["aim"] = {weapon: -200.0}
				at_contact["aim"] = {weapon: -50.0 if base != "air" else -30.0}
		"sweep":
			# Low, from behind to before.
			before = _reach(arm, shoulder + Vector2(-26, 56), yaw0, lean)
			at_contact = _reach(arm, shoulder + Vector2(reach * 0.85, 66), yaw1, lean + 8.0)
			if armed:
				before["aim"] = {weapon: 60.0}
				at_contact["aim"] = {weapon: -78.0}
		"uppercut":
			before = _reach(arm, shoulder + Vector2(6, 62), yaw0, lean)
			at_contact = _reach(arm, shoulder + Vector2(reach * 0.6, -28), yaw1, lean - 4.0)
			if armed:
				before["aim"] = {weapon: 40.0}
				at_contact["aim"] = {weapon: -160.0}
		"kick":
			var low := height == "low"
			before = {lead_thigh = -60.0, lead_shin = 80.0, torso = -4.0, yaw = yaw0}
			at_contact = {lead_thigh = -70.0 if low else -88.0, lead_shin = 12.0 if low else 4.0, torso = -12.0, yaw = yaw1}
		"body":
			before = {torso = -10.0, yaw = yaw0}
			at_contact = {torso = 26.0, yaw = yaw1}
		"grab":
			var hold := {torso = 14.0, yaw = yaw1, ik = {}}
			for side in ["lead", "trail"]:
				if p.find(side + "_upper") and not p.find(side + "_weapon"):
					hold.ik[side] = {to = shoulder + Vector2(reach * 0.8, 22)}
			if hold.ik.is_empty():
				hold.ik[arm] = {to = shoulder + Vector2(reach * 0.8, 22)}
			before = hold
			at_contact = hold
			var lift := {torso = -10.0, ik = {}}
			for side in hold.ik:
				lift.ik[side] = {to = shoulder + Vector2(10, -60)}
			after_keys = [[2.4, lift], [2.75, {torso = 24.0}]]
		"toss":
			var style: String = d.get("style", "sidearm")
			var wind: Vector2 = {"underhand": Vector2(-20, 60), "sidearm": Vector2(-30, 20), "overhand": Vector2(-10, -60)}[style]
			before = _reach(arm, shoulder + wind, yaw0, lean - 6.0)
			at_contact = _reach(arm, shoulder + Vector2(reach * 0.9, dy - 10.0), yaw1, lean + 4.0)
		"gesture":
			at_contact = _reach(arm, shoulder + Vector2(26, -36), yaw1, 2.0)
			before = at_contact
		"limbs":
			at_contact = (d.get("limbs", {}) as Dictionary).duplicate()
			at_contact["yaw"] = yaw1
	var keys: Array = [[0.6, before], [1.0, at_contact], [2.0, at_contact]]
	# On the ground, thrusts and the end of a cut aim at fixed heights in the
	# world (where standing opponents of any size are), not at the attacker's
	# own shoulder: high just under the shortest head, mid the chest, low the
	# shins. The arm reaches as far forward as it can at that height.
	if base != "air" and verb in ["thrust", "toss", "arc"] and at_contact.has("ik"):
		var s: float = d.get("world_scale", 1.0)
		var world_y: float = {"high": -116.0, "mid": -82.0, "low": -34.0}[height]
		if verb == "arc":
			world_y = -76.0
		var y := world_y / s
		var dy2 := y - shoulder.y
		var forward := sqrt(maxf(reach * reach - dy2 * dy2, 0.12 * reach * reach)) * (0.8 if verb == "arc" else 1.0)
		at_contact.ik[arm] = {to = Vector2(shoulder.x + forward, y)}
		keys = [[0.6, before], [1.0, at_contact], [2.0, at_contact]]
	if d.get("traced", false) and armed and verb in ["arc", "sweep", "uppercut"]:
		var entry: Dictionary = {"arc": _reach(arm, shoulder + Vector2(reach * 0.55, -38), yaw0 + (yaw1 - yaw0) * 0.5, lean),
				"sweep": _reach(arm, shoulder + Vector2(reach * 0.3, 62), yaw0 + (yaw1 - yaw0) * 0.5, lean + 4.0),
				"uppercut": _reach(arm, shoulder + Vector2(reach * 0.6, 34), yaw0 + (yaw1 - yaw0) * 0.5, lean)}[verb]
		if armed:
			entry["aim"] = {weapon: {"arc": -150.0, "sweep": -10.0, "uppercut": -70.0}[verb]}
		keys = [[0.6, before], [1.0, entry], [2.0, at_contact]]
	keys.append_array(after_keys)
	var out := {keys = keys, base = base}
	# What leads the blow, for its motion trail: the hand, the foot, the body.
	match verb:
		"kick":
			out["tip"] = ["lead_foot", Vector2(12, 0)]
		"body", "gesture", "limbs":
			pass
		_:
			if p.find(arm + "_hand"):
				out["tip"] = [arm + "_hand", Vector2(0, 6)]
	for k in ["strikes", "zones"]:
		if d.has(k):
			out[k] = d[k]
	# A blow with something held is traced from it.
	if d.get("traced", false) and armed and verb in ["thrust", "arc", "sweep", "uppercut"] and not d.has("strikes"):
		var names: Array = []
		for w in p.weapons:
			if String(w.bone).begins_with(weapon):
				names.append(w.name)
		if not names.is_empty():
			out["strikes"] = names
	return out


static func _reach(arm: String, to: Vector2, yaw: float, lean: float) -> Dictionary:
	return {yaw = yaw, torso = lean, ik = {arm: {to = to}}}


## A fighter's whole kit from its stance and hold, under the shared
## conventions: in profile the far, higher arm makes the light attacks and the
## near, lower arm the heavy ones; in the boxer's stance the lead hand jabs and
## the trailing hand crosses; a shouldered weapon makes the heavy; a weapon
## held in both hands makes everything. `light` and `heavy` name the arms if a
## fighter differs. Moves it does not cover are left as they are.
static func kit(p: PuppetDefinition, spec: Dictionary) -> Dictionary:
	var side := p.view == PuppetDefinition.View.SIDE
	var near := "lead" if p.side_lead_near else "trail"
	var far := "trail" if p.side_lead_near else "lead"
	var light: String = spec.get("light", far if side else "lead")
	var heavy: String = spec.get("heavy", near if side else "trail")
	var weapon_arm := ""
	for a in ["lead", "trail"]:
		if p.find(a + "_weapon") and spec.get("weapon", {}).get("hand", "") == a:
			weapon_arm = a
	var two_handed := not p.grips.is_empty()
	if two_handed:
		light = weapon_arm
		heavy = weapon_arm
	var light_turn := (-50.0 if light == far else 0.0) if side else -25.0
	var heavy_turn := 0.0 if side else (105.0 if heavy == "trail" else 0.0)
	var heavy_armed := p.find(heavy + "_weapon") != null
	var kit := {
		stand_light = {verb = "thrust", arm = light, height = "high", turn = light_turn},
		stand_heavy = {verb = "arc" if heavy_armed else ("uppercut" if side else "thrust"), arm = heavy, height = "mid", turn = heavy_turn},
		crouch_light = {verb = "thrust", arm = light, height = "low", base = "crouch"},
		# The low heavy differs by weapon: a long two-handed weapon thrusts low,
		# a sword or shouldered weapon sweeps, the unarmed kick.
		crouch_heavy = ({verb = "thrust", arm = heavy, height = "low", base = "crouch", reach = 1.2} if two_handed
				else {verb = "sweep", arm = heavy, base = "crouch"}) if heavy_armed else {verb = "kick", height = "low", base = "crouch"},
		jump_light = {verb = "thrust", arm = light, height = "mid", base = "air", reach = 0.9},
		jump_heavy = {verb = "arc", arm = heavy, base = "air"} if heavy_armed else {verb = "kick", base = "air"},
		throw = {verb = "grab", arm = light},
		rush = {verb = "thrust", arm = heavy if heavy_armed else light, height = "mid", lean = 22.0},
		rising = {verb = "uppercut", arm = heavy},
	}
	# A fighter may kick for some of these instead (Hanzō, low and in the air).
	for id in spec.get("kicks", []):
		kit[id] = {verb = "kick", height = "low" if String(id).begins_with("crouch") else "mid",
				base = "crouch" if String(id).begins_with("crouch") else ("air" if String(id).begins_with("jump") else "stand")}
	var out := {}
	var traced: bool = spec.get("traced", false)
	var world_scale: float = spec.get("world_scale", 1.0)
	for id in kit:
		kit[id]["traced"] = traced
		kit[id]["world_scale"] = world_scale
		out[id] = swing(kit[id], p)
	for id in spec.get("verbs", {}):
		var described: Dictionary = (spec.verbs[id] as Dictionary).duplicate()
		described["traced"] = traced
		described["world_scale"] = world_scale
		out[id] = swing(described, p)
	return out
