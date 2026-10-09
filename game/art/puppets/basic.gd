extends RefCounted
## Rigs for the fighters not yet drawn in detail: each a description for the
## template, with resting guards from the art direction. Weapons are drawn
## only, and hitboxes stay each move's own, unless a fighter's moves are
## animated as swings that strike with a weapon (Kojirō's are).

const Template := preload("res://game/art/puppets/template.gd")


static func definition(id: StringName, world_scale := 1.0) -> PuppetDefinition:
	var spec := _spec(id)
	spec["world_scale"] = world_scale
	return Template.build(spec) if spec.has("colours") else null


## tori warm, uke cool; anything not given falls back to the template's.
static func _palette(skin: String, tori: Dictionary, uke: Dictionary) -> Dictionary:
	var base := {skin = Color(skin), hair = Color("1b1614"), straw = Color("d8b46a"), lantern = Color("f3e3b0"),
			nail = Color("efe6d0"), ice = Color("bfe3f2"), gear = Color("c9a23a")}
	var t := base.duplicate()
	var u := base.duplicate()
	for k in tori:
		t[k] = Color(tori[k])
	for k in uke:
		u[k] = Color(uke[k])
	return {tori = t, uke = u}


static func _spread(prefix: String, count: int, from: float, to: float, extra := {}) -> Dictionary:
	var out := extra.duplicate()
	for i in count:
		out["%s_%d" % [prefix, i + 1]] = lerpf(from, to, float(i) / maxf(count - 1, 1))
	return out


