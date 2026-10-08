extends RefCounted
## Miyamoto Musashi on the humanoid rig, in side view with his lead side near:
## the wakizashi in the lead (near) hand levelled at the opponent, the katana
## raised high (jōdan) in the trailing (far) hand, where a large blade on the
## far side stays visible by being held up. Kimono and pleated hakama,
## scabbards at the obi, a crest on the sleeve, a headband over long tied
## hair. His face is a white base with kumadori, red as tori, indigo as uke.

const P := PuppetDefinition.Part
const K := PuppetDefinition.Kind
const V := PuppetDefinition.View


static func definition(world_scale := 1.0) -> PuppetDefinition:
	var d := PuppetDefinition.new()
	d.height = 172.0
	d.view = V.SIDE
	d.side_lead_near = true
	d.anchors = {V.SIDE: {lead_shoulder = Vector2(6, -52), trail_shoulder = Vector2(-5, -52),
			lead_hip = Vector2(6, 6), trail_hip = Vector2(-5, 6), neck = Vector2(1, -57)}}
	var thigh := [Vector2(-11, 0), Vector2(11, 0), Vector2(15, 42), Vector2(-15, 42)]
	var shin := [Vector2(-14, 0), Vector2(14, 0), Vector2(18, 37), Vector2(-18, 37)]
	var foot := [Vector2(-6, -2), Vector2(15, -2), Vector2(15, 3), Vector2(-6, 3)]
	var sleeve := [Vector2(-8, 0), Vector2(9, 0), Vector2(12, 32), Vector2(-9, 30)]
	var forearm := [Vector2(-4, 0), Vector2(5, 0), Vector2(4, 23), Vector2(-3, 23)]
	d.parts = [
		P.new("hips", "", Vector2(0, -84), [Vector2(-16, -6), Vector2(17, -6), Vector2(22, 12), Vector2(-20, 12)], "garment", K.CLOTHING),
		P.new("torso", "hips", Vector2(0, -4), [Vector2(-12, 0), Vector2(13, 0), Vector2(17, -28), Vector2(14, -56), Vector2(-12, -56), Vector2(-15, -30)], "secondary", K.BODY),
		P.new("head", "torso", "neck", [Vector2(-10, 0), Vector2(10, 0), Vector2(13, -14), Vector2(11, -26), Vector2(1, -31), Vector2(-9, -27), Vector2(-12, -14)], "face", K.HEAD),
		P.new("hair", "head", Vector2(0, 0), [Vector2(-13, -12), Vector2(-12, -27), Vector2(-2, -34), Vector2(10, -30), Vector2(12, -24), Vector2(4, -27), Vector2(-4, -26), Vector2(-7, -18), Vector2(-9, -6), Vector2(-16, -2)], "hair", K.DECO),
		P.new("band", "head", Vector2(0, 0), [Vector2(-12, -22), Vector2(12, -25), Vector2(12, -21), Vector2(-12, -18)], "band", K.DECO),
		P.new("band_tail", "head", Vector2(-12, -20), [Vector2(0, -2), Vector2(-14, 2), Vector2(-20, 10), Vector2(-12, 5), Vector2(0, 2)], "band", K.DECO),
		P.new("topknot", "head", Vector2(-6, -31), [Vector2(-5, 0), Vector2(4, -1), Vector2(6, -8), Vector2(-3, -9)], "hair", K.DECO),
		P.new("lapel", "torso", Vector2(0, 0), [Vector2(-12, -56), Vector2(2, -56), Vector2(8, -30), Vector2(13, -56), Vector2(14, -56), Vector2(17, -28), Vector2(13, 0), Vector2(-12, 0), Vector2(-15, -30)], "garment", K.CLOTHING),
		P.new("collar", "torso", Vector2(0, 0), [Vector2(2, -56), Vector2(5, -56), Vector2(9, -34), Vector2(8, -30)], "secondary", K.CLOTHING),
		P.new("obi", "torso", Vector2(0, 0), [Vector2(-13, 3), Vector2(14, 3), Vector2(15, -9), Vector2(-14, -9)], "accent", K.CLOTHING),
		P.new("saya_k", "hips", Vector2(4, -10), [Vector2(-2.5, 0), Vector2(2.5, 0), Vector2(2, 74), Vector2(-2, 74)], "lacquer", K.CLOTHING),
		P.new("saya_w", "hips", Vector2(8, -8), [Vector2(-2.5, 0), Vector2(2.5, 0), Vector2(2, 48), Vector2(-2, 48)], "lacquer", K.CLOTHING),
		# The trailing (far) side: the katana arm and the back leg.
		P.new("trail_upper", "torso", "trail_shoulder", sleeve, "garment", K.ARM_UPPER),
		P.new("trail_fore", "trail_upper", Vector2(1, 29), forearm, "skin", K.ARM_FORE),
		P.new("trail_weapon", "trail_fore", Vector2(0, 22), [Vector2(-2, -4), Vector2(2, -4), Vector2(2, 9), Vector2(-2, 9)], "hilt", K.WEAPON),
		P.new("trail_tsuba", "trail_weapon", Vector2(0, 8), [Vector2(-4, 0), Vector2(4, 0), Vector2(4, 2.5), Vector2(-4, 2.5)], "accent", K.DECO),
		P.new("trail_blade", "trail_weapon", Vector2(0, 10), [Vector2(-3, 0), Vector2(3, 0), Vector2(1.5, 52), Vector2(-1, 56), Vector2(-2, 2)], "steel", K.DECO),
		P.new("trail_thigh", "hips", "trail_hip", thigh, "garment", K.LEG),
		P.new("trail_shin", "trail_thigh", Vector2(0, 40), shin, "garment", K.LEG),
		P.new("trail_foot", "trail_shin", Vector2(0, 37), foot, "tabi", K.LEG),
		# The lead (near) side: the wakizashi arm with the crest on its sleeve,
		# and the front leg with the hakama's pleats.
		P.new("lead_thigh", "hips", "lead_hip", thigh, "garment", K.LEG),
		P.new("pleat_1", "lead_thigh", Vector2(0, 0), [Vector2(-4, 2), Vector2(-2, 2), Vector2(-5, 42), Vector2(-7, 42)], "fold", K.DECO),
		P.new("pleat_2", "lead_thigh", Vector2(0, 0), [Vector2(4, 2), Vector2(6, 2), Vector2(9, 42), Vector2(7, 42)], "fold", K.DECO),
		P.new("lead_shin", "lead_thigh", Vector2(0, 40), shin, "garment", K.LEG),
		P.new("pleat_3", "lead_shin", Vector2(0, 0), [Vector2(-6, 0), Vector2(-4, 0), Vector2(-8, 37), Vector2(-10, 37)], "fold", K.DECO),
		P.new("pleat_4", "lead_shin", Vector2(0, 0), [Vector2(6, 0), Vector2(8, 0), Vector2(12, 37), Vector2(10, 37)], "fold", K.DECO),
		P.new("lead_foot", "lead_shin", Vector2(0, 37), foot, "tabi", K.LEG),
		P.new("lead_upper", "torso", "lead_shoulder", sleeve, "garment", K.ARM_UPPER),
		P.new("mon", "lead_upper", Vector2(1, 14), [Vector2(0, -5), Vector2(3.5, -3.5), Vector2(5, 0), Vector2(3.5, 3.5), Vector2(0, 5), Vector2(-3.5, 3.5), Vector2(-5, 0), Vector2(-3.5, -3.5)], "mon", K.DECO),
		P.new("lead_fore", "lead_upper", Vector2(1, 30), forearm, "skin", K.ARM_FORE),
		P.new("lead_weapon", "lead_fore", Vector2(0, 23), [Vector2(-2, -5), Vector2(2.5, -5), Vector2(2.5, 14), Vector2(-2, 14)], "hilt", K.WEAPON),
		P.new("lead_tsuba", "lead_weapon", Vector2(0, 14), [Vector2(-5, 0), Vector2(5, 0), Vector2(5, 3), Vector2(-5, 3)], "accent", K.DECO),
		P.new("lead_blade", "lead_weapon", Vector2(0, 17), [Vector2(-3, 0), Vector2(3, 0), Vector2(2, 80), Vector2(-1, 86), Vector2(-2, 3)], "steel", K.DECO),
	]
	var ink := "ink"
	d.face_teru = [
		[[Vector2(-1, -20), Vector2(9, -23), Vector2(10, -21), Vector2(0, -18)], ink],        # brow, raised
		[[Vector2(2, -16), Vector2(9, -18), Vector2(10, -15), Vector2(3, -14)], ink],         # eye, open
		[[Vector2(6, -14), Vector2(12, -25), Vector2(13, -22), Vector2(8, -13)], "paint"],    # kumadori line
		[[Vector2(-4, -15), Vector2(-1, -25), Vector2(0, -23), Vector2(-2, -14)], "paint"],
		[[Vector2(3, -6), Vector2(10, -8), Vector2(10, -6), Vector2(3, -5)], ink],            # mouth, set
	]
	d.face_kumoru = [
		[[Vector2(-1, -17), Vector2(9, -19), Vector2(10, -17), Vector2(0, -15)], ink],        # brow, knit low
		[[Vector2(2, -14), Vector2(10, -15), Vector2(10, -14), Vector2(2, -13)], ink],        # eye, narrowed
		[[Vector2(6, -13), Vector2(12, -22), Vector2(13, -20), Vector2(8, -12)], "paint"],
		[[Vector2(-4, -14), Vector2(-1, -22), Vector2(0, -20), Vector2(-2, -13)], "paint"],
		[[Vector2(3, -5), Vector2(10, -4), Vector2(10, -3), Vector2(3, -4)], ink],            # mouth, turned down
	]
	var common := {skin = Color("f0dcc2"), face = Color("f5f0e6"), hair = Color("1b1614"),
			hilt = Color("2b201a"), steel = Color("dde2e6"), tabi = Color("f3f0ea"), ink = Color("141010"),
			lacquer = Color("2a1a16"), band = Color("f1ece2")}
	var tori := common.duplicate()
	tori.merge({garment = Color("b8392a"), fold = Color("8e2a1f"), secondary = Color("ede4cf"),
			accent = Color("c9a23a"), paint = Color("c3261c"), mon = Color("ede4cf")})
	var uke := common.duplicate()
	uke.merge({garment = Color("2b3a66"), fold = Color("1e2a4c"), secondary = Color("b6b2aa"),
			accent = Color("c0c6cc"), paint = Color("233671"), mon = Color("d8dce2")})
	d.colourways = [tori, uke]
	# In profile, feet split: the wakizashi in his far hand raised and levelled
	# at the throat (his light), the katana in his near hand held low before him,
	# point down (his heavy); the scabbards pointing back from the obi.
	d.rest = {torso = 6.0,
			ik = {trail = {to = Vector2(40, -130)}, lead = {to = Vector2(30, -98)}},
			aim = {trail_weapon = -100.0}, lead_weapon = 0.0,
			lead_thigh = -24.0, lead_shin = 16.0, trail_thigh = 30.0, trail_shin = 6.0,
			saya_k = 75.0, saya_w = 68.0}

	# Both blades wound most near the tip and least near the guard.
	var edge := [[0.0, 0.25, 0.4], [0.25, 0.7, 0.8], [0.7, 1.0, 1.0]]
	d.weapons = [
		{name = "katana", bone = "lead_weapon", from = Vector2(0, 17), to = Vector2(0, 103), width = 5.0, zones = edge},
		{name = "wakizashi", bone = "trail_weapon", from = Vector2(0, 10), to = Vector2(0, 66), width = 5.0, zones = edge},
	]
	# Lights are the wakizashi (near hand), heavies the katana (far hand).
	# His moves from the verbs: light with the wakizashi (far hand), heavy with
	# the katana (near hand), each traced from the blade that strikes.
	d.swings = Verbs.kit(d, {traced = true, world_scale = world_scale, verbs = {
		void_stance = {verb = "gesture", arm = "lead"},
		void_cut = {verb = "sweep", arm = "lead", base = "stand"},
	}})
	var wakizashi := ["stand_light", "crouch_light", "jump_light", "throw"]
	for id in d.swings:
		d.swings[id]["strikes"] = ["wakizashi"] if id in wakizashi else ["katana"]
	d.swings.erase("throw")
	d.swings["void_stance"].erase("strikes")
	# Two Heavens, staggered: the wakizashi thrusts high, then a beat later the
	# katana low, with a step in.
	var high := Verbs.swing({verb = "thrust", arm = "trail", height = "high", turn = -40.0, world_scale = world_scale}, d)
	var low := Verbs.swing({verb = "thrust", arm = "lead", height = "low", world_scale = world_scale}, d)
	var both: Dictionary = (high.keys[1][1] as Dictionary).duplicate(true)
	both.ik.merge(low.keys[1][1].ik)
	both.aim = (both.get("aim", {}) as Dictionary).duplicate()
	both.aim.merge(low.keys[1][1].get("aim", {}))
	var first: Dictionary = (high.keys[1][1] as Dictionary).duplicate(true)
	first.ik.merge(low.keys[0][1].ik)
	d.swings["two_heavens"] = {strikes = ["wakizashi", "katana"], keys = [
		[0.6, high.keys[0][1]], [1.0, first], [1.35, both], [2.0, both]]}
	return d
