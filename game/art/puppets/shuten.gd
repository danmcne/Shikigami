extends RefCounted
## Shuten-dōji as a cut-paper puppet: a huge oni in a boxing stance, chest
## toward us, his free lead hand up and forward, the iron kanabō dragged low
## behind him in his rear hand, his sake gourd tucked just inside his front
## hip. Tiger-skin loincloth with its tail, a knotted rope sash, a necklace of
## great beads, iron rings on his arms, clawed feet, wild mane and horns. A red
## oni as tori, a blue oni as uke. Facing left he is mirrored.
##
## "_f" parts are his lead side (toward the opponent), "_b" his rear side.

const P := PuppetDefinition.Part


static func definition() -> PuppetDefinition:
	var d := PuppetDefinition.new()
	d.height = 176.0
	var ring := [Vector2(-10, 0), Vector2(10, 0), Vector2(10, 5), Vector2(-10, 5)]
	var gourd := [Vector2(-1, -4), Vector2(1, -4), Vector2(1, 0), Vector2(5, 0), Vector2(7, 8), Vector2(4, 12),
			Vector2(8, 20), Vector2(0, 26), Vector2(-8, 20), Vector2(-4, 12), Vector2(-7, 8), Vector2(-5, 0), Vector2(-1, 0)]
	d.parts = [
		# Rear side: the arm that drags the club, and the rear leg.
		P.new("upper_arm_b", "torso", Vector2(-22, -54), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 32), Vector2(-9, 32)], "skin", 1, true),
		P.new("ring_b", "upper_arm_b", Vector2(0, 8), ring, "iron", 1, true),
		P.new("lower_arm_b", "upper_arm_b", Vector2(0, 31), [Vector2(-9, 0), Vector2(9, 0), Vector2(8, 26), Vector2(-7, 26)], "skin", 1, true),
		P.new("cuff_b", "lower_arm_b", Vector2(0, 18), [Vector2(-9, 0), Vector2(9, 0), Vector2(9, 6), Vector2(-9, 6)], "iron", 1, true),
		P.new("weapon_b", "lower_arm_b", Vector2(0, 26), [Vector2(-3, -6), Vector2(4, -6), Vector2(4, 16), Vector2(-3, 16)], "iron", 2),
		P.new("club_b", "weapon_b", Vector2(0, 16), [Vector2(-5, 0), Vector2(6, 0), Vector2(11, 72), Vector2(0, 78), Vector2(-10, 72)], "iron", 2),
		P.new("studs_1", "club_b", Vector2(0, 0), [Vector2(-5, 24), Vector2(-1, 24), Vector2(-1, 28), Vector2(-5, 28)], "studs", 2),
		P.new("studs_2", "club_b", Vector2(0, 0), [Vector2(2, 38), Vector2(6, 38), Vector2(6, 42), Vector2(2, 42)], "studs", 2),
		P.new("studs_3", "club_b", Vector2(0, 0), [Vector2(-7, 52), Vector2(-3, 52), Vector2(-3, 56), Vector2(-7, 56)], "studs", 2),
		P.new("studs_4", "club_b", Vector2(0, 0), [Vector2(3, 64), Vector2(7, 64), Vector2(7, 68), Vector2(3, 68)], "studs", 2),
		P.new("thigh_b", "hips", Vector2(-12, 12), [Vector2(-13, 0), Vector2(13, 0), Vector2(11, 36), Vector2(-11, 36)], "skin", 3, true),
		P.new("shin_b", "thigh_b", Vector2(0, 34), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 34), Vector2(-9, 34)], "skin", 3, true),
		P.new("foot_b", "shin_b", Vector2(0, 34), [Vector2(-9, -2), Vector2(16, -2), Vector2(16, 5), Vector2(-9, 5)], "skin", 3, true),
		P.new("claws_b", "foot_b", Vector2(16, 0), [Vector2(0, -2), Vector2(6, 2), Vector2(0, 5)], "fang", 3),
		# Lead leg.
		P.new("thigh_f", "hips", Vector2(12, 12), [Vector2(-13, 0), Vector2(13, 0), Vector2(11, 36), Vector2(-11, 36)], "skin", 4),
		P.new("shin_f", "thigh_f", Vector2(0, 34), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 34), Vector2(-9, 34)], "skin", 4),
		P.new("anklet_f", "shin_f", Vector2(0, 26), ring, "iron", 4),
		P.new("foot_f", "shin_f", Vector2(0, 34), [Vector2(-9, -2), Vector2(16, -2), Vector2(16, 5), Vector2(-9, 5)], "skin", 4),
		P.new("claws_f", "foot_f", Vector2(16, 0), [Vector2(0, -2), Vector2(6, 2), Vector2(0, 5)], "fang", 4),
		# Loincloth over the thighs.
		P.new("hips", "", Vector2(0, -80), [Vector2(-26, -6), Vector2(26, -6), Vector2(28, 18), Vector2(4, 24), Vector2(-28, 18)], "tiger", 5),
		P.new("stripe_1", "hips", Vector2(0, 0), [Vector2(-17, -4), Vector2(-12, -4), Vector2(-15, 16), Vector2(-19, 16)], "stripes", 5),
		P.new("stripe_2", "hips", Vector2(0, 0), [Vector2(-3, -4), Vector2(2, -4), Vector2(0, 21), Vector2(-4, 21)], "stripes", 5),
		P.new("stripe_3", "hips", Vector2(0, 0), [Vector2(14, -4), Vector2(19, -4), Vector2(21, 15), Vector2(17, 16)], "stripes", 5),
		P.new("pelt_tail", "hips", Vector2(-24, 10), [Vector2(0, 0), Vector2(4, 0), Vector2(-4, 22), Vector2(-12, 30), Vector2(-10, 24), Vector2(-3, 18)], "tiger", 5),
		# The torso, chest toward us.
		P.new("torso", "hips", Vector2(0, -4), [Vector2(-24, 0), Vector2(24, 0), Vector2(32, -56), Vector2(-30, -56)], "skin", 6),
		P.new("pec_f", "torso", Vector2(0, 0), [Vector2(3, -48), Vector2(26, -50), Vector2(26, -36), Vector2(4, -34)], "shade", 7),
		P.new("pec_b", "torso", Vector2(0, 0), [Vector2(-25, -48), Vector2(-2, -50), Vector2(-3, -34), Vector2(-24, -36)], "shade", 7),
		P.new("belly", "torso", Vector2(0, 0), [Vector2(-10, -26), Vector2(12, -27), Vector2(13, -10), Vector2(-9, -9)], "shade", 7),
		P.new("sash", "torso", Vector2(0, 0), [Vector2(-25, 3), Vector2(25, 3), Vector2(25, -6), Vector2(-25, -6)], "rope", 7),
		P.new("knot", "torso", Vector2(-14, 2), [Vector2(-4, -4), Vector2(4, -4), Vector2(6, 14), Vector2(2, 10), Vector2(-2, 14)], "rope", 7),
		# The gourd, tucked just inside his front hip, except while he drinks.
		P.new("gourd_hip", "hips", Vector2(12, 2), gourd, "gourd", 7),
		P.new("head", "torso", Vector2(3, -56), [Vector2(-15, 0), Vector2(16, 0), Vector2(20, -16), Vector2(16, -32), Vector2(0, -38), Vector2(-15, -32), Vector2(-19, -16)], "skin", 8),
		P.new("beads", "torso", Vector2(0, 0), [Vector2(-20, -55), Vector2(-10, -50), Vector2(0, -48), Vector2(10, -48), Vector2(22, -50),
				Vector2(28, -55), Vector2(22, -45), Vector2(10, -43), Vector2(0, -43), Vector2(-10, -45)], "beads", 8),
		P.new("mane", "head", Vector2(0, 0), [Vector2(-19, -14), Vector2(-25, -30), Vector2(-15, -46), Vector2(0, -44), Vector2(10, -50), Vector2(21, -36), Vector2(19, -26), Vector2(10, -33), Vector2(0, -37), Vector2(-10, -33), Vector2(-15, -18), Vector2(-27, 4)], "hair", 9),
		P.new("horn_f", "head", Vector2(0, 0), [Vector2(5, -35), Vector2(10, -56), Vector2(13, -54), Vector2(10, -34)], "horn", 10),
		P.new("horn_b", "head", Vector2(0, 0), [Vector2(-6, -35), Vector2(-11, -53), Vector2(-8, -54), Vector2(-2, -35)], "horn", 10),
		# Lead side: the free arm, up and forward.
		P.new("upper_arm_f", "torso", Vector2(24, -54), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 32), Vector2(-9, 32)], "skin", 11),
		P.new("ring_f", "upper_arm_f", Vector2(0, 8), ring, "iron", 11),
		P.new("lower_arm_f", "upper_arm_f", Vector2(0, 31), [Vector2(-9, 0), Vector2(9, 0), Vector2(8, 26), Vector2(-7, 26)], "skin", 11),
		P.new("cuff_f", "lower_arm_f", Vector2(0, 18), [Vector2(-9, 0), Vector2(9, 0), Vector2(9, 6), Vector2(-9, 6)], "iron", 11),
		P.new("fist_f", "lower_arm_f", Vector2(0, 26), [Vector2(-8, 0), Vector2(8, 0), Vector2(8, 10), Vector2(-8, 10)], "skin", 11),
		# The gourd in that hand, only while he drinks.
		P.new("gourd_hand", "fist_f", Vector2(0, 6), gourd, "gourd", 12),
	]
	d.props = {gourd_hand = [&"sake"]}
	d.hidden_during = {gourd_hip = [&"sake"]}
	d.face_teru = [
		[[Vector2(-3, -27), Vector2(17, -34), Vector2(18, -28), Vector2(-2, -23)], "ink"],     # brow, furious
		[[Vector2(0, -23), Vector2(15, -26), Vector2(16, -17), Vector2(1, -15)], "eye"],      # eye, blazing
		[[Vector2(6, -23), Vector2(11, -23), Vector2(11, -18), Vector2(6, -18)], "ink"],      # pupil
		[[Vector2(0, -12), Vector2(18, -13), Vector2(17, -1), Vector2(1, -2)], "ink"],        # mouth, roaring
		[[Vector2(2, -12), Vector2(5, -12), Vector2(3.5, -6)], "fang"],
		[[Vector2(13, -13), Vector2(16, -13), Vector2(14.5, -7)], "fang"],
		[[Vector2(4, -2), Vector2(7, -2), Vector2(5.5, -7)], "fang"],
	]
	d.face_kumoru = [
		[[Vector2(-3, -22), Vector2(17, -25), Vector2(18, -20), Vector2(-2, -18)], "ink"],     # brow, lowered
		[[Vector2(0, -18), Vector2(15, -20), Vector2(15, -15), Vector2(1, -15)], "eye"],      # eye, narrowed
		[[Vector2(0, -8), Vector2(18, -8), Vector2(17, -5), Vector2(1, -5)], "ink"],          # mouth, shut
		[[Vector2(2, -8), Vector2(5, -8), Vector2(3.5, -1)], "fang"],                          # fangs over the lip
		[[Vector2(13, -8), Vector2(16, -8), Vector2(14.5, -1)], "fang"],
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
	# Lead fist up and forward; the rear arm hanging, the club trailing behind
	# him with its head near the ground.
	d.rest = {torso = 4.0,
			upper_arm_f = -50.0, lower_arm_f = -100.0,
			upper_arm_b = 10.0, lower_arm_b = 5.0, weapon_b = 31.0,
			thigh_f = -22.0, shin_f = 14.0, thigh_b = 26.0, shin_b = 6.0,
			pelt_tail = 10.0}

	# The kanabō wounds hardest at its head; closer in it still hurts.
	d.weapons = [
		{name = "club", bone = "weapon_b", from = Vector2(0, 16), to = Vector2(0, 94), width = 15.0,
			zones = [[0.0, 0.3, 0.5], [0.3, 0.65, 0.8], [0.65, 1.0, 1.0]]},
		{name = "fist", bone = "fist_f", from = Vector2(0, 0), to = Vector2(0, 10), width = 16.0,
			zones = [[0.0, 1.0, 1.0]]},
	]
	# Angles beyond 180 carry a swing on over the top rather than back down
	# the way it came: 300 is straight-up-and-over to forward-down.
	var hauled := {upper_arm_b = 130.0, lower_arm_b = 10.0, weapon_b = 20.0, torso = -10.0}
	var overhead := {upper_arm_b = 175.0, lower_arm_b = 10.0, weapon_b = 10.0, torso = -8.0}
	var heave := {upper_arm_b = 178.0, lower_arm_b = 5.0, weapon_b = 5.0, upper_arm_f = -170.0, lower_arm_f = -10.0, torso = -12.0}
	var slam := {upper_arm_b = 305.0, lower_arm_b = -10.0, weapon_b = -4.0, upper_arm_f = -50.0, lower_arm_f = -20.0, torso = 28.0}
	var lift := {upper_arm_f = -80.0, lower_arm_f = -20.0, torso = 14.0}
	# The gourd from his front hip to his mouth in his lead hand: elbow raised,
	# the gourd tipped up as he drinks.
	var drink := {upper_arm_f = -149.0, lower_arm_f = -153.0, gourd_hand = 175.0, head = -22.0, torso = -8.0}
	d.swings = {
		# The jab: the free lead fist, straight out.
		stand_light = {strikes = ["fist"], keys = [
			[1.0, {upper_arm_f = -40.0, lower_arm_f = -120.0, torso = 0.0}],
			[1.2, {upper_arm_f = -88.0, lower_arm_f = -2.0, torso = 10.0}],
			[2.0, {upper_arm_f = -90.0, lower_arm_f = 0.0, torso = 10.0}]]},
		# The club hauled up from behind, over the head, and down in front with
		# the elbow bent; it ends low enough to catch a crouching opponent.
		stand_heavy = {strikes = ["club"], keys = [
			[0.45, hauled], [1.0, overhead],
			[1.75, {upper_arm_b = 300.0, lower_arm_b = -55.0, weapon_b = 40.0, torso = 22.0}],
			[2.0, {upper_arm_b = 305.0, lower_arm_b = -55.0, weapon_b = 42.0, torso = 22.0}]]},
		crouch_light = {base = "crouch", strikes = ["fist"], keys = [
			[1.0, {upper_arm_f = -30.0, lower_arm_f = -100.0}],
			[1.2, {upper_arm_f = -62.0, lower_arm_f = 0.0}],
			[2.0, {upper_arm_f = -62.0, lower_arm_f = 0.0}]]},
		# Out of the drag, the club sweeps forward along the ground.
		crouch_heavy = {base = "crouch", strikes = ["club"], keys = [
			[1.0, {upper_arm_b = 40.0, lower_arm_b = 10.0, weapon_b = 50.0}],
			[2.0, {upper_arm_b = -50.0, lower_arm_b = -10.0, weapon_b = -48.0}]]},
		jump_light = {base = "air", strikes = ["fist"], keys = [
			[1.0, {upper_arm_f = -60.0, lower_arm_f = -60.0}],
			[1.2, {upper_arm_f = -40.0, lower_arm_f = 20.0}],
			[2.0, {upper_arm_f = -40.0, lower_arm_f = 20.0}]]},
		jump_heavy = {base = "air", strikes = ["club"], keys = [
			[1.0, overhead],
			[2.0, {upper_arm_b = 330.0, lower_arm_b = 10.0, weapon_b = 10.0}]]},
		# The quake: both hands heave the club up and slam it into the ground,
		# landing exactly as the quake begins.
		kanabo_quake = {keys = [[0.4, hauled], [0.8, heave], [1.0, slam], [2.0, slam]]},
		sake = {keys = [[0.6, drink], [2.2, drink]]},
		# A one-handed lift and slam; the club stays in the other hand.
		throw = {keys = [
			[1.0, lift], [2.0, lift],
			[2.4, {upper_arm_f = -170.0, lower_arm_f = -20.0, torso = -12.0}],
			[2.7, {upper_arm_f = -30.0, lower_arm_f = 0.0, torso = 30.0}]]},
		# The rush swings the club forward out of the drag.
		rush = {strikes = ["club"], keys = [
			[1.0, {upper_arm_b = 60.0, lower_arm_b = 0.0, weapon_b = 60.0}],
			[1.2, {upper_arm_b = -70.0, lower_arm_b = -10.0, weapon_b = -20.0, torso = 22.0}],
			[2.0, {upper_arm_b = -70.0, lower_arm_b = -10.0, weapon_b = -20.0, torso = 22.0}]]},
		# Rising: an uppercut swing from behind and low, up in front.
		rising = {strikes = ["club"], keys = [
			[1.0, {upper_arm_b = 40.0, lower_arm_b = 0.0, weapon_b = 40.0}],
			[2.0, {upper_arm_b = -175.0, lower_arm_b = 0.0, weapon_b = 0.0}]]},
		summon = {keys = [
			[1.0, {upper_arm_f = -160.0, lower_arm_f = -10.0, head = -14.0}],
			[2.0, {upper_arm_f = -160.0, lower_arm_f = -10.0, head = -14.0}]]},
		finisher = {keys = [[0.4, hauled], [0.8, heave], [1.0, slam], [2.0, slam]]},
	}
	return d
