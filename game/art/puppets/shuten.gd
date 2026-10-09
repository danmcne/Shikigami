extends RefCounted
## Shuten-dōji on the humanoid rig, in the diagonal (aspective) view of a
## boxer: torso and arms as seen from the front, head and legs in profile. His
## free lead fist is up and forward; the iron kanabō rests diagonally on his
## trailing shoulder, the arm bent in toward his torso; his sake gourd is
## tucked just inside his front hip.
## Turning toward the viewer swings his lead side away, so his lead leg is the
## far one; both arms are drawn over his torso. Tiger-skin loincloth with its
## tail, a knotted rope sash, a necklace of great beads, iron rings, clawed
## feet, wild mane and horns. A red oni as tori, a blue oni as uke.

const P := PuppetDefinition.Part
const K := PuppetDefinition.Kind
const V := PuppetDefinition.View


static func definition() -> PuppetDefinition:
	var d := PuppetDefinition.new()
	d.height = 176.0
	d.view = V.DIAGONAL
	d.anchors = {V.DIAGONAL: {lead_shoulder = Vector2(24, -54), trail_shoulder = Vector2(-22, -54),
			lead_hip = Vector2(12, 12), trail_hip = Vector2(-12, 12), neck = Vector2(3, -56)}}
	d.points = {mouth = ["head", Vector2(13, -8)], gourd = ["hips", Vector2(12, 0)], before = ["torso", Vector2(46, -24)]}
	var ring := [Vector2(-10, 0), Vector2(10, 0), Vector2(10, 5), Vector2(-10, 5)]
	var gourd := [Vector2(-1, -4), Vector2(1, -4), Vector2(1, 0), Vector2(5, 0), Vector2(7, 8), Vector2(4, 12),
			Vector2(8, 20), Vector2(0, 26), Vector2(-8, 20), Vector2(-4, 12), Vector2(-7, 8), Vector2(-5, 0), Vector2(-1, 0)]
	var thigh := [Vector2(-13, 0), Vector2(13, 0), Vector2(11, 36), Vector2(-11, 36)]
	var shin := [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 34), Vector2(-9, 34)]
	var foot := [Vector2(-9, -2), Vector2(16, -2), Vector2(16, 5), Vector2(-9, 5)]
	var claws := [Vector2(0, -2), Vector2(6, 2), Vector2(0, 5)]
	var upper := [Vector2(-11, 0), Vector2(11, 0), Vector2(9, 32), Vector2(-9, 32)]
	var fore := [Vector2(-9, 0), Vector2(9, 0), Vector2(8, 26), Vector2(-7, 26)]
	var cuff := [Vector2(-9, 0), Vector2(9, 0), Vector2(9, 6), Vector2(-9, 6)]
	d.parts = [
		P.new("hips", "", Vector2(0, -80), [Vector2(-26, -6), Vector2(26, -6), Vector2(28, 18), Vector2(4, 24), Vector2(-28, 18)], "tiger", K.CLOTHING),
		P.new("stripe_1", "hips", Vector2(0, 0), [Vector2(-17, -4), Vector2(-12, -4), Vector2(-15, 16), Vector2(-19, 16)], "stripes", K.DECO),
		P.new("stripe_2", "hips", Vector2(0, 0), [Vector2(-3, -4), Vector2(2, -4), Vector2(0, 21), Vector2(-4, 21)], "stripes", K.DECO),
		P.new("stripe_3", "hips", Vector2(0, 0), [Vector2(14, -4), Vector2(19, -4), Vector2(21, 15), Vector2(17, 16)], "stripes", K.DECO),
		P.new("pelt_tail", "hips", Vector2(-24, 10), [Vector2(0, 0), Vector2(4, 0), Vector2(-4, 22), Vector2(-12, 30), Vector2(-10, 24), Vector2(-3, 18)], "tiger", K.DECO),
		# The torso seen from the front.
		P.new("torso", "hips", Vector2(0, -4), {"front": [Vector2(-24, 0), Vector2(24, 0), Vector2(32, -56), Vector2(-30, -56)]}, "skin", K.BODY),
		P.new("pec_f", "torso", Vector2(0, 0), [Vector2(3, -48), Vector2(26, -50), Vector2(26, -36), Vector2(4, -34)], "shade", K.DECO),
		P.new("pec_b", "torso", Vector2(0, 0), [Vector2(-25, -48), Vector2(-2, -50), Vector2(-3, -34), Vector2(-24, -36)], "shade", K.DECO),
		P.new("belly", "torso", Vector2(0, 0), [Vector2(-10, -26), Vector2(12, -27), Vector2(13, -10), Vector2(-9, -9)], "shade", K.DECO),
		P.new("sash", "torso", Vector2(0, 0), [Vector2(-25, 3), Vector2(25, 3), Vector2(25, -6), Vector2(-25, -6)], "rope", K.CLOTHING),
		P.new("knot", "torso", Vector2(-14, 2), [Vector2(-4, -4), Vector2(4, -4), Vector2(6, 14), Vector2(2, 10), Vector2(-2, 14)], "rope", K.CLOTHING),
		P.new("beads", "torso", Vector2(0, 0), [Vector2(-20, -55), Vector2(-10, -50), Vector2(0, -48), Vector2(10, -48), Vector2(22, -50),
				Vector2(28, -55), Vector2(22, -45), Vector2(10, -43), Vector2(0, -43), Vector2(-10, -45)], "beads", K.CLOTHING),
		# The gourd, just inside his front hip, except while he drinks.
		P.new("gourd_hip", "hips", Vector2(12, 2), gourd, "gourd", K.CLOTHING),
		# The head in profile, toward the opponent.
		P.new("head", "torso", "neck", {"side": [Vector2(-15, 0), Vector2(16, 0), Vector2(20, -16), Vector2(16, -32), Vector2(0, -38), Vector2(-15, -32), Vector2(-19, -16)]}, "skin", K.HEAD),
		P.new("mane", "head", Vector2(0, 0), [Vector2(-19, -14), Vector2(-25, -30), Vector2(-15, -46), Vector2(0, -44), Vector2(10, -50), Vector2(21, -36), Vector2(19, -26), Vector2(10, -33), Vector2(0, -37), Vector2(-10, -33), Vector2(-15, -18), Vector2(-27, 4)], "hair", K.DECO),
		P.new("horn_f", "head", Vector2(0, 0), [Vector2(5, -35), Vector2(10, -56), Vector2(13, -54), Vector2(10, -34)], "horn", K.DECO),
		P.new("horn_b", "head", Vector2(0, 0), [Vector2(-6, -35), Vector2(-11, -53), Vector2(-8, -54), Vector2(-2, -35)], "horn", K.DECO),
		# Legs in profile: the lead leg is the far one.
		P.new("lead_thigh", "hips", "lead_hip", thigh, "skin", K.LEG),
		P.new("lead_shin", "lead_thigh", Vector2(0, 34), shin, "skin", K.LEG),
		P.new("anklet", "lead_shin", Vector2(0, 26), ring, "iron", K.DECO),
		P.new("lead_foot", "lead_shin", Vector2(0, 34), foot, "skin", K.LEG),
		P.new("lead_claws", "lead_foot", Vector2(16, 0), claws, "fang", K.DECO),
		P.new("trail_thigh", "hips", "trail_hip", thigh, "skin", K.LEG),
		P.new("trail_shin", "trail_thigh", Vector2(0, 34), shin, "skin", K.LEG),
		P.new("trail_foot", "trail_shin", Vector2(0, 34), foot, "skin", K.LEG),
		P.new("trail_claws", "trail_foot", Vector2(16, 0), claws, "fang", K.DECO),
		# The lead arm: the free fist.
		P.new("lead_upper", "torso", "lead_shoulder", upper, "skin", K.ARM_UPPER),
		P.new("lead_ring", "lead_upper", Vector2(0, 8), ring, "iron", K.DECO),
		P.new("lead_fore", "lead_upper", Vector2(0, 31), fore, "skin", K.ARM_FORE),
		P.new("lead_cuff", "lead_fore", Vector2(0, 18), cuff, "iron", K.DECO),
		P.new("lead_hand", "lead_fore", Vector2(0, 26), [Vector2(-8, 0), Vector2(8, 0), Vector2(8, 10), Vector2(-8, 10)], "skin", K.HAND),
		P.new("gourd_hand", "lead_hand", Vector2(0, 6), gourd, "gourd", K.DECO),
		# The trailing arm and the club it drags.
		P.new("trail_upper", "torso", "trail_shoulder", upper, "skin", K.ARM_UPPER),
		P.new("trail_ring", "trail_upper", Vector2(0, 8), ring, "iron", K.DECO),
		P.new("trail_fore", "trail_upper", Vector2(0, 31), fore, "skin", K.ARM_FORE),
		P.new("trail_cuff", "trail_fore", Vector2(0, 18), cuff, "iron", K.DECO),
		P.new("trail_weapon", "trail_fore", Vector2(0, 26), [Vector2(-3, -6), Vector2(4, -6), Vector2(4, 16), Vector2(-3, 16)], "iron", K.WEAPON),
		P.new("club", "trail_weapon", Vector2(0, 16), [Vector2(-5, 0), Vector2(6, 0), Vector2(11, 72), Vector2(0, 78), Vector2(-10, 72)], "iron", K.DECO),
		P.new("studs_1", "club", Vector2(0, 0), [Vector2(-5, 24), Vector2(-1, 24), Vector2(-1, 28), Vector2(-5, 28)], "studs", K.DECO),
		P.new("studs_2", "club", Vector2(0, 0), [Vector2(2, 38), Vector2(6, 38), Vector2(6, 42), Vector2(2, 42)], "studs", K.DECO),
		P.new("studs_3", "club", Vector2(0, 0), [Vector2(-7, 52), Vector2(-3, 52), Vector2(-3, 56), Vector2(-7, 56)], "studs", K.DECO),
		P.new("studs_4", "club", Vector2(0, 0), [Vector2(3, 64), Vector2(7, 64), Vector2(7, 68), Vector2(3, 68)], "studs", K.DECO),
	]
	# The gourd passes from hip to hand as his hand reaches it, and back again.
	d.props = {gourd_hand = [[&"sake", 0.38, 2.78]]}
	d.hidden_during = {gourd_hip = [[&"sake", 0.38, 2.78]]}
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
	# Lead fist up and forward; the trailing arm bent in, the club lying
	# diagonally up and back over the trailing shoulder.
	d.rest = {torso = 4.0,
			lead_upper = -50.0, lead_fore = -100.0,
			trail_upper = -15.0, trail_fore = -110.0, trail_weapon = -94.0,
			lead_thigh = -22.0, lead_shin = 14.0, trail_thigh = 26.0, trail_shin = 6.0,
			pelt_tail = 10.0}

	# The kanabō wounds hardest at its head; closer in it still hurts.
	d.weapons = [
		{name = "club", bone = "trail_weapon", from = Vector2(0, 16), to = Vector2(0, 94), width = 15.0,
			zones = [[0.0, 0.3, 0.5], [0.3, 0.65, 0.8], [0.65, 1.0, 1.0]]},
		{name = "fist", bone = "lead_hand", from = Vector2(0, 0), to = Vector2(0, 10), width = 16.0,
			zones = [[0.0, 1.0, 1.0]]},
	]
	# From the shoulder the club is raised in front of him to overhead (the
	# arm swinging forward and up, never round behind), then brought over and
	# down: angles fall from rest to -180 and rise again to strike.
	var overhead := {trail_upper = -180.0, trail_fore = -20.0, trail_weapon = -30.0, torso = -8.0}
	var heave := {trail_upper = -180.0, trail_fore = -10.0, trail_weapon = -20.0, lead_upper = -170.0, lead_fore = -10.0, torso = -12.0}
	var slam := {trail_upper = -55.0, trail_fore = -10.0, trail_weapon = -4.0, lead_upper = -50.0, lead_fore = -20.0, torso = 28.0}
	var lift := {lead_upper = -80.0, lead_fore = -20.0, torso = 14.0}
	# He reaches down for the gourd at his hip, takes it up to his mouth (elbow
	# raised, gourd tipped up), and puts it back afterwards.
	var take := {ik = {lead = {to = "gourd", bend = 1.0}}, torso = 6.0}

	# Of the two ways an arm can bring a hand to the mouth, the elbow raised
	# forward (not dropped back).
	var drink := {ik = {lead = {to = "mouth", bend = 1.0}}, gourd_hand = 175.0, head = -22.0, torso = -8.0}
	d.swings = {
		# The jab: the free lead fist, straight out.
		# A jab angled down, so it lands on the smallest opponent as well as
		# reaching the chest of most (a level jab from his height passed over
		# Kawatarō).
		stand_light = {strikes = ["fist"], keys = [
			[1.0, {lead_upper = -40.0, lead_fore = -120.0, torso = 0.0}],
			[1.2, {ik = {lead = {to = Vector2(74, -110)}}, torso = 14.0}],
			[2.0, {ik = {lead = {to = Vector2(76, -110)}}, torso = 14.0}]]},
		# From the shoulder to overhead, then down in front with the elbow
		# bent; it ends low enough to catch a crouching opponent.
		stand_heavy = {strikes = ["club"], keys = [
			[1.0, overhead],
			[1.75, {trail_upper = -60.0, trail_fore = -55.0, trail_weapon = 40.0, torso = 22.0}],
			[2.0, {trail_upper = -55.0, trail_fore = -55.0, trail_weapon = 42.0, torso = 22.0}]]},
		crouch_light = {base = "crouch", strikes = ["fist"], keys = [
			[1.0, {lead_upper = -30.0, lead_fore = -100.0}],
			[1.2, {lead_upper = -62.0, lead_fore = 0.0}],
			[2.0, {lead_upper = -62.0, lead_fore = 0.0}]]},
		# The club brought down off the shoulder behind him, then swept forward
		# along the ground.
		crouch_heavy = {base = "crouch", strikes = ["club"], keys = [
			[1.0, {trail_upper = 40.0, trail_fore = 10.0, trail_weapon = 50.0}],
			[2.0, {trail_upper = -50.0, trail_fore = -10.0, trail_weapon = -48.0}]]},
		jump_light = {base = "air", strikes = ["fist"], keys = [
			[1.0, {lead_upper = -60.0, lead_fore = -60.0}],
			[1.2, {lead_upper = -40.0, lead_fore = 20.0}],
			[2.0, {lead_upper = -40.0, lead_fore = 20.0}]]},
		jump_heavy = {base = "air", strikes = ["club"], keys = [
			[1.0, overhead],
			[2.0, {trail_upper = -30.0, trail_fore = 10.0, trail_weapon = 10.0}]]},
		# The quake: both hands heave the club up and slam it into the ground,
		# landing exactly as the quake begins.
		kanabo_quake = {keys = [[0.8, heave], [1.0, slam], [2.0, slam]]},
		# Between hip and mouth, both ways, the hand passes through its guard
		# (a key with no lead arm in it), so the drink arcs out in front.
		sake = {keys = [[0.25, take], [0.4, take], [0.58, {gourd_hand = 60.0}], [0.85, drink], [2.2, drink],
				[2.42, {gourd_hand = 60.0}], [2.62, take], [2.8, take]]},
		# A one-handed lift and slam; the club stays on the shoulder.
		throw = {keys = [
			[1.0, lift], [2.0, lift],
			[2.4, {lead_upper = -170.0, lead_fore = -20.0, torso = -12.0}],
			[2.7, {lead_upper = -30.0, lead_fore = 0.0, torso = 30.0}]]},
		rush = {strikes = ["club"], keys = [
			[1.0, {trail_upper = 60.0, trail_fore = 0.0, trail_weapon = 60.0}],
			[1.2, {trail_upper = -70.0, trail_fore = -10.0, trail_weapon = -20.0, torso = 22.0}],
			[2.0, {trail_upper = -70.0, trail_fore = -10.0, trail_weapon = -20.0, torso = 22.0}]]},
		# Rising: an uppercut swing from behind and low, up in front.
		rising = {strikes = ["club"], keys = [
			[1.0, {trail_upper = 40.0, trail_fore = 0.0, trail_weapon = 40.0}],
			[2.0, {trail_upper = -175.0, trail_fore = 0.0, trail_weapon = 0.0}]]},
		summon = {keys = [
			[1.0, {lead_upper = -160.0, lead_fore = -10.0, head = -14.0}],
			[2.0, {lead_upper = -160.0, lead_fore = -10.0, head = -14.0}]]},
		finisher = {keys = [[0.8, heave], [1.0, slam], [2.0, slam]]},
	}
	return d
