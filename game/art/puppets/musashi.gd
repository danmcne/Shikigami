extends RefCounted
## Miyamoto Musashi as a cut-paper puppet: kimono and hakama, long hair tied
## back, katana in the leading hand and wakizashi in the other (the two
## swords of his Niten Ichi-ryū). His face is a white base painted with
## kumadori lines, red as tori, indigo as uke.

const P := PuppetDefinition.Part


static func definition() -> PuppetDefinition:
	var d := PuppetDefinition.new()
	d.height = 172.0
	d.parts = [
		P.new("hips", "", Vector2(0, -84), [Vector2(-17, -6), Vector2(17, -6), Vector2(21, 12), Vector2(-21, 12)], "garment", 3),
		# Far side: back arm with the wakizashi, back leg.
		P.new("upper_arm_b", "torso", Vector2(-3, -52), [Vector2(-8, 0), Vector2(8, 0), Vector2(11, 31), Vector2(-9, 29)], "garment", 1, true),
		P.new("lower_arm_b", "upper_arm_b", Vector2(1, 29), [Vector2(-4, 0), Vector2(5, 0), Vector2(4, 22), Vector2(-3, 22)], "skin", 1, true),
		P.new("weapon_b", "lower_arm_b", Vector2(0, 22), [Vector2(-2, -4), Vector2(2, -4), Vector2(2, 9), Vector2(-2, 9)], "hilt", 1, true),
		P.new("blade_b", "weapon_b", Vector2(0, 9), [Vector2(-3, 0), Vector2(3, 0), Vector2(1.5, 52), Vector2(-1, 56), Vector2(-2, 2)], "steel", 1, true),
		P.new("thigh_b", "hips", Vector2(-5, 6), [Vector2(-11, 0), Vector2(11, 0), Vector2(14, 42), Vector2(-14, 42)], "garment", 2, true),
		P.new("shin_b", "thigh_b", Vector2(0, 40), [Vector2(-13, 0), Vector2(13, 0), Vector2(17, 37), Vector2(-17, 37)], "garment", 2, true),
		P.new("foot_b", "shin_b", Vector2(0, 37), [Vector2(-6, -2), Vector2(15, -2), Vector2(15, 3), Vector2(-6, 3)], "tabi", 2, true),
		# Near side.
		P.new("thigh_f", "hips", Vector2(6, 6), [Vector2(-11, 0), Vector2(11, 0), Vector2(14, 42), Vector2(-14, 42)], "garment", 4),
		P.new("shin_f", "thigh_f", Vector2(0, 40), [Vector2(-13, 0), Vector2(13, 0), Vector2(17, 37), Vector2(-17, 37)], "garment", 4),
		P.new("foot_f", "shin_f", Vector2(0, 37), [Vector2(-6, -2), Vector2(15, -2), Vector2(15, 3), Vector2(-6, 3)], "tabi", 4),
		P.new("torso", "hips", Vector2(0, -4), [Vector2(-15, 0), Vector2(15, 0), Vector2(19, -56), Vector2(-18, -56)], "secondary", 5),
		P.new("lapel", "torso", Vector2(0, 0), [Vector2(-18, -56), Vector2(-4, -56), Vector2(2, -28), Vector2(9, -56), Vector2(19, -56), Vector2(15, 0), Vector2(-15, 0)], "garment", 6),
		P.new("obi", "torso", Vector2(0, 0), [Vector2(-16, 3), Vector2(16, 3), Vector2(16.5, -9), Vector2(-16.5, -9)], "accent", 6),
		P.new("head", "torso", Vector2(1, -57), [Vector2(-10, 0), Vector2(10, 0), Vector2(13, -14), Vector2(11, -26), Vector2(1, -31), Vector2(-9, -27), Vector2(-12, -14)], "face", 7),
		P.new("hair", "head", Vector2(0, 0), [Vector2(-13, -12), Vector2(-12, -27), Vector2(-2, -34), Vector2(10, -30), Vector2(12, -24), Vector2(4, -27), Vector2(-4, -26), Vector2(-7, -18), Vector2(-9, -6), Vector2(-16, -2)], "hair", 8),
		P.new("topknot", "head", Vector2(-6, -31), [Vector2(-5, 0), Vector2(4, -1), Vector2(6, -8), Vector2(-3, -9)], "hair", 8),
		P.new("upper_arm_f", "torso", Vector2(4, -52), [Vector2(-8, 0), Vector2(9, 0), Vector2(12, 32), Vector2(-9, 30)], "garment", 9),
		P.new("lower_arm_f", "upper_arm_f", Vector2(1, 30), [Vector2(-4, 0), Vector2(5, 0), Vector2(4, 23), Vector2(-3, 23)], "skin", 9),
		P.new("weapon_f", "lower_arm_f", Vector2(0, 23), [Vector2(-2, -5), Vector2(2.5, -5), Vector2(2.5, 14), Vector2(-2, 14)], "hilt", 10),
		P.new("tsuba_f", "weapon_f", Vector2(0, 14), [Vector2(-5, 0), Vector2(5, 0), Vector2(5, 3), Vector2(-5, 3)], "accent", 10),
		P.new("blade_f", "weapon_f", Vector2(0, 17), [Vector2(-3, 0), Vector2(3, 0), Vector2(2, 80), Vector2(-1, 86), Vector2(-2, 3)], "steel", 10),
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
			hilt = Color("2b201a"), steel = Color("dde2e6"), tabi = Color("f3f0ea"), ink = Color("141010")}
	var tori := common.duplicate()
	tori.merge({garment = Color("b8392a"), secondary = Color("ede4cf"), accent = Color("c9a23a"), paint = Color("c3261c")})
	var uke := common.duplicate()
	uke.merge({garment = Color("2b3a66"), secondary = Color("b6b2aa"), accent = Color("c0c6cc"), paint = Color("233671")})
	d.colourways = [tori, uke]
	# Chūdan: the katana raised toward the opponent's eyes, the wakizashi low.
	d.rest = {upper_arm_f = -25.0, lower_arm_f = -60.0, weapon_f = -55.0,
			upper_arm_b = 10.0, lower_arm_b = -35.0, weapon_b = -70.0}
	return d
