extends RefCounted
## Shuten-dōji as a cut-paper puppet: a huge oni, bare-chested, in a tiger-skin
## loincloth, wild mane and horns, an iron kanabō in his leading hand. A red
## oni as tori, a blue oni as uke.

const P := PuppetDefinition.Part


static func definition() -> PuppetDefinition:
	var d := PuppetDefinition.new()
	d.height = 176.0
	d.parts = [
		P.new("hips", "", Vector2(0, -80), [Vector2(-22, -6), Vector2(22, -6), Vector2(25, 18), Vector2(4, 22), Vector2(-25, 18)], "tiger", 3),
		P.new("stripe_1", "hips", Vector2(0, 0), [Vector2(-15, -4), Vector2(-10, -4), Vector2(-13, 16), Vector2(-17, 16)], "stripes", 3),
		P.new("stripe_2", "hips", Vector2(0, 0), [Vector2(-2, -4), Vector2(3, -4), Vector2(1, 19), Vector2(-3, 19)], "stripes", 3),
		P.new("stripe_3", "hips", Vector2(0, 0), [Vector2(11, -4), Vector2(16, -4), Vector2(18, 15), Vector2(14, 16)], "stripes", 3),
		# Far side.
		P.new("upper_arm_b", "torso", Vector2(-8, -54), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 32), Vector2(-9, 32)], "skin", 1, true),
		P.new("lower_arm_b", "upper_arm_b", Vector2(0, 31), [Vector2(-9, 0), Vector2(9, 0), Vector2(8, 26), Vector2(-7, 26)], "skin", 1, true),
		P.new("fist_b", "lower_arm_b", Vector2(0, 26), [Vector2(-8, 0), Vector2(8, 0), Vector2(8, 10), Vector2(-8, 10)], "skin", 1, true),
		P.new("thigh_b", "hips", Vector2(-8, 12), [Vector2(-13, 0), Vector2(13, 0), Vector2(11, 36), Vector2(-11, 36)], "skin", 2, true),
		P.new("shin_b", "thigh_b", Vector2(0, 34), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 34), Vector2(-9, 34)], "skin", 2, true),
		P.new("foot_b", "shin_b", Vector2(0, 34), [Vector2(-9, -2), Vector2(16, -2), Vector2(16, 5), Vector2(-9, 5)], "skin", 2, true),
		# Near side.
		P.new("thigh_f", "hips", Vector2(8, 12), [Vector2(-13, 0), Vector2(13, 0), Vector2(11, 36), Vector2(-11, 36)], "skin", 4),
		P.new("shin_f", "thigh_f", Vector2(0, 34), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 34), Vector2(-9, 34)], "skin", 4),
		P.new("foot_f", "shin_f", Vector2(0, 34), [Vector2(-9, -2), Vector2(16, -2), Vector2(16, 5), Vector2(-9, 5)], "skin", 4),
		P.new("torso", "hips", Vector2(0, -4), [Vector2(-21, 0), Vector2(21, 0), Vector2(30, -58), Vector2(-27, -58)], "skin", 5),
		P.new("chest", "torso", Vector2(0, 0), [Vector2(-6, -46), Vector2(16, -50), Vector2(19, -40), Vector2(-2, -36)], "shade", 6),
		P.new("belly", "torso", Vector2(0, 0), [Vector2(-8, -24), Vector2(12, -26), Vector2(13, -14), Vector2(-7, -12)], "shade", 6),
		P.new("sash", "torso", Vector2(0, 0), [Vector2(-22, 3), Vector2(22, 3), Vector2(22, -6), Vector2(-22, -6)], "rope", 6),
		P.new("head", "torso", Vector2(3, -58), [Vector2(-14, 0), Vector2(15, 0), Vector2(19, -16), Vector2(15, -32), Vector2(0, -38), Vector2(-14, -32), Vector2(-18, -16)], "skin", 7),
		P.new("mane", "head", Vector2(0, 0), [Vector2(-18, -14), Vector2(-24, -30), Vector2(-14, -46), Vector2(0, -44), Vector2(10, -50), Vector2(20, -36), Vector2(18, -26), Vector2(10, -33), Vector2(0, -37), Vector2(-10, -33), Vector2(-14, -18), Vector2(-26, 4)], "hair", 8),
		P.new("horn_f", "head", Vector2(0, 0), [Vector2(5, -35), Vector2(10, -56), Vector2(13, -54), Vector2(10, -34)], "horn", 9),
		P.new("horn_b", "head", Vector2(0, 0), [Vector2(-6, -35), Vector2(-11, -53), Vector2(-8, -54), Vector2(-2, -35)], "horn", 9),
		P.new("upper_arm_f", "torso", Vector2(10, -54), [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 32), Vector2(-9, 32)], "skin", 10),
		P.new("lower_arm_f", "upper_arm_f", Vector2(0, 31), [Vector2(-9, 0), Vector2(9, 0), Vector2(8, 26), Vector2(-7, 26)], "skin", 10),
		P.new("cuff_f", "lower_arm_f", Vector2(0, 18), [Vector2(-9, 0), Vector2(9, 0), Vector2(9, 6), Vector2(-9, 6)], "iron", 10),
		P.new("weapon_f", "lower_arm_f", Vector2(0, 26), [Vector2(-3, -6), Vector2(4, -6), Vector2(4, 16), Vector2(-3, 16)], "iron", 11),
		P.new("club_f", "weapon_f", Vector2(0, 16), [Vector2(-6, 0), Vector2(7, 0), Vector2(11, 92), Vector2(0, 98), Vector2(-10, 92)], "iron", 11),
		P.new("studs_1", "club_f", Vector2(0, 0), [Vector2(-5, 30), Vector2(-1, 30), Vector2(-1, 34), Vector2(-5, 34)], "studs", 11),
		P.new("studs_2", "club_f", Vector2(0, 0), [Vector2(2, 48), Vector2(6, 48), Vector2(6, 52), Vector2(2, 52)], "studs", 11),
		P.new("studs_3", "club_f", Vector2(0, 0), [Vector2(-6, 66), Vector2(-2, 66), Vector2(-2, 70), Vector2(-6, 70)], "studs", 11),
		P.new("studs_4", "club_f", Vector2(0, 0), [Vector2(3, 82), Vector2(7, 82), Vector2(7, 86), Vector2(3, 86)], "studs", 11),
	]
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
			rope = Color("d9cca5"), fang = Color("f2eee4"), ink = Color("141010")}
	var tori := common.duplicate()
	tori.merge({skin = Color("b8332a"), shade = Color("8f241e"), tiger = Color("d9a12b"),
			stripes = Color("2a1c10"), horn = Color("e8ddc0"), eye = Color("e9c647")})
	var uke := common.duplicate()
	uke.merge({skin = Color("2f5fa8"), shade = Color("21447d"), tiger = Color("b4b0a8"),
			stripes = Color("3a3a46"), horn = Color("c7cdd3"), eye = Color("dde2e7")})
	d.colourways = [tori, uke]
	# The club held low and forward, its head near the ground ahead.
	d.rest = {upper_arm_f = -10.0, lower_arm_f = -30.0, weapon_f = -8.0,
			upper_arm_b = 18.0, lower_arm_b = -30.0}
	return d