static func _spec(id: StringName) -> Dictionary:
	var stance := {lead_thigh = -24.0, lead_shin = 16.0, trail_thigh = 28.0, trail_shin = 6.0, torso = 6.0}
	var r := func(extra: Dictionary) -> Dictionary:
		var out := stance.duplicate()
		out.merge(extra, true)
		return out
	var edge := [[0.0, 0.25, 0.4], [0.25, 0.7, 0.8], [0.7, 1.0, 1.0]]
	match id:
		&"kojiro":
			# In profile, both hands on the long grip, in chūdan-no-kamae: hands
			# before the navel, the point at the opponent's throat. Lights stab; the heavy rises and falls; the Swallow Cut
			# cuts down and back up; the Drying Pole is a fencer's lunge, the
			# trailing hand letting go.
			var lunge := {release = ["trail"], ik = {lead = {to = Vector2(68, -124)}}, aim = {lead_weapon = -90.0},
				torso = 22.0, lead_thigh = -55.0, lead_shin = 45.0, trail_thigh = 55.0, trail_shin = 0.0, trail_upper = 70.0, trail_fore = -20.0}
			return {view = "side", hair = "ponytail", weapon = {type = "nodachi", hand = "lead"},
				# Hands on the centre line before the navel, within reach of both arms.
				# Seigan: the grip held out in front of him, the point raised to the eyes.
				rest = r.call({ik = {lead = {to = Vector2(28, -112)}}, aim = {lead_weapon = -122.0}}),
				weapons = [{name = "nodachi", bone = "lead_weapon", from = Vector2(0, 6), to = Vector2(0, 124), width = 5.0, zones = edge}],
				swings = {
					stand_light = {strikes = ["nodachi"], keys = [
						[1.0, {ik = {lead = {to = Vector2(36, -112)}}, aim = {lead_weapon = -90.0}}],
						[1.3, {ik = {lead = {to = Vector2(60, -120)}}, aim = {lead_weapon = -92.0}, torso = 12.0}],
						[2.0, {ik = {lead = {to = Vector2(60, -120)}}, aim = {lead_weapon = -92.0}, torso = 12.0}]]},
					stand_heavy = {strikes = ["nodachi"], keys = [
						[0.8, {ik = {lead = {to = Vector2(14, -182)}}, aim = {lead_weapon = -200.0}, torso = -4.0}],
						[1.0, {ik = {lead = {to = Vector2(16, -182)}}, aim = {lead_weapon = -195.0}, torso = -4.0}],
						[1.8, {ik = {lead = {to = Vector2(52, -112)}}, aim = {lead_weapon = -60.0}, torso = 16.0}],
						[2.0, {ik = {lead = {to = Vector2(52, -112)}}, aim = {lead_weapon = -60.0}, torso = 16.0}]]},
					swallow_cut = {strikes = ["nodachi"], keys = [
						[1.0, {ik = {lead = {to = Vector2(40, -172)}}, aim = {lead_weapon = -150.0}}],
						[1.45, {ik = {lead = {to = Vector2(54, -108)}}, aim = {lead_weapon = -55.0}, torso = 14.0}],
						[2.0, {ik = {lead = {to = Vector2(40, -165)}}, aim = {lead_weapon = -140.0}}]]},
					drying_pole = {strikes = ["nodachi"], zones = [[0.0, 0.55, 0.0], [0.55, 1.0, 1.0]], keys = [
						[0.6, {release = ["trail"], ik = {lead = {to = Vector2(34, -118)}}, aim = {lead_weapon = -90.0}}],
						[1.0, lunge], [2.0, lunge], [2.6, {release = ["trail"]}]]}},
				colours = _palette("f0dcc2", {garment = "8f3a4f", secondary = "ede4cf", accent = "c9a23a", gear = "c9a23a"},
					{garment = "35406b", secondary = "b6b2aa", accent = "c0c6cc", gear = "c0c6cc"})}
		&"tomoe":
			# Diagonal, the naginata held in both hands in front of her, its blade
			# low toward the opponent.
			return {view = "diagonal", hair = "long", headband = true, weapon = {type = "naginata", hand = "trail", two_handed = true},
				verbs = {naginata_sweep = {verb = "sweep", arm = "trail"}},
				# The Naginata Wheel: the butt of the haft driven back at whoever is
				# behind her, then the blade thrust forward; traced, so it strikes
				# behind first and in front after.
				swings = {naginata_wheel = {strikes = ["trail_naginata"], keys = [
					[0.6, {yaw = 120.0, ik = {trail = {to = Vector2(14, -112)}}, aim = {trail_weapon = -80.0}}],
					[1.0, {yaw = 175.0, torso = -6.0, ik = {trail = {to = Vector2(-30, -108)}}, aim = {trail_weapon = -96.0}}],
					[1.4, {yaw = 175.0, torso = -6.0, ik = {trail = {to = Vector2(-34, -108)}}, aim = {trail_weapon = -96.0}}],
					[1.65, {yaw = 100.0, torso = 14.0, ik = {trail = {to = Vector2(64, -118)}}, aim = {trail_weapon = -92.0}}],
					[2.0, {yaw = 100.0, torso = 14.0, ik = {trail = {to = Vector2(66, -118)}}, aim = {trail_weapon = -92.0}}]]}},
				rest = r.call({ik = {trail = {to = Vector2(-4, -96)}}, aim = {trail_weapon = -60.0}}),
				colours = _palette("f2dfc8", {garment = "c0392b", secondary = "f0e7d3", accent = "c9a23a"},
					{garment = "2b4a6b", secondary = "c9ccd2", accent = "c0c6cc"})}
		&"benkei":
			# The great warrior monk: the polearm shouldered, a monk's hood. His
			# light attacks are jabs with the free lead hand.
			return {view = "diagonal", build = 1.25, hat = "hood", hair = "none", face = ["stubble", "brows"], weapon = {type = "naginata", hand = "trail"},
				verbs = {standing_death = {verb = "body"}, seven_weapons = {verb = "grab", arm = "lead"}},
				rest = r.call({trail_upper = -15.0, trail_fore = -110.0, trail_weapon = -94.0, lead_upper = -50.0, lead_fore = -90.0}),
				colours = _palette("e9cfb0", {garment = "2a2524", secondary = "e9e2d2", accent = "b8392a"},
					{garment = "2a2d3a", secondary = "d7d9de", accent = "3c5a8f"})}
		&"hanzo":
			# A straight short blade held forward, crouched low, hooded.
			# The kama in his near hand makes both his light and heavy; his far hand
			# only throws.
			return {view = "side", hat = "hood", hair = "none", face = ["mask"], weapon = {type = "kama", hand = "lead"},
				off_hand = {type = "shuriken", hand = "trail"}, light = "lead",
				# Low and in the air he kicks; his rising cut stays the kama's.
				kicks = ["crouch_light", "crouch_heavy", "jump_light", "jump_heavy"],
				verbs = {kawarimi = {verb = "gesture", arm = "lead"}, kawarimi_strike = {verb = "arc", arm = "lead"},
					shuriken = {verb = "toss", arm = "trail", style = "sidearm"}},
				rest = r.call({lead_upper = -45.0, lead_fore = -45.0, aim = {lead_weapon = -60.0},
					lead_thigh = -34.0, lead_shin = 30.0, trail_thigh = 36.0, trail_shin = 12.0, torso = 14.0}),
				colours = _palette("e8cfb2", {garment = "26262c", secondary = "34343c", accent = "b8392a", paper = "1d1d22"},
					{garment = "22262e", secondary = "30353f", accent = "3a5a9a", paper = "1a1d24"})}
		&"monk":
			# En no Gyōja: the ringed staff planted in his trailing (near) hand,
			# the lead hand forward in a mudra.
			# The shakujō held across the body in both hands, as a polearm.
			return {view = "diagonal", hat = "tokin", hair = "short", face = ["beard", "brows"], weapon = {type = "staff", hand = "trail", two_handed = true},
				# The ringed end forward, at the height of his face.
				rest = r.call({ik = {trail = {to = Vector2(0, -114)}}, aim = {trail_weapon = -100.0}}),
				verbs = {meditation = {verb = "gesture", arm = "lead"}, sutra_palm = {verb = "thrust", arm = "lead", height = "mid"}},
				colours = _palette("e8cdb0", {garment = "e9e1cf", secondary = "d97a2b", accent = "b8392a", gear = "c9a23a"},
					{garment = "d9dbe0", secondary = "6a7fa8", accent = "3a5a9a", gear = "c0c6cc"})}
		&"miko":
			# Izumo no Okuni: dancer's fan raised, a talisman in the other hand.
			# Both her strikes are the fan's (a quick jab, a great swing); the
			# trailing hand throws talismans.
			return {view = "diagonal", hair = "bun", face = ["makeup"], weapon = {type = "fan", hand = "lead"}, off_hand = {type = "ofuda", hand = "trail"},
				light = "lead", heavy = "lead",
				verbs = {ofuda = {verb = "toss", arm = "trail", style = "sidearm"}, warding_seal = {verb = "toss", arm = "trail", style = "underhand", height = "low"}},
				rest = r.call({lead_upper = -60.0, lead_fore = -70.0, trail_upper = 10.0, trail_fore = -60.0}),
				colours = _palette("f7f3ee", {garment = "c0392b", secondary = "f2eee6", accent = "c9a23a"},
					{garment = "2b4a7a", secondary = "e6e9ee", accent = "c0c6cc"})}
		&"onmyoji":
			# Abe no Seimei: in robes to his ankles, a talisman held low before
			# him, the other hand forward too; his paper birds are flung underhand.
			return {view = "side", hat = "eboshi", hair = "none", face = ["moustache"], sleeves = true, hem = "robe", weapon = {type = "ofuda", hand = "lead"},
				verbs = {five_element_seal = {verb = "gesture", arm = "lead"}},
				rest = r.call({}),
				swings = {paper_birds = {keys = [
					[0.5, {lead_upper = 30.0, lead_fore = -20.0}],
					[1.0, {lead_upper = -75.0, lead_fore = -10.0}],
					[1.6, {lead_upper = -85.0, lead_fore = -5.0}]]}},
				colours = _palette("f2e0cb", {garment = "ece4d0", secondary = "f6f1e6", accent = "b8392a"},
					{garment = "9fb0c8", secondary = "e3e7ee", accent = "2b3f6e"})}
		&"kitsune":
			# Tamamo-no-Mae: court robes, fox ears, a kitsune mask's markings,
			# three tails, a dagger.
			# Her heavy: a boxer's cross with the free trailing hand, the upper body
			# turning from the diagonal (120) through profile to 225 degrees, the
			# trailing shoulder brought forward and near.
			return {view = "diagonal", hair = "long", ears = "fox", face = "fox", sleeves = true, tails = 3, tail = "fox",
				weapon = {type = "claws", hand = "lead"}, off_hand = {type = "claws", hand = "trail"},
				verbs = {fox_step = {verb = "gesture", arm = "lead"}, bewitching_dust = {verb = "toss", arm = "lead", style = "sidearm"}},
				swings = {stand_heavy = {keys = [
					[0.6, {yaw = 110.0, ik = {trail = {to = Vector2(-4, -132)}}}],
					[1.0, {yaw = 225.0, torso = 10.0, ik = {trail = {to = Vector2(92, -128)}}}],
					[2.0, {yaw = 225.0, torso = 10.0, ik = {trail = {to = Vector2(92, -128)}}}]]}},
				rest = r.call(_spread("tail", 3, 115.0, 160.0, {ik = {lead = {to = Vector2(48, -124)}, trail = {to = Vector2(16, -112)}}})),
				colours = _palette("f3e6d6", {garment = "b8392a", secondary = "f2e2b8", accent = "c9a23a", extra = "e8a25a", hair = "a8452a", gear = "c9a23a", nail = "f3ead8"},
					{garment = "2f3f6e", secondary = "dfe3ea", accent = "c0c6cc", extra = "e6e9ee", hair = "c8c2bc", gear = "c0c6cc", nail = "eef0f4"})}
		&"tengu":
			# Sōjōbō: wings folded low, the long nose, the feather fan held before
			# his chest, the other hand up.
			# In the boxer's stance: the feather fan in his lead hand, a straight
			# double-edged sword in his trailing hand.
			return {view = "diagonal", hat = "tokin", hair = "long", nose = "tengu", wings = 0.5, weapon = {type = "feather_fan", hand = "lead"},
				off_hand = {type = "straight_sword", hand = "trail"},
				rest = r.call({ik = {lead = {to = Vector2(46, -128)}, trail = {to = Vector2(10, -104)}}, aim = {trail_weapon = -150.0}, lead_wing = 120.0, trail_wing = 135.0}),
				verbs = {gale_fan = {verb = "arc", arm = "lead"}, tengu_flight = {verb = "body"}},
				colours = _palette("c0392b", {garment = "e9e1cf", secondary = "d97a2b", accent = "b8392a", extra = "3b2f2a"},
					{garment = "d9dbe0", secondary = "6a7fa8", accent = "3a5a9a", extra = "2a2f3a", skin = "8a3a40"})}
		&"kappa":
			# Kawatarō, in profile: empty-handed, fists up, a sumo's wide feet;
			# shell on his back, water dish on his head. He leans in to spit his jet.
			var spit := {torso = 26.0, head = 10.0, lead_upper = 20.0, lead_fore = -60.0, trail_upper = 30.0, trail_fore = -60.0}
			return {view = "side", build = 1.3, hat = "dish", hair = "short", face = ["beak"], shell = true,
				verbs = {charging_grab = {verb = "grab", lean = 24.0}},
				rest = {torso = 10.0, lead_thigh = -40.0, lead_shin = 34.0, trail_thigh = 40.0, trail_shin = 10.0},
				swings = {water_jet = {keys = [[0.7, spit], [1.0, spit], [2.0, spit]]},
					# His light: a jab with the far, higher arm, the chest turning toward
					# the opponent (from profile to -60 degrees) to bring that shoulder,
					# and the reach, forward.
					stand_light = {keys = [
						[0.5, {yaw = 0.0, ik = {trail = {to = Vector2(22, -128)}}}],
						[1.0, {yaw = -60.0, torso = 12.0, ik = {trail = {to = Vector2(100, -130)}}}],
						[2.0, {yaw = -60.0, torso = 12.0, ik = {trail = {to = Vector2(100, -130)}}}]]}},
				colours = _palette("5f8f4e", {garment = "5f8f4e", secondary = "6f9f5e", accent = "c9a23a", extra = "6b5a2e", paper = "dfe8d0"},
					{garment = "4f7f8f", secondary = "5f8f9f", accent = "c0c6cc", extra = "4a5a4e", paper = "d8e4e8", skin = "4f7f8f"})}
		&"yuki_onna":
			# O-Yuki: a white kimono wide at the hem, covering her legs but not her
			# feet; trailing sleeves.
			# Claws of ice along her hands give her reach.
			return {view = "side", hair = "long_front", face = ["lips"], hem = "robe", sleeves = true,
				weapon = {type = "claws", hand = "lead", slot = "ice"}, off_hand = {type = "claws", hand = "trail", slot = "ice"},
				rest = r.call({}),
				verbs = {frost_breath = {verb = "body"}, icicle = {verb = "gesture", arm = "trail"}},
				colours = _palette("f4f2f0", {garment = "f2f1ee", secondary = "f7f6f3", accent = "c0392b", hair = "15151c", ice = "bfe3f2", lips = "6a8fc0"},
					{garment = "dde6f0", secondary = "eef3f8", accent = "8fa3c0", hair = "15151c", ice = "a8d4ea", lips = "6a8fc0"})}
		&"jorogumo":
			# In profile: a kimono to the knee, below it a spider's legs, each with
			# a leg branching before and behind, two more trailing low behind.
			# Her spider's legs keep a shuffle, and crouch and leap as a spider's.
			# Kusarigama in spirit: a kama in her near hand, her web as the chain.
			# Her light is a stab with a front spider leg.
			return {view = "side", hair = "tied", face = ["spider_eyes", "lips"], hem = "dress", spider = true, gait = "shuffle",
				weapon = {type = "kama", hand = "lead"},
				verbs = {stand_light = {verb = "limbs", limbs = {lead_before = -115.0, lead_before_foot = 15.0}},
					crouch_light = {verb = "limbs", base = "crouch", limbs = {lead_before = -95.0, lead_before_foot = 20.0}},
					web = {verb = "toss", arm = "trail", style = "overhand"}, ceiling_drop = {verb = "gesture", arm = "trail"}},
				crouch_pose = {lead_thigh = -100.0, lead_shin = 115.0, trail_thigh = 95.0, trail_shin = -110.0},
				air_pose = {lead_thigh = -55.0, lead_shin = 60.0, trail_thigh = 55.0, trail_shin = -60.0},
				rest = {torso = 6.0, aim = {lead_weapon = -60.0},
					lead_thigh = -75.0, lead_shin = 85.0, trail_thigh = 70.0, trail_shin = -80.0,
					lead_before = -30.0, lead_before_foot = 100.0, lead_behind = 30.0, lead_behind_foot = 60.0,
					trail_before = -30.0, trail_before_foot = -60.0, trail_behind = 30.0, trail_behind_foot = -100.0,
					rear_1 = 30.0, rear_1_foot = -20.0, rear_2 = 45.0, rear_2_foot = -30.0},
				colours = _palette("f1e1d2", {garment = "8a2f3a", secondary = "f0e4d6", accent = "c9a23a", extra = "c9a032", lips = "5a1a2a"},
					{garment = "2f3a5a", secondary = "e4e7ec", accent = "c0c6cc", extra = "9aa3ad"})}
		&"rokurokubi":
			# A kimono wide at the hem, a lantern hanging from a stick in her hand,
			# thrown underhand. Her head sits on her shoulders; when it flies, the
			# neck grows from there.
			return {view = "side", hair = "long", face = ["ohaguro"], hem = "robe", weapon = {type = "lantern", hand = "lead"},
				hides_head_during = &"long_neck",
				hidden_during = {lead_weapon_body = [[&"lantern", 1.0, 2.9]]},
				rest = r.call({lead_upper = -40.0, lead_fore = -50.0, aim = {lead_weapon = -120.0}}),
				swings = {lantern = {keys = [
					[0.5, {lead_upper = 40.0, lead_fore = -10.0, aim = {lead_weapon = 20.0}}],
					[1.0, {lead_upper = -100.0, lead_fore = -10.0, aim = {lead_weapon = -150.0}}],
					[1.5, {lead_upper = -110.0, lead_fore = -5.0, aim = {lead_weapon = -160.0}}]]}},
				colours = _palette("f6f2ec", {garment = "a8432e", secondary = "f0e6d4", accent = "c9a23a"},
					{garment = "3a4f7a", secondary = "e3e6ec", accent = "c0c6cc"})}
		&"tanuki":
			# Danzaburō-danuki, in profile: great belly, round ears, straw hat
			# pushed back, a sake flask, a thick tail; a leaf on his forehead when
			# he disguises himself; he drums his belly with both hands.
			var drum := {lead_upper = -30.0, lead_fore = -90.0, trail_upper = -20.0, trail_fore = -100.0, torso = -4.0}
			return {view = "side", build = 1.4, belly = true, ears = "tanuki", hat = "kasa", hair = "none", face = ["patches"], tails = 1, tail = "tanuki",
				verbs = {stand_heavy = {verb = "body"}, leaf_disguise = {verb = "gesture", arm = "lead"}, statue_slam = {verb = "body"}},
				leaf = &"leaf_disguise", weapon = {type = "flask", hand = "trail"},
				rest = r.call({hat = -28.0, tail_1 = 60.0}),
				swings = {belly_drum = {keys = [[0.6, {lead_upper = 10.0, lead_fore = -110.0, trail_upper = 15.0, trail_fore = -120.0}],
					[1.0, drum], [2.0, drum]]}},
				colours = _palette("d8c2a0", {garment = "7a5a3e", secondary = "8a6a4a", accent = "c9a23a", extra = "6a4a30", gear = "c9a46a"},
					{garment = "6a6a72", secondary = "7a7a82", accent = "c0c6cc", extra = "55555c", gear = "b8b8c0", skin = "d0d0d6", belly = "e2e2e8"})}
	return {}
