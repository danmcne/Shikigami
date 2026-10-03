extends RefCounted
## Shuten-dōji as a cut-paper puppet, drawn for clarity: a huge oni side-on
## like a boxer, the iron kanabō carried on his near shoulder and drawn behind
## his head, his free fist up in guard, his sake gourd hanging at his near
## hip. Tiger-skin loincloth with its tail, a knotted rope sash, a necklace of
## great beads, iron rings on his arms, clawed feet, wild mane and horns. A red
## oni as tori, a blue oni as uke.

const P := PuppetDefinition.Part


static func definition() -> PuppetDefinition:
	var d := PuppetDefinition.new()
	d.height = 176.0
	var ring := [Vector2(-10, 0), Vector2(10, 0), Vector2(10, 5), Vector2(-10, 5)]
	d.parts = [
		P.new("hips", "", Vector2(0, -80), [Vector2(-20, -6), Vector2(22, -6), Vector2(25, 18), Vector2(4, 22), Vector2(-24, 18)], "tiger", 3),
		P.new("stripe_1", "hips", Vector2(0, 0), [Vector2(-14, -4), Vector2(-9, -4), Vector2(-12, 16), Vector2(-16, 16)], "stripes", 3),
		P.new("stripe_2", "hips", Vector2(0, 0), [Vector2(-1, -4), Vector2(4, -4), Vector2(2, 19), Vector2(-2, 19)], "stripes", 3),
		P.new("stripe_3", "hips", Vector2(0, 0), [Vector2(12, -4), Vector2(17, -4), Vector2(19, 15), Vector2(15, 16)], "stripes", 3),
		P.new("pelt_tail", "hips", Vector2(-20, 10), [Vector2(0, 0), Vector2(4, 0), Vector2(-4, 22), Vector2(-12, 30), Vector2(-10, 24), Vector2(-3, 18)], "tiger", 3),
		# Far side: the free arm, fist up in guard.
		P.new("upper_arm_b", "torso", Vector2(-8, -54), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 32), Vector2(-9, 32)], "skin", 1, true),
		P.new("ring_b", "upper_arm_b", Vector2(0, 8), ring, "iron", 1, true),
		P.new("lower_arm_b", "upper_arm_b", Vector2(0, 31), [Vector2(-9, 0), Vector2(9, 0), Vector2(8, 26), Vector2(-7, 26)], "skin", 1, true),
		P.new("cuff_b", "lower_arm_b", Vector2(0, 18), [Vector2(-9, 0), Vector2(9, 0), Vector2(9, 6), Vector2(-9, 6)], "iron", 1, true),
		P.new("fist_b", "lower_arm_b", Vector2(0, 26), [Vector2(-8, 0), Vector2(8, 0), Vector2(8, 10), Vector2(-8, 10)], "skin", 1, true),
		P.new("thigh_b", "hips", Vector2(-8, 12), [Vector2(-13, 0), Vector2(13, 0), Vector2(11, 36), Vector2(-11, 36)], "skin", 2, true),
		P.new("shin_b", "thigh_b", Vector2(0, 34), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 34), Vector2(-9, 34)], "skin", 2, true),
		P.new("foot_b", "shin_b", Vector2(0, 34), [Vector2(-9, -2), Vector2(16, -2), Vector2(16, 5), Vector2(-9, 5)], "skin", 2, true),
		P.new("claws_b", "foot_b", Vector2(16, 0), [Vector2(0, -2), Vector2(6, 2), Vector2(0, 5)], "fang", 2),
		# Near leg.
		P.new("thigh_f", "hips", Vector2(8, 12), [Vector2(-13, 0), Vector2(13, 0), Vector2(11, 36), Vector2(-11, 36)], "skin", 4),
		P.new("shin_f", "thigh_f", Vector2(0, 34), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 34), Vector2(-9, 34)], "skin", 4),
		P.new("anklet_f", "shin_f", Vector2(0, 26), ring, "iron", 4),
		P.new("foot_f", "shin_f", Vector2(0, 34), [Vector2(-9, -2), Vector2(16, -2), Vector2(16, 5), Vector2(-9, 5)], "skin", 4),
		P.new("claws_f", "foot_f", Vector2(16, 0), [Vector2(0, -2), Vector2(6, 2), Vector2(0, 5)], "fang", 4),
		# Torso in profile: the chest thrust toward the opponent.
		P.new("torso", "hips", Vector2(0, -4), [Vector2(-18, 0), Vector2(20, 0), Vector2(30, -34), Vector2(24, -58), Vector2(-20, -58), Vector2(-24, -30)], "skin", 5),
		P.new("chest", "torso", Vector2(0, 0), [Vector2(2, -48), Vector2(24, -50), Vector2(28, -36), Vector2(6, -36)], "shade", 6),
		P.new("belly", "torso", Vector2(0, 0), [Vector2(0, -26), Vector2(20, -28), Vector2(22, -12), Vector2(1, -10)], "shade", 6),
		P.new("sash", "torso", Vector2(0, 0), [Vector2(-19, 3), Vector2(21, 3), Vector2(21, -6), Vector2(-19, -6)], "rope", 6),
		P.new("knot", "torso", Vector2(14, 2), [Vector2(-4, -4), Vector2(4, -4), Vector2(6, 14), Vector2(2, 10), Vector2(-2, 14)], "rope", 6),
		# His sake gourd, at his near hip, except while he drinks from it.
		P.new("gourd_hip", "hips", Vector2(15, 4), [Vector2(-1, -4), Vector2(1, -4), Vector2(1, 0), Vector2(5, 0), Vector2(7, 8),
				Vector2(4, 12), Vector2(8, 20), Vector2(0, 26), Vector2(-8, 20), Vector2(-4, 12), Vector2(-7, 8), Vector2(-5, 0), Vector2(-1, 0)], "gourd", 6),
		# The club: its handle in the near hand, its length behind the head.
		P.new("club_f", "weapon_f", Vector2(0, 16), [Vector2(-5, 0), Vector2(6, 0), Vector2(11, 72), Vector2(0, 78), Vector2(-10, 72)], "iron", 7),
		P.new("studs_1", "club_f", Vector2(0, 0), [Vector2(-5, 24), Vector2(-1, 24), Vector2(-1, 28), Vector2(-5, 28)], "studs", 7),
		P.new("studs_2", "club_f", Vector2(0, 0), [Vector2(2, 38), Vector2(6, 38), Vector2(6, 42), Vector2(2, 42)], "studs", 7),
		P.new("studs_3", "club_f", Vector2(0, 0), [Vector2(-7, 52), Vector2(-3, 52), Vector2(-3, 56), Vector2(-7, 56)], "studs", 7),
		P.new("studs_4", "club_f", Vector2(0, 0), [Vector2(3, 64), Vector2(7, 64), Vector2(7, 68), Vector2(3, 68)], "studs", 7),
		P.new("head", "torso", Vector2(3, -58), [Vector2(-14, 0), Vector2(15, 0), Vector2(19, -16), Vector2(15, -32), Vector2(0, -38), Vector2(-14, -32), Vector2(-18, -16)], "skin", 8),
		P.new("beads", "torso", Vector2(0, 0), [Vector2(-14, -56), Vector2(-8, -52), Vector2(0, -50), Vector2(8, -50), Vector2(16, -52),
				Vector2(20, -56), Vector2(16, -47), Vector2(8, -45), Vector2(0, -45), Vector2(-8, -47)], "beads", 8),
		P.new("mane", "head", Vector2(0, 0), [Vector2(-18, -14), Vector2(-24, -30), Vector2(-14, -46), Vector2(0, -44), Vector2(10, -50), Vector2(20, -36), Vector2(18, -26), Vector2(10, -33), Vector2(0, -37), Vector2(-10, -33), Vector2(-14, -18), Vector2(-26, 4)], "hair", 9),
		P.new("horn_f", "head", Vector2(0, 0), [Vector2(5, -35), Vector2(10, -56), Vector2(13, -54), Vector2(10, -34)], "horn", 10),
		P.new("horn_b", "head", Vector2(0, 0), [Vector2(-6, -35), Vector2(-11, -53), Vector2(-8, -54), Vector2(-2, -35)], "horn", 10),
		# Near side: the club arm.
		P.new("upper_arm_f", "torso", Vector2(12, -54), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 32), Vector2(-9, 32)], "skin", 11),
		P.new("ring_f", "upper_arm_f", Vector2(0, 8), ring, "iron", 11),
		P.new("lower_arm_f", "upper_arm_f", Vector2(0, 31), [Vector2(-9, 0), Vector2(9, 0), Vector2(8, 26), Vector2(-7, 26)], "skin", 11),
		P.new("cuff_f", "lower_arm_f", Vector2(0, 18), [Vector2(-9, 0), Vector2(9, 0), Vector2(9, 6), Vector2(-9, 6)], "iron", 11),
		P.new("weapon_f", "lower_arm_f", Vector2(0, 26), [Vector2(-3, -6), Vector2(4, -6), Vector2(4, 16), Vector2(-3, 16)], "iron", 12),
		# The gourd in his free hand, only while he drinks.
		P.new("gourd_hand", "fist_b", Vector2(0, 6), [Vector2(-5, 0), Vector2(5, 0), Vector2(7, 8), Vector2(4, 12), Vector2(8, 20),
				Vector2(0, 26), Vector2(-8, 20), Vector2(-4, 12), Vector2(-7, 8)], "gourd", 13),
	]
	d.props = {gourd_hand = [&"sake"]}
	d.hidden_during = {gourd_hip = [&"sake"]}
	d.face_teru = [
		[[Vector2(-1, -27), Vector2(18, -34), Vector2(19, -28), Vector2(0, -23)], "ink"],      # brow, furious
		[[Vector2(2, -23), Vector2(16, -26), Vector2(17, -17), Vector2(3, -15)], "eye"],      # eye, blazing
		[[Vector2(8, -23), Vector2(13, -23), Vector2(13, -18), Vector2(8, -18)], "ink"],      # pupil
		[[Vector2(2, -12), Vector2(19, -13), Vector2(18, -1), Vector2(3, -2)], "ink"],        # mouth, roaring
		[[Vector2(4, -12), Vector2(7, -12), Vector2(5.5, -6)], "fang"],
		[[Vector2(14, -13), Vector2(17, -13), Vector2(15.5, -7)], "fang"],
		[[Vector2(5, -2), Vector2(8, -2), Vector2(6.5, -7)], "fang"],
	]
	d.face_kumoru = [
		[[Vector2(-1, -22), Vector2(18, -25), Vector2(19, -20), Vector2(0, -18)], "ink"],      # brow, lowered
		[[Vector2(2, -18), Vector2(16, -20), Vector2(16, -15), Vector2(3, -15)], "eye"],      # eye, narrowed
		[[Vector2(2, -8), Vector2(19, -8), Vector2(18, -5), Vector2(3, -5)], "ink"],          # mouth, shut
		[[Vector2(4, -8), Vector2(7, -8), Vector2(5.5, -1)], "fang"],                          # fangs over the lip
		[[Vector2(14, -8), Vector2(17, -8), Vector2(15.5, -1)], "fang"],
	]
	var common := {hair = Color("1d1411"), iron = Color("3a3a3f"), studs = Color("8b8b92"),
			rope = Color("d9cca5"), fang = Color("f2eee4"), ink = Color("141010"), gourd = Color("c9a46a"),
			beads = Color("2b2420")}
	var tori := common.duplicate()
	tori.merge({skin = Color("b8332a"), shade = Color("8f241e"), tiger = Color("d9a12b"),
			stripes = Color("2a1c10"), horn = Color("e8ddc0"), eye = Color("e9c647")})
	var uke := common.duplicate()
	uke.merge({skin = Color("2f5fa8"), shade = Color("21447d"), tiger = Color("b4b0a8"),
			stripes = Color("3a3a46"), horn = Color("c7cdd3"), eye = Color("dde2e7")})
	d.colourways = [tori, uke]
	# Side-on, feet split; the club on his shoulder, angled up and back; his
	# free fist up by his chin.
	d.rest = {torso = 6.0,
			upper_arm_f = -20.0, lower_arm_f = -120.0, weapon_f = -106.0,
			upper_arm_b = -55.0, lower_arm_b = -95.0,
			thigh_f = -24.0, shin_f = 16.0, thigh_b = 30.0, shin_b = 6.0,
			pelt_tail = 10.0}

	# The kanabō wounds hardest at its head; closer in it still hurts.
	d.weapons = [
		{name = "club", bone = "weapon_f", from = Vector2(0, 16), to = Vector2(0, 94), width = 15.0,
			zones = [[0.0, 0.3, 0.5], [0.3, 0.65, 0.8], [0.65, 1.0, 1.0]]},
		{name = "fist", bone = "fist_b", from = Vector2(0, 0), to = Vector2(0, 10), width = 16.0,
			zones = [[0.0, 1.0, 1.0]]},
	]
	var slam := {upper_arm_f = -55.0, lower_arm_f = -10.0, weapon_f = -4.0, upper_arm_b = -50.0, torso = 28.0}
	var heave := {upper_arm_f = -178.0, lower_arm_f = -20.0, weapon_f = -20.0, upper_arm_b = -170.0, torso = -10.0}
	var lift := {upper_arm_f = -80.0, lower_arm_f = -20.0, upper_arm_b = -75.0, lower_arm_b = -20.0, torso = 14.0}
	# Hand at the mouth, the gourd tipped forward and up as he drinks.
	var drink := {upper_arm_b = -60.0, lower_arm_b = -126.0, gourd_hand = 59.0, head = -22.0, torso = -8.0}
	d.swings = {
		# The jab: the free fist, now the nearest thing to the opponent.
		stand_light = {strikes = ["fist"], keys = [
			[1.0, {upper_arm_b = -20.0, lower_arm_b = -120.0, torso = 0.0}],
			[1.2, {upper_arm_b = -88.0, lower_arm_b = -2.0, torso = 10.0}],
			[2.0, {upper_arm_b = -90.0, lower_arm_b = 0.0, torso = 10.0}]]},
		# From the shoulder, up over the head and down in front, elbow bent; it
		# ends low enough to catch a crouching opponent, and right under it the
		# club passes overhead.
		stand_heavy = {strikes = ["club"], keys = [
			[1.0, {upper_arm_f = -175.0, lower_arm_f = -60.0, weapon_f = -10.0, torso = -8.0}],
			[1.75, {upper_arm_f = -60.0, lower_arm_f = -55.0, weapon_f = 40.0, torso = 22.0}],
			[2.0, {upper_arm_f = -55.0, lower_arm_f = -55.0, weapon_f = 42.0, torso = 22.0}]]},
		crouch_light = {base = "crouch", strikes = ["fist"], keys = [
			[1.0, {upper_arm_b = -20.0, lower_arm_b = -100.0}],
			[1.2, {upper_arm_b = -60.0, lower_arm_b = 0.0}],
			[2.0, {upper_arm_b = -62.0, lower_arm_b = 0.0}]]},
		crouch_heavy = {base = "crouch", strikes = ["club"], keys = [
			[1.0, {upper_arm_f = 30.0, lower_arm_f = -20.0, weapon_f = 30.0}],
			[2.0, {upper_arm_f = -50.0, lower_arm_f = -10.0, weapon_f = -32.0}]]},
		jump_light = {base = "air", strikes = ["fist"], keys = [
			[1.0, {upper_arm_b = -60.0, lower_arm_b = -60.0}],
			[1.2, {upper_arm_b = -40.0, lower_arm_b = 20.0}],
			[2.0, {upper_arm_b = -40.0, lower_arm_b = 20.0}]]},
		jump_heavy = {base = "air", strikes = ["club"], keys = [
			[1.0, {upper_arm_f = -175.0, lower_arm_f = -20.0, weapon_f = -20.0}],
			[2.0, {upper_arm_f = -30.0, lower_arm_f = 10.0, weapon_f = 10.0}]]},
		# The quake: both hands bring the club down into the ground. The quake
		# itself is the ground wave, so the move keeps its own boxes.
		kanabo_quake = {keys = [[1.0, heave], [1.3, slam], [2.0, slam]]},
		# The gourd from his hip to his mouth, head thrown back.
		sake = {keys = [[0.6, drink], [2.2, drink]]},
		throw = {keys = [
			[1.0, lift], [2.0, lift],
			[2.4, {upper_arm_f = -170.0, lower_arm_f = -20.0, upper_arm_b = -170.0, lower_arm_b = -20.0, torso = -12.0}],
			[2.7, {upper_arm_f = -30.0, lower_arm_f = 0.0, upper_arm_b = -30.0, lower_arm_b = 0.0, torso = 30.0}]]},
		rush = {strikes = ["club"], keys = [
			[1.0, {upper_arm_f = 20.0, lower_arm_f = -60.0, weapon_f = -20.0}],
			[1.2, {upper_arm_f = -70.0, lower_arm_f = -10.0, weapon_f = -20.0, torso = 22.0}],
			[2.0, {upper_arm_f = -70.0, lower_arm_f = -10.0, weapon_f = -20.0, torso = 22.0}]]},
		rising = {strikes = ["club"], keys = [
			[1.0, {upper_arm_f = 10.0, lower_arm_f = -10.0, weapon_f = 40.0}],
			[2.0, {upper_arm_f = -175.0, lower_arm_f = 0.0, weapon_f = 0.0}]]},
		summon = {keys = [
			[1.0, {upper_arm_b = -160.0, lower_arm_b = -10.0, head = -14.0}],
			[2.0, {upper_arm_b = -160.0, lower_arm_b = -10.0, head = -14.0}]]},
		finisher = {keys = [[1.0, heave], [2.0, slam]]},
	}
	return d
