extends RefCounted
## Miyamoto Musashi as a cut-paper puppet, drawn for clarity rather than
## correctness: side-on like a boxer, the wakizashi in the near hand pointed at
## the opponent, the katana raised high (jōdan) in the far hand where it reads
## against the sky. Kimono and pleated hakama, scabbards at the obi, a crest on
## the sleeve, a headband over long tied hair. His face is a white base with
## kumadori, red as tori, indigo as uke. Facing left he is simply mirrored.

const P := PuppetDefinition.Part


static func definition() -> PuppetDefinition:
	var d := PuppetDefinition.new()
	d.height = 172.0
	d.parts = [
		P.new("hips", "", Vector2(0, -84), [Vector2(-16, -6), Vector2(17, -6), Vector2(22, 12), Vector2(-20, 12)], "garment", 3),
		# Far side: the katana arm and the back leg.
		P.new("upper_arm_b", "torso", Vector2(-5, -52), [Vector2(-8, 0), Vector2(8, 0), Vector2(11, 31), Vector2(-9, 29)], "garment", 1, true),
		P.new("lower_arm_b", "upper_arm_b", Vector2(1, 29), [Vector2(-4, 0), Vector2(5, 0), Vector2(4, 22), Vector2(-3, 22)], "skin", 1, true),
		P.new("weapon_b", "lower_arm_b", Vector2(0, 22), [Vector2(-2, -5), Vector2(2.5, -5), Vector2(2.5, 14), Vector2(-2, 14)], "hilt", 1),
		P.new("tsuba_b", "weapon_b", Vector2(0, 14), [Vector2(-5, 0), Vector2(5, 0), Vector2(5, 3), Vector2(-5, 3)], "accent", 1),
		P.new("blade_b", "weapon_b", Vector2(0, 17), [Vector2(-3, 0), Vector2(3, 0), Vector2(2, 80), Vector2(-1, 86), Vector2(-2, 3)], "steel", 1),
		P.new("thigh_b", "hips", Vector2(-5, 6), [Vector2(-11, 0), Vector2(11, 0), Vector2(15, 42), Vector2(-15, 42)], "garment", 2, true),
		P.new("shin_b", "thigh_b", Vector2(0, 40), [Vector2(-14, 0), Vector2(14, 0), Vector2(18, 37), Vector2(-18, 37)], "garment", 2, true),
		P.new("foot_b", "shin_b", Vector2(0, 37), [Vector2(-6, -2), Vector2(15, -2), Vector2(15, 3), Vector2(-6, 3)], "tabi", 2, true),
		# Near leg, with the hakama's pleats.
		P.new("thigh_f", "hips", Vector2(6, 6), [Vector2(-11, 0), Vector2(11, 0), Vector2(15, 42), Vector2(-15, 42)], "garment", 4),
		P.new("pleat_1", "thigh_f", Vector2(0, 0), [Vector2(-4, 2), Vector2(-2, 2), Vector2(-5, 42), Vector2(-7, 42)], "fold", 4),
		P.new("pleat_2", "thigh_f", Vector2(0, 0), [Vector2(4, 2), Vector2(6, 2), Vector2(9, 42), Vector2(7, 42)], "fold", 4),
		P.new("shin_f", "thigh_f", Vector2(0, 40), [Vector2(-14, 0), Vector2(14, 0), Vector2(18, 37), Vector2(-18, 37)], "garment", 4),
		P.new("pleat_3", "shin_f", Vector2(0, 0), [Vector2(-6, 0), Vector2(-4, 0), Vector2(-8, 37), Vector2(-10, 37)], "fold", 4),
		P.new("pleat_4", "shin_f", Vector2(0, 0), [Vector2(6, 0), Vector2(8, 0), Vector2(12, 37), Vector2(10, 37)], "fold", 4),
		P.new("foot_f", "shin_f", Vector2(0, 37), [Vector2(-6, -2), Vector2(15, -2), Vector2(15, 3), Vector2(-6, 3)], "tabi", 4),
		# Torso in profile, chest toward the opponent's side.
		P.new("torso", "hips", Vector2(0, -4), [Vector2(-12, 0), Vector2(13, 0), Vector2(17, -28), Vector2(14, -56), Vector2(-12, -56), Vector2(-15, -30)], "secondary", 5),
		P.new("lapel", "torso", Vector2(0, 0), [Vector2(-12, -56), Vector2(2, -56), Vector2(8, -30), Vector2(13, -56), Vector2(14, -56), Vector2(17, -28), Vector2(13, 0), Vector2(-12, 0), Vector2(-15, -30)], "garment", 6),
		P.new("collar", "torso", Vector2(0, 0), [Vector2(2, -56), Vector2(5, -56), Vector2(9, -34), Vector2(8, -30)], "secondary", 6),
		P.new("obi", "torso", Vector2(0, 0), [Vector2(-13, 3), Vector2(14, 3), Vector2(15, -9), Vector2(-14, -9)], "accent", 6),
		# The two scabbards, thrust through the obi and pointing back.
		P.new("saya_k", "hips", Vector2(4, -10), [Vector2(-2.5, 0), Vector2(2.5, 0), Vector2(2, 74), Vector2(-2, 74)], "lacquer", 7),
		P.new("saya_w", "hips", Vector2(8, -8), [Vector2(-2.5, 0), Vector2(2.5, 0), Vector2(2, 48), Vector2(-2, 48)], "lacquer", 7),
		P.new("head", "torso", Vector2(1, -57), [Vector2(-10, 0), Vector2(10, 0), Vector2(13, -14), Vector2(11, -26), Vector2(1, -31), Vector2(-9, -27), Vector2(-12, -14)], "face", 8),
		P.new("hair", "head", Vector2(0, 0), [Vector2(-13, -12), Vector2(-12, -27), Vector2(-2, -34), Vector2(10, -30), Vector2(12, -24), Vector2(4, -27), Vector2(-4, -26), Vector2(-7, -18), Vector2(-9, -6), Vector2(-16, -2)], "hair", 9),
		P.new("band", "head", Vector2(0, 0), [Vector2(-12, -22), Vector2(12, -25), Vector2(12, -21), Vector2(-12, -18)], "band", 9),
		P.new("band_tail", "head", Vector2(-12, -20), [Vector2(0, -2), Vector2(-14, 2), Vector2(-20, 10), Vector2(-12, 5), Vector2(0, 2)], "band", 9),
		P.new("topknot", "head", Vector2(-6, -31), [Vector2(-5, 0), Vector2(4, -1), Vector2(6, -8), Vector2(-3, -9)], "hair", 9),
		# Near side: the wakizashi arm, with the family crest on the sleeve.
		P.new("upper_arm_f", "torso", Vector2(6, -52), [Vector2(-8, 0), Vector2(9, 0), Vector2(12, 32), Vector2(-9, 30)], "garment", 10),
		P.new("mon", "upper_arm_f", Vector2(1, 14), [Vector2(0, -5), Vector2(3.5, -3.5), Vector2(5, 0), Vector2(3.5, 3.5), Vector2(0, 5), Vector2(-3.5, 3.5), Vector2(-5, 0), Vector2(-3.5, -3.5)], "mon", 10),
		P.new("lower_arm_f", "upper_arm_f", Vector2(1, 30), [Vector2(-4, 0), Vector2(5, 0), Vector2(4, 23), Vector2(-3, 23)], "skin", 10),
		P.new("weapon_f", "lower_arm_f", Vector2(0, 23), [Vector2(-2, -4), Vector2(2, -4), Vector2(2, 9), Vector2(-2, 9)], "hilt", 11),
		P.new("tsuba_f", "weapon_f", Vector2(0, 8), [Vector2(-4, 0), Vector2(4, 0), Vector2(4, 2.5), Vector2(-4, 2.5)], "accent", 11),
		P.new("blade_f", "weapon_f", Vector2(0, 10), [Vector2(-3, 0), Vector2(3, 0), Vector2(1.5, 52), Vector2(-1, 56), Vector2(-2, 2)], "steel", 11),
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
	# Side-on, feet split; the wakizashi levelled at the opponent, the katana
	# held high and back; the scabbards pointing back from the obi.
	d.rest = {torso = 6.0,
			upper_arm_f = -40.0, lower_arm_f = -45.0, weapon_f = -10.0,
			upper_arm_b = -160.0, lower_arm_b = -30.0, weapon_b = -26.0,
			thigh_f = -24.0, shin_f = 16.0, thigh_b = 30.0, shin_b = 6.0,
			saya_k = 75.0, saya_w = 68.0}

	# Both blades wound most near the tip and least near the guard.
	var edge := [[0.0, 0.25, 0.4], [0.25, 0.7, 0.8], [0.7, 1.0, 1.0]]
	d.weapons = [
		{name = "katana", bone = "weapon_b", from = Vector2(0, 17), to = Vector2(0, 103), width = 5.0, zones = edge},
		{name = "wakizashi", bone = "weapon_f", from = Vector2(0, 10), to = Vector2(0, 66), width = 5.0, zones = edge},
	]
	# Lights are the wakizashi (near hand), heavies the katana (far hand).
	var double_thrust := {upper_arm_f = -95.0, lower_arm_f = 0.0, weapon_f = 0.0,
			upper_arm_b = -60.0, lower_arm_b = 0.0, weapon_b = -2.0, torso = 10.0}
	var grab := {upper_arm_f = -75.0, lower_arm_f = -20.0, upper_arm_b = -70.0, lower_arm_b = -20.0, torso = 12.0}
	d.swings = {
		stand_light = {strikes = ["wakizashi"], keys = [
			[1.0, {upper_arm_f = -20.0, lower_arm_f = -110.0, weapon_f = -40.0, torso = 0.0}],
			[1.3, {upper_arm_f = -88.0, lower_arm_f = -2.0, weapon_f = 0.0, torso = 12.0}],
			[2.0, {upper_arm_f = -90.0, lower_arm_f = 0.0, weapon_f = 0.0, torso = 12.0}]]},
		# From jōdan straight down: level through the middle, low by the end.
		stand_heavy = {strikes = ["katana"], keys = [
			[1.0, {upper_arm_b = -175.0, lower_arm_b = -20.0, weapon_b = -20.0, torso = -6.0}],
			[1.75, {upper_arm_b = -45.0, lower_arm_b = -5.0, weapon_b = -5.0, torso = 18.0}],
			[2.0, {upper_arm_b = -40.0, lower_arm_b = -5.0, weapon_b = -5.0, torso = 18.0}]]},
		crouch_light = {base = "crouch", strikes = ["wakizashi"], keys = [
			[1.0, {upper_arm_f = -20.0, lower_arm_f = -100.0, weapon_f = -30.0}],
			[1.3, {upper_arm_f = -58.0, lower_arm_f = -5.0, weapon_f = -22.0}],
			[2.0, {upper_arm_f = -58.0, lower_arm_f = -5.0, weapon_f = -22.0}]]},
		crouch_heavy = {base = "crouch", strikes = ["katana"], keys = [
			[1.0, {upper_arm_b = 40.0, lower_arm_b = -30.0, weapon_b = 10.0}],
			[2.0, {upper_arm_b = -55.0, lower_arm_b = -5.0, weapon_b = -32.0}]]},
		jump_light = {base = "air", strikes = ["wakizashi"], keys = [
			[1.0, {upper_arm_f = -10.0, lower_arm_f = -100.0, weapon_f = -20.0}],
			[1.3, {upper_arm_f = -40.0, lower_arm_f = 10.0, weapon_f = 20.0}],
			[2.0, {upper_arm_f = -40.0, lower_arm_f = 10.0, weapon_f = 20.0}]]},
		jump_heavy = {base = "air", strikes = ["katana"], keys = [
			[1.0, {upper_arm_b = -170.0, lower_arm_b = -20.0, weapon_b = -10.0}],
			[2.0, {upper_arm_b = -40.0, lower_arm_b = 10.0, weapon_b = 10.0}]]},
		# Two Heavens: a double thrust, the wakizashi high to the upper body
		# and the katana low.
		two_heavens = {strikes = ["wakizashi", "katana"], keys = [
			[1.0, {upper_arm_f = -20.0, lower_arm_f = -110.0, weapon_f = -40.0,
					upper_arm_b = -10.0, lower_arm_b = -110.0, weapon_b = -30.0, torso = -4.0}],
			[1.3, double_thrust],
			[2.0, double_thrust]]},
		# Void Stance: katana high, wakizashi guarding, waiting.
		void_stance = {keys = [
			[0.5, {upper_arm_b = -170.0, lower_arm_b = -10.0, weapon_b = 0.0, upper_arm_f = -60.0, lower_arm_f = -60.0, weapon_f = -10.0}],
			[2.5, {upper_arm_b = -170.0, lower_arm_b = -10.0, weapon_b = 0.0, upper_arm_f = -60.0, lower_arm_f = -60.0, weapon_f = -10.0}]]},
		# ...and its answer, a level cut with the katana.
		void_cut = {strikes = ["katana"], keys = [
			[1.0, {upper_arm_b = 50.0, lower_arm_b = -60.0, weapon_b = -20.0}],
			[2.0, {upper_arm_b = -95.0, lower_arm_b = 0.0, weapon_b = 0.0, torso = 14.0}]]},
		throw = {keys = [
			[1.0, grab], [2.0, grab],
			[2.5, {upper_arm_f = -20.0, lower_arm_f = -110.0, upper_arm_b = 10.0, lower_arm_b = -100.0, torso = -10.0}]]},
		rush = {strikes = ["katana"], keys = [
			[1.0, {upper_arm_b = -40.0, lower_arm_b = -90.0, weapon_b = -10.0}],
			[1.2, {upper_arm_b = -90.0, lower_arm_b = 0.0, weapon_b = 0.0, torso = 18.0}],
			[2.0, {upper_arm_b = -90.0, lower_arm_b = 0.0, weapon_b = 0.0, torso = 18.0}]]},
		rising = {strikes = ["katana"], keys = [
			[0.5, {upper_arm_b = 0.0, lower_arm_b = -20.0, weapon_b = 40.0}],
			[1.0, {upper_arm_b = -120.0, lower_arm_b = -10.0, weapon_b = 0.0}],
			[2.0, {upper_arm_b = -175.0, lower_arm_b = 0.0, weapon_b = 0.0}]]},
		summon = {keys = [
			[1.0, {upper_arm_f = -150.0, lower_arm_f = -20.0, head = -10.0}],
			[2.0, {upper_arm_f = -150.0, lower_arm_f = -20.0, head = -10.0}]]},
		# The finisher's cut lands exactly as its active frames begin.
		finisher = {keys = [
			[0.7, {upper_arm_b = -175.0, lower_arm_b = -10.0, weapon_b = -10.0, upper_arm_f = -150.0, torso = -8.0}],
			[1.0, {upper_arm_b = -60.0, lower_arm_b = 0.0, weapon_b = -20.0, upper_arm_f = 30.0, torso = 18.0}],
			[2.0, {upper_arm_b = -60.0, lower_arm_b = 0.0, weapon_b = -20.0, upper_arm_f = 30.0, torso = 18.0}]]},
	}
	return d
